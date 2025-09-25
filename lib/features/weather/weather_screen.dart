import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/services/weather_service.dart';
import '../../core/models/weather_model.dart';
import '../../test_weather.dart'; // Add this import

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherModel? _currentWeather;
  List<WeatherModel> _forecast = [];
  bool _isLoading = false;
  String? _error;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _testWeatherAPI() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final result = await WeatherAPITest.testWeatherAPI();
      setState(() {
        _testResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weatherService =
          Provider.of<WeatherService>(context, listen: false);

      // Test connection first
      final isConnected = await weatherService.testConnection();
      if (!isConnected) {
        throw Exception('Weather service is not available');
      }

      // Try to get weather by location first
      try {
        final weather = await weatherService.getWeatherByLocation();
        final forecast = await weatherService.getWeatherForecast(
          cityName: weather.cityName,
          days: 5,
        );

        setState(() {
          _currentWeather = weather;
          _forecast = forecast;
          _isLoading = false;
        });
      } catch (locationError) {
        print('Location weather failed, trying Delhi: $locationError');
        // Fallback to Delhi
        final weather = await weatherService.getCurrentWeatherByCity('Delhi');
        final forecast = await weatherService.getWeatherForecast(
          cityName: 'Delhi',
          days: 5,
        );

        setState(() {
          _currentWeather = weather;
          _forecast = forecast;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Debug test button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testWeatherAPI,
            tooltip: 'Test Weather API',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Result (for debugging)
              if (_testResult != null) ...[
                Card(
                  color: _testResult!.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'API Test Result:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_testResult!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Error message
              if (_error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Weather Error',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_error!),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadWeather,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Current Weather
              if (_currentWeather != null) ...[
                _buildCurrentWeatherCard(_currentWeather!),
                const SizedBox(height: 16),
              ],

              // Weather Forecast
              if (_forecast.isNotEmpty) ...[
                const Text(
                  '5-Day Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._forecast.map((weather) => _buildForecastCard(weather)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherModel weather) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.countryCode,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      weather.temperatureString,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail('Feels Like', weather.feelsLikeString),
                _buildWeatherDetail('Humidity', weather.humidityString),
                _buildWeatherDetail('Wind', weather.windSpeedString),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(WeatherModel weather) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          weather.formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        title: Text(weather.description),
        trailing: Text(
          weather.temperatureRangeString,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
