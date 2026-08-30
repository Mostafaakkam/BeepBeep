import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../addresses/presentation/pages/addresses_page.dart';
import '../../../store_owner/presentation/pages/store_owner_home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthViewModel _authViewModel = AuthViewModel();
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _authViewModel.loadUserInfo();
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authViewModel.logout();

      if (mounted) {
        // Navigate to login and clear the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.logoutFailed),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              // Store Owner Dashboard: _buildContent() reads
              // _authViewModel.userInfo!['role'] to decide whether to show
              // the dashboard entry button. loadUserInfo() (called in
              // initState) resolves asynchronously, so without this listener
              // the button would be evaluated against a stale/null userInfo
              // from the very first frame and never appear once the role
              // loads in.
              child: ListenableBuilder(
                listenable: _authViewModel,
                builder: (context, child) => _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: _authViewModel,
      builder: (context, child) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profile,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_authViewModel.userInfo != null) ...[
                Text(
                  l10n.nameValue(
                    _authViewModel.userInfo!['name']?.toString() ?? l10n.notAvailable,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.roleValue(
                    _authViewModel.userInfo!['role']?.toString() ?? l10n.notAvailable,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.account,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildMyOrdersButton(),
                const SizedBox(height: AppSpacing.md),
                _buildMyFavoritesButton(),
                const SizedBox(height: AppSpacing.md),
                _buildMyAddressesButton(),
                if (_authViewModel.userInfo?['role'] == 'store_owner') ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildStoreOwnerDashboardButton(),
                ],
                const SizedBox(height: AppSpacing.md),
                _buildLogoutButton(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLanguageCard(),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.comingSoon,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.comingSoonDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Language selector: lets the user pick English or Arabic and persists
  /// the choice (via [localeProvider], backed by SharedPreferences).
  Widget _buildLanguageCard() {
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      label: l10n.englishLanguage,
                      selected: localeProvider.locale.languageCode == 'en',
                      onTap: () => localeProvider.setLocale(const Locale('en')),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildLanguageOption(
                      label: l10n.arabicLanguage,
                      selected: localeProvider.locale.languageCode == 'ar',
                      onTap: () => localeProvider.setLocale(const Locale('ar')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.darkNavy,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersButton() {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.myOrders,
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OrdersPage(),
          ),
        );
      },
    );
  }

  Widget _buildMyFavoritesButton() {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.myFavorites,
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FavoritesPage(),
          ),
        );
      },
    );
  }

  Widget _buildMyAddressesButton() {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.myAddresses,
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddressesPage(),
          ),
        );
      },
    );
  }

  /// Entry point into the Store Owner Dashboard, shown only for
  /// authenticated store owners. The role checked here comes from
  /// AuthViewModel.userInfo, which AuthViewModel.checkAuthStatus() refreshes
  /// from the backend (GET /api/auth/me) rather than trusting a
  /// client-cached value indefinitely -- this button is a convenience
  /// entry point only, not an authorization boundary: every dashboard
  /// endpoint re-verifies the role and store ownership server-side
  /// regardless of whether this button is shown.
  Widget _buildStoreOwnerDashboardButton() {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.storeOwnerDashboard,
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const StoreOwnerHomePage(),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.logout,
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isLoggingOut,
      onPressed: _isLoggingOut ? null : _handleLogout,
    );
  }
}
