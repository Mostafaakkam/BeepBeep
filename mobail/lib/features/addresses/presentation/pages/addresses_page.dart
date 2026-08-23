import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/address_viewmodel.dart';
import 'address_form_page.dart';
import '../../../../data/models/models.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';

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
    _authViewModel.checkAuthStatus();
    _loadAddressesIfAuthenticated();
  }

  Future<void> _loadAddressesIfAuthenticated() async {
    if (_authViewModel.isAuthenticated) {
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
                    address.label,
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              address.recipientName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              address.phone,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              address.address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
            ),
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
