import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherAPITest {
  static const String apiKey = '471c40da64334faa95384058251309';
  static const String baseUrl = 'https://api.weatherapi.com/v1';

  static Future<String> testWeatherAPI() async {
    try {
      print('🌤️ Testing WeatherAPI.com...');
      print('🔑 API Key: $apiKey');

      // Test with a known location (Delhi)
      final url = '$baseUrl/current.json?key=$apiKey&q=Delhi&aqi=yes';
      print('📡 URL: $url');

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 15),
          );

      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['location']['name'];
        final temp = data['current']['temp_c'];
        final condition = data['current']['condition']['text'];

        final result =
            '✅ Weather API working!\nLocation: $location\nTemperature: ${temp}°C\nCondition: $condition';
        print(result);
        return result;
      } else {
        final error = 'API Error ${response.statusCode}: ${response.body}';
        print('❌ $error');
        return error;
      }
    } catch (e) {
      final error = 'Exception: $e';
      print('💥 $error');
      return error;
    }
  }
}
