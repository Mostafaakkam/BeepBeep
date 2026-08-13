import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Centralized branding widget for Beep Beep
/// 
/// This widget provides a consistent branding element that can be easily
/// replaced with the final ostrich logo when provided.
/// 
/// Currently uses a temporary placeholder icon, but is structured
/// to support image assets, custom illustrations, or animations.
class BrandLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool showBackground;
  
  const BrandLogo({
    super.key,
    this.size = 100,
    this.backgroundColor,
    this.showBackground = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(size * 0.2),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
              blurRadius: size * 0.2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildLogoContent(),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: _buildLogoContent(),
      );
    }
  }
  
  Widget _buildLogoContent() {
    // TODO: Replace with final ostrich logo when provided
    // Future implementations may include:
    // - Custom ostrich illustration
    // - SVG assets
    // - Animated mascot
    // - Custom widget for ostrich character
    
    return Icon(
      Icons.blur_circular, // Neutral placeholder - not a store/shopping icon
      size: size * 0.5,
      color: AppColors.white,
    );
  }
}

/// Branding constants and configuration
class BrandConfig {
  // TODO: Replace with actual brand assets when provided
  static const String logoAssetPath = ''; // Future: 'assets/images/ostrich_logo.png'
  static const String mascotAssetPath = ''; // Future: 'assets/images/ostrich_mascot.png'
  
  // Current placeholder configuration
  static const double defaultLogoSize = 100.0;
  static const double smallLogoSize = 60.0;
  static const double largeLogoSize = 120.0;
}
