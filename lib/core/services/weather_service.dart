import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '471c40da64334faa95384058251309';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  /// Test the weather API connection
  Future<bool> testConnection() async {
    try {
      print('🌤️ Testing Weather API connection...');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=London'),
          )
          .timeout(const Duration(seconds: 10));

      print('Weather API Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Weather API test failed: $e');
      return false;
    }
  }

  /// Get current weather by city name
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      print('🌍 Getting weather for: $cityName');

      final url = '$_baseUrl/current.json?key=$_apiKey&q=$cityName&aqi=yes';
      print('📡 Weather URL: $url');

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 15),
          );

      print('📊 Weather Response: ${response.statusCode}');
      print('📄 Weather Data: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = WeatherModel.fromWeatherApiJson(data);
        print('✅ Weather loaded successfully');
        return weather;
      } else {
        throw Exception(
            'Weather API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Weather error: $e');
      throw Exception('Failed to get weather: $e');
    }
  }

  /// Get current weather by coordinates
  Future<WeatherModel> getCurrentWeatherByCoords(
      double latitude, double longitude) async {
    try {
      print('📍 Getting weather for: $latitude, $longitude');

      final url =
          '$_baseUrl/current.json?key=$_apiKey&q=$latitude,$longitude&aqi=yes';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromWeatherApiJson(data);
      } else {
        throw Exception('Weather API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get weather by coordinates: $e');
    }
  }

  /// Get weather forecast
  Future<List<WeatherModel>> getWeatherForecast({
    String? cityName,
    double? latitude,
    double? longitude,
    int days = 5,
  }) async {
    try {
      String location;
      if (cityName != null) {
        location = cityName;
      } else if (latitude != null && longitude != null) {
        location = '$latitude,$longitude';
      } else {
        throw Exception('Either city name or coordinates must be provided');
      }

      final url =
          '$_baseUrl/forecast.json?key=$_apiKey&q=$location&days=$days&aqi=yes&alerts=yes';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastDays = data['forecast']['forecastday'];

        return forecastDays.map((dayData) {
          return WeatherModel.fromWeatherApiForecastJson(
              dayData, data['location']);
        }).toList();
      } else {
        throw Exception('Forecast API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get weather forecast: $e');
    }
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    try {
      print('📍 Getting current location...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Location found: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Location error: $e');
      throw Exception('Failed to get location: $e');
    }
  }

  /// Get weather by device location
  Future<WeatherModel> getWeatherByLocation() async {
    try {
      final position = await getCurrentLocation();
      return await getCurrentWeatherByCoords(
          position.latitude, position.longitude);
    } catch (e) {
      print('⚠️ Location weather failed, trying default location...');
      // Fallback to Delhi if location fails
      return await getCurrentWeatherByCity('Delhi');
    }
  }
}
