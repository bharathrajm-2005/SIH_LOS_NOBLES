import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';
import '../core/constants/app_constants.dart';

class QuickTipsCard extends StatefulWidget {
  const QuickTipsCard({super.key});

  @override
  State<QuickTipsCard> createState() => _QuickTipsCardState();
}

class _QuickTipsCardState extends State<QuickTipsCard> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<QuickTip> _tips = [
    QuickTip(
      icon: Icons.water_drop,
      title: 'Smart Irrigation',
      description:
          'Water your crops early morning or late evening to reduce evaporation and save water.',
      color: AppColors.infoColor,
    ),
    QuickTip(
      icon: Icons.bug_report,
      title: 'Pest Prevention',
      description:
          'Regular inspection and early detection can prevent major pest infestations.',
      color: AppColors.warningColor,
    ),
    QuickTip(
      icon: Icons.eco,
      title: 'Soil Health',
      description:
          'Rotate crops seasonally to maintain soil fertility and prevent nutrient depletion.',
      color: AppColors.successColor,
    ),
    QuickTip(
      icon: Icons.thermostat,
      title: 'Weather Monitoring',
      description:
          'Check weather forecasts regularly to plan your farming activities effectively.',
      color: AppColors.primaryColor,
    ),
    QuickTip(
      icon: Icons.schedule,
      title: 'Timing is Key',
      description:
          'Plant seeds at the right time according to your local climate and season patterns.',
      color: AppColors.accentColor,
    ),
    QuickTip(
      icon: Icons.psychology,
      title: 'Smart Farming',
      description:
          'Use technology and AI assistance to make data-driven farming decisions.',
      color: AppColors.primaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_currentIndex + 1}/${_tips.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  final tip = _tips[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tip.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tip.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tip.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            tip.icon,
                            color: tip.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tip.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tips.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: AppConstants.shortAnimationDuration,
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.shortAnimationDuration,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class QuickTip {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const QuickTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
