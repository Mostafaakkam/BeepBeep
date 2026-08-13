import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final AuthViewModel _authViewModel = AuthViewModel();
  
  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _checkAuthAndNavigate();
  }
  
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left
      end: const Offset(1.0, 0.0),   // Move to right
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete (most of it)
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Check authentication status
    await _authViewModel.checkAuthStatus();
    
    if (!mounted) return;
    
    // Navigate based on auth state
    _navigateToDestination();
  }
  
  void _navigateToDestination() {
    if (!mounted) return;
    
    Widget destination;
    
    if (_authViewModel.isAuthenticated) {
      destination = const HomePage();
    } else {
      destination = const LoginPage();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _authViewModel.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container
              const BrandLogo(
                size: 120,
                showBackground: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // App name
              Text(
                'Beep Beep',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Tagline
              Text(
                'Your Local Marketplace',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
