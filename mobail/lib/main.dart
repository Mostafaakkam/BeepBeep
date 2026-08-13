import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_widgets.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const BeepBeepApp());
}

class BeepBeepApp extends StatelessWidget {
  const BeepBeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beep Beep',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}

class DesignSystemDemo extends StatelessWidget {
  const DesignSystemDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beep Beep Design System'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Demo
            Text(
              'Typography',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Heading Large',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              'Heading Medium',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'Heading Small',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Body Large - The quick brown fox jumps over the lazy dog',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Body Medium - The quick brown fox jumps over the lazy dog',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Body Small - The quick brown fox jumps over the lazy dog',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Buttons Demo
            Text(
              'Buttons',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppButton(
              text: 'Primary Button',
              type: AppButtonType.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppButton(
              text: 'Secondary Button',
              type: AppButtonType.secondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppButton(
              text: 'Outline Button',
              type: AppButtonType.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppButton(
              text: 'Text Button',
              type: AppButtonType.text,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppButton(
              text: 'Loading Button',
              type: AppButtonType.primary,
              isLoading: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Text Fields Demo
            Text(
              'Text Fields',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Password',
              hint: 'Enter your password',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Disabled Field',
              hint: 'This field is disabled',
              enabled: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Cards Demo
            Text(
              'Cards',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This is a sample card demonstrating the design system card component with subtle elevation and rounded corners.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              onTap: () {
                // Handle tap
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clickable Card',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'This card can be tapped',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
