import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    _viewModel.setLocalizations(AppLocalizations.of(context));

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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const BrandLogo(
          size: 80,
          showBackground: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.appName,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.welcome,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: l10n.email,
          hint: l10n.emailHint,
          errorText: _viewModel.emailError,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email, size: 20),
          onChanged: _viewModel.setEmail,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: l10n.password,
          hint: l10n.passwordHint,
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
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppButton(
          text: l10n.login,
          type: AppButtonType.primary,
          isFullWidth: true,
          isLoading: _viewModel.isLoading,
          onPressed: _viewModel.isFormValid ? _handleLogin : null,
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        child: Text.rich(
          TextSpan(
            text: l10n.noAccountPrompt,
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: l10n.register,
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
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.errorMessage ?? l10n.loginFailed),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
