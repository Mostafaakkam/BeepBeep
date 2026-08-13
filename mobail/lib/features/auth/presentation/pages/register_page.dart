import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/register_viewmodel.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();
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
                    _buildNameField(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPhoneField(),
                    const SizedBox(height: AppSpacing.md),
                    _buildEmailField(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPasswordField(),
                    const SizedBox(height: AppSpacing.md),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRegisterButton(),
                    const SizedBox(height: AppSpacing.md),
                    _buildLoginLink(),
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
          'Create your account',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildNameField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: 'Name',
          hint: 'Enter your full name',
          errorText: _viewModel.nameError,
          keyboardType: TextInputType.name,
          onChanged: _viewModel.setName,
        );
      },
    );
  }
  
  Widget _buildPhoneField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: 'Phone',
          hint: '+963 900 000 000',
          errorText: _viewModel.phoneError,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone, size: 20),
          onChanged: _viewModel.setPhone,
        );
      },
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
          hint: 'Create a password',
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
  
  Widget _buildConfirmPasswordField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          errorText: _viewModel.confirmPasswordError,
          obscureText: _viewModel.obscureConfirmPassword,
          prefixIcon: const Icon(Icons.lock, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _viewModel.obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 20,
            ),
            onPressed: _viewModel.toggleConfirmPasswordVisibility,
          ),
          onChanged: _viewModel.setConfirmPassword,
        );
      },
    );
  }
  
  Widget _buildRegisterButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppButton(
          text: 'Create Account',
          type: AppButtonType.primary,
          isFullWidth: true,
          isLoading: _viewModel.isLoading,
          onPressed: _viewModel.isFormValid ? _handleRegister : null,
        );
      },
    );
  }
  
  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Text.rich(
          TextSpan(
            text: 'Already have an account? ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Login',
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
  
  Future<void> _handleRegister() async {
    _viewModel.clearMessages();
    
    final success = await _viewModel.register();
    
    if (success && mounted) {
      _showSuccessDialog();
    } else if (_viewModel.errorMessage != null && mounted) {
      _showErrorSnackBar();
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Your account has been created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.errorMessage ?? 'Registration failed'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
