import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';
import '../core/constants/app_constants.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? badge;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.isEnabled = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shadowColor: AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(12), // Reduced padding from 16 to 12
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                stops: const [0.0, 1.0],
              ),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Main Content - Using Flex to better manage space
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize:
                        MainAxisSize.min, // Important: minimize space usage
                    children: [
                      // Icon Container - Reduced size
                      Container(
                        padding:
                            const EdgeInsets.all(8), // Reduced from 12 to 8
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(12), // Reduced from 16
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.1), // Reduced shadow
                              blurRadius: 4, // Reduced from 8
                              offset: const Offset(0, 1), // Reduced offset
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 24, // Reduced from 32 to 24
                          color: color,
                        ),
                      ),

                      const SizedBox(height: 8), // Reduced from 12

                      // Title - Flexible to prevent overflow
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13, // Reduced from 14
                            fontWeight: FontWeight.bold,
                            color: isEnabled
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 2), // Reduced from 4

                      // Subtitle - Flexible to prevent overflow
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12
                            color: isEnabled
                                ? AppColors.textSecondary
                                : AppColors.textSecondary.withOpacity(0.7),
                            height: 1.1, // Reduced line height
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge (if provided)
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, // Reduced
                        vertical: 1, // Reduced
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor,
                        borderRadius: BorderRadius.circular(6), // Reduced
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9, // Reduced from 10
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Disabled Overlay
                if (!isEnabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ... rest of the classes remain the same but with improved space management
