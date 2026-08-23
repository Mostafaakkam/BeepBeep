import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
          l10n.createYourAccount,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: l10n.name,
          hint: l10n.nameHint,
          errorText: _viewModel.nameError,
          keyboardType: TextInputType.name,
          onChanged: _viewModel.setName,
        );
      },
    );
  }

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: l10n.phone,
          hint: l10n.phoneHint,
          errorText: _viewModel.phoneError,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone, size: 20),
          onChanged: _viewModel.setPhone,
        );
      },
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
          hint: l10n.passwordHintCreate,
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
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppTextField(
          label: l10n.confirmPassword,
          hint: l10n.confirmPasswordHint,
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
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AppButton(
          text: l10n.createAccount,
          type: AppButtonType.primary,
          isFullWidth: true,
          isLoading: _viewModel.isLoading,
          onPressed: _viewModel.isFormValid ? _handleRegister : null,
        );
      },
    );
  }

  Widget _buildLoginLink() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Text.rich(
          TextSpan(
            text: l10n.haveAccountPrompt,
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: l10n.login,
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.registrationSuccessful),
        content: Text(l10n.accountCreatedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text(l10n.goToLogin),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.errorMessage ?? l10n.registrationFailed),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
