import 'package:flutter/material.dart';
import '../core/models/crop_recommendation.dart';
import '../core/utils/app_colors.dart';
import '../core/constants/app_constants.dart';

class RecommendationCard extends StatelessWidget {
  final CropRecommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with crop name and suitability score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.cropName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors
                                    .cropTypeColors[recommendation.cropType]
                                    ?.withOpacity(0.2) ??
                                AppColors.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recommendation.cropType,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cropTypeColors[
                                      recommendation.cropType] ??
                                  AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getSuitabilityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${(recommendation.suitabilityScore * 100).round()}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getSuitabilityColor(),
                              ),
                            ),
                            Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 10,
                                color: _getSuitabilityColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Key information grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.schedule,
                      'Growth Period',
                      '${recommendation.growthPeriod} days',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.trending_up,
                      'Expected Yield',
                      '${recommendation.expectedYield} t/ha',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Market Price',
                      '₹${recommendation.marketPrice}/kg',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Season and soil compatibility
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Season: ${recommendation.season}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.terrain,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Soil: ${recommendation.soilTypes.join(", ")}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Advantages preview
              if (recommendation.advantages.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        recommendation.advantages.take(2).join(", "),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // View details button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getSuitabilityColor() {
    if (recommendation.suitabilityScore >= 0.8) return AppColors.successColor;
    if (recommendation.suitabilityScore >= 0.6) return AppColors.warningColor;
    return AppColors.errorColor;
  }
}
