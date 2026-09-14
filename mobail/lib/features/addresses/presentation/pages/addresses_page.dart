import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/address_viewmodel.dart';
import 'address_form_page.dart';
import '../../../../data/models/models.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../data/services/token_storage.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final AddressViewModel _viewModel = AddressViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    // First-round fix (2026-08-30): the original bug was
    // _authViewModel.checkAuthStatus() being fired without awaiting it, so
    // _loadAddressesIfAuthenticated() ran immediately and read
    // _authViewModel.isAuthenticated while it was still false. That was
    // corrected by awaiting checkAuthStatus() before deciding whether to
    // load -- confirmed live that GET /api/addresses itself always returns
    // 200 with the caller's own addresses for the real test account, so the
    // backend was never at fault.
    //
    // Second-round finding: gating the address fetch on the *full*
    // checkAuthStatus() cycle was still the one remaining structural
    // difference between this code path and every other one that reliably
    // works. addAddress()/updateAddress()/deleteAddress()/
    // setDefaultAddress() all call _viewModel.loadAddresses() directly, with
    // no dependency on _authViewModel at all -- that is exactly why
    // addresses correctly reappear after adding a new one. checkAuthStatus()
    // does not just read the locally cached token; it also awaits a network
    // round trip to GET /api/auth/me (_refreshRoleFromBackend) purely to
    // refresh the cached role, which has nothing to do with whether the
    // address list should be fetched. Making the initial load depend on that
    // extra network call -- which none of the other, working call sites
    // depend on -- was an avoidable difference. The fix below removes it:
    // the address list is now gated on a fast, local, network-free check
    // (does a token exist in storage at all), exactly matching the trigger
    // every other working mutation already uses, while checkAuthStatus()
    // still runs in parallel purely to drive the login-required/role UI.
    _authViewModel.checkAuthStatus();
    _loadAddressesIfTokenPresent();
  }

  Future<void> _loadAddressesIfTokenPresent() async {
    final hasToken = await TokenStorage.isAuthenticated();
    if (hasToken) {
      await _viewModel.loadAddresses();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.myAddresses,
              style: const TextStyle(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _authViewModel,
      builder: (context, child) {
        if (!_authViewModel.isAuthenticated) {
          return _buildLoginRequiredState();
        }

        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return _buildLoadingState();
            }

            if (_viewModel.isError) {
              return _buildErrorState();
            }

            if (!_viewModel.hasAddresses) {
              return _buildEmptyState();
            }

            return _buildAddressesList();
          },
        );
      },
    );
  }

  Widget _buildLoginRequiredState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.loginToViewAddresses,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.loginRequiredAddressesMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.login,
              type: AppButtonType.primary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _viewModel.errorMessage ?? l10n.failedToLoadAddresses,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.retry,
              type: AppButtonType.primary,
              onPressed: _viewModel.retry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noAddresses,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noAddressesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.addAddress,
              type: AppButtonType.primary,
              onPressed: () => _navigateToForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _viewModel.addresses.length,
            itemBuilder: (context, index) {
              return _buildAddressCard(_viewModel.addresses[index]);
            },
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.area != null && address.area!.isNotEmpty
                        ? '${address.city} - ${address.area}'
                        : address.city,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      l10n.defaultAddress,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (address.details != null && address.details!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                address.details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (!address.isDefault)
                  Expanded(
                    child: AppButton(
                      text: l10n.setDefault,
                      type: AppButtonType.secondary,
                      onPressed: _viewModel.isOperationInProgress
                          ? null
                          : () => _viewModel.setDefaultAddress(address.id),
                    ),
                  ),
                if (!address.isDefault) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: l10n.edit,
                    type: AppButtonType.secondary,
                    onPressed: _viewModel.isOperationInProgress
                        ? null
                        : () => _navigateToForm(address: address),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: _viewModel.isOperationInProgress
                      ? null
                      : () => _confirmDelete(address),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        text: l10n.addNewAddress,
        type: AppButtonType.primary,
        isFullWidth: true,
        onPressed: () => _navigateToForm(),
      ),
    );
  }

  void _navigateToForm({AddressModel? address}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormPage(address: address),
      ),
    );

    if (result != null && result is AddressModel) {
      if (address != null) {
        await _viewModel.updateAddress(result);
      } else {
        await _viewModel.addAddress(result);
      }
    }
  }

  void _confirmDelete(AddressModel address) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAddressTitle),
        content: Text(l10n.deleteAddressConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel.deleteAddress(address.id);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
