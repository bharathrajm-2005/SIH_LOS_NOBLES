import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/weather_model.dart';
import '../core/utils/app_colors.dart';
import '../core/constants/app_constants.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const WeatherCard({
    super.key,
    this.weather,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

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
                const Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    color: AppColors.primaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (error != null)
              _buildErrorState()
            else if (weather != null)
              _buildWeatherContent()
            else
              _buildNoDataState(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      children: [
        Row(
          children: [
            // Weather Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: weather!.iconUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.cloud,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Temperature and Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather!.temperatureString,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    weather!.feelsLikeString,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather!.cityName}, ${weather!.countryCode}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    weather!.description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weather Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherDetail(
              Icons.water_drop,
              'Humidity',
              weather!.humidityString,
            ),
            _buildWeatherDetail(
              Icons.air,
              'Wind',
              weather!.windSpeedString,
            ),
            _buildWeatherDetail(
              Icons.compress,
              'Pressure',
              weather!.pressureString,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Farming Advice
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: weather!.isFavorableForFarming
                ? AppColors.successColor.withOpacity(0.1)
                : AppColors.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: weather!.isFavorableForFarming
                  ? AppColors.successColor
                  : AppColors.warningColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    weather!.isFavorableForFarming
                        ? Icons.check_circle
                        : Icons.warning,
                    color: weather!.isFavorableForFarming
                        ? AppColors.successColor
                        : AppColors.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Farming Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: weather!.isFavorableForFarming
                          ? AppColors.successColor
                          : AppColors.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                weather!.farmingAdvice,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load weather data',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            error ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'No weather data available',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
