import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';
import '../core/constants/app_constants.dart';

class DetectionResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const DetectionResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final identification = result['identification'] as String? ?? 'Unknown';
    final severity = result['severity'] as String? ?? 'Medium';
    final treatment =
        result['treatment'] as String? ?? 'No treatment specified';
    final prevention =
        result['prevention'] as String? ?? 'No prevention specified';

    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Analysis Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Identification
            _buildSection(
              'Identification',
              identification,
              Icons.search,
              AppColors.primaryColor,
            ),

            // Severity
            _buildSection(
              'Severity Level',
              severity,
              Icons.warning,
              _getSeverityColor(severity),
            ),

            // Treatment
            _buildSection(
              'Recommended Treatment',
              treatment,
              Icons.healing,
              AppColors.successColor,
            ),

            // Prevention
            _buildSection(
              'Prevention Measures',
              prevention,
              Icons.shield,
              AppColors.infoColor,
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warningColor,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info,
                    color: AppColors.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is an AI-powered analysis for guidance only. For serious issues, please consult with local agricultural experts or extension services.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.successColor;
      case 'medium':
        return AppColors.warningColor;
      case 'high':
        return AppColors.errorColor;
      case 'critical':
        return const Color(0xFFD32F2F);
      default:
        return AppColors.warningColor;
    }
  }
}
