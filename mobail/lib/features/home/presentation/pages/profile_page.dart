import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../addresses/presentation/pages/addresses_page.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
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
              child: _buildContent(),
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
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_authViewModel.userInfo != null) ...[
                Text(
                  'Name: ${_authViewModel.userInfo!['name']?.toString() ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Role: ${_authViewModel.userInfo!['role']?.toString() ?? 'N/A'}',
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
                  'Account',
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
                const SizedBox(height: AppSpacing.md),
                _buildLogoutButton(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'More profile features will be added in future updates.',
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
  
  Widget _buildMyOrdersButton() {
    return AppButton(
      text: 'My Orders',
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
    return AppButton(
      text: 'My Favorites',
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
    return AppButton(
      text: 'My Addresses',
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
  
  Widget _buildLogoutButton() {
    return AppButton(
      text: 'Logout',
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isLoggingOut,
      onPressed: _isLoggingOut ? null : _handleLogout,
    );
  }
}
