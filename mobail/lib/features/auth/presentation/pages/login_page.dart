import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../viewmodels/login_viewmodel.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginViewModel _viewModel = LoginViewModel();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildEmailField(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPasswordField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLoginButton(),
                    const SizedBox(height: AppSpacing.md),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        const BrandLogo(
          size: 80,
          showBackground: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Beep Beep',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildEmailField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: 'Email',
          hint: 'your@email.com',
          errorText: _viewModel.emailError,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email, size: 20),
          onChanged: _viewModel.setEmail,
        );
      },
    );
  }
  
  Widget _buildPasswordField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          errorText: _viewModel.passwordError,
          obscureText: _viewModel.obscurePassword,
          prefixIcon: const Icon(Icons.lock, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _viewModel.obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 20,
            ),
            onPressed: _viewModel.togglePasswordVisibility,
          ),
          onChanged: _viewModel.setPassword,
        );
      },
    );
  }
  
  Widget _buildLoginButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppButton(
          text: 'Login',
          type: AppButtonType.primary,
          isFullWidth: true,
          isLoading: _viewModel.isLoading,
          onPressed: _viewModel.isFormValid ? _handleLogin : null,
        );
      },
    );
  }
  
  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        child: Text.rich(
          TextSpan(
            text: "Don't have an account? ",
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Register',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    _viewModel.clearMessages();
    
    final success = await _viewModel.login();
    
    if (success && mounted) {
      // Navigate to HomePage after successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (_viewModel.errorMessage != null && mounted) {
      _showErrorSnackBar();
    }
  }
  
  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.errorMessage ?? 'Login failed'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
