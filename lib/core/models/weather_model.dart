import 'dart:convert';
import 'package:intl/intl.dart';

/// Comprehensive weather model for agricultural applications
/// Supports both WeatherAPI.com and OpenWeatherMap API responses
class WeatherModel {
  final String cityName;
  final String countryCode;
  final String region;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double windDirection;
  final int pressure;
  final String description;
  final String mainCondition;
  final String iconCode;
  final DateTime dateTime;
  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final double? uvIndex;
  final double? dewPoint;
  final int cloudiness;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final int? timezoneOffset;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? rainVolume1h;
  final double? rainVolume3h;
  final double? snowVolume1h;
  final double? snowVolume3h;
  final double? windGust;
  final int? airQualityIndex;
  final double? co;
  final double? no2;
  final double? o3;
  final double? so2;
  final double? pm2_5;
  final double? pm10;
  final bool isDay;
  final double? precipitationMm;
  final double? precipitationChance;
  final String? windDirection16Point;

  const WeatherModel({
    required this.cityName,
    required this.countryCode,
    this.region = '',
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.description,
    required this.mainCondition,
    required this.iconCode,
    required this.dateTime,
    this.tempMin,
    this.tempMax,
    this.visibility,
    this.uvIndex,
    this.dewPoint,
    this.cloudiness = 0,
    this.latitude,
    this.longitude,
    this.timezone,
    this.timezoneOffset,
    this.sunrise,
    this.sunset,
    this.rainVolume1h,
    this.rainVolume3h,
    this.snowVolume1h,
    this.snowVolume3h,
    this.windGust,
    this.airQualityIndex,
    this.co,
    this.no2,
    this.o3,
    this.so2,
    this.pm2_5,
    this.pm10,
    this.isDay = true,
    this.precipitationMm,
    this.precipitationChance,
    this.windDirection16Point,
  });

  /// Factory constructor from WeatherAPI.com current weather response
  factory WeatherModel.fromWeatherApiJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;
    final airQuality = current['air_quality'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: location['name'] as String? ?? 'Unknown',
      countryCode: location['country'] as String? ?? 'Unknown',
      region: location['region'] as String? ?? '',
      temperature: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (current['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      humidity: current['humidity'] as int? ?? 0,
      windSpeed: (current['wind_kph'] as num?)?.toDouble() ?? 0.0,
      windDirection: (current['wind_degree'] as num?)?.toDouble() ?? 0.0,
      pressure: (current['pressure_mb'] as num?)?.toInt() ?? 0,
      description: condition['text'] as String? ?? 'Unknown',
      mainCondition: condition['text'] as String? ?? 'Unknown',
      iconCode: condition['icon'] as String? ?? '',
      dateTime: DateTime.parse(current['last_updated'] as String? ??
          DateTime.now().toIso8601String()),
      visibility:
          ((current['vis_km'] as num?)?.toDouble() ?? 0.0 * 1000).toInt(),
      uvIndex: (current['uv'] as num?)?.toDouble(),
      dewPoint: (current['dewpoint_c'] as num?)?.toDouble(),
      cloudiness: current['cloud'] as int? ?? 0,
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lon'] as num?)?.toDouble(),
      timezone: location['tz_id'] as String?,
      windGust: (current['gust_kph'] as num?)?.toDouble(),
      airQualityIndex: (airQuality['us-epa-index'] as num?)?.toInt(),
      co: (airQuality['co'] as num?)?.toDouble(),
      no2: (airQuality['no2'] as num?)?.toDouble(),
      o3: (airQuality['o3'] as num?)?.toDouble(),
      so2: (airQuality['so2'] as num?)?.toDouble(),
      pm2_5: (airQuality['pm2_5'] as num?)?.toDouble(),
      pm10: (airQuality['pm10'] as num?)?.toDouble(),
      isDay: (current['is_day'] as int? ?? 1) == 1,
      precipitationMm: (current['precip_mm'] as num?)?.toDouble(),
      windDirection16Point: current['wind_dir'] as String?,
    );
  }

  /// Factory constructor from WeatherAPI.com forecast response
  factory WeatherModel.fromWeatherApiForecastJson(
      Map<String, dynamic> dayData, Map<String, dynamic> location) {
    final day = dayData['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;
    final astro = dayData['astro'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: location['name'] as String? ?? 'Unknown',
      countryCode: location['country'] as String? ?? 'Unknown',
      region: location['region'] as String? ?? '',
      temperature: (day['avgtemp_c'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (day['avgtemp_c'] as num?)?.toDouble() ?? 0.0,
      humidity: (day['avghumidity'] as num?)?.toInt() ?? 0,
      windSpeed: (day['maxwind_kph'] as num?)?.toDouble() ?? 0.0,
      windDirection: 0.0,
      pressure: 1013, // Default as not provided in forecast
      description: condition['text'] as String? ?? 'Unknown',
      mainCondition: condition['text'] as String? ?? 'Unknown',
      iconCode: condition['icon'] as String? ?? '',
      dateTime: DateTime.parse(
          dayData['date'] as String? ?? DateTime.now().toIso8601String()),
      tempMin: (day['mintemp_c'] as num?)?.toDouble(),
      tempMax: (day['maxtemp_c'] as num?)?.toDouble(),
      uvIndex: (day['uv'] as num?)?.toDouble(),
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lon'] as num?)?.toDouble(),
      timezone: location['tz_id'] as String?,
      precipitationMm: (day['totalprecip_mm'] as num?)?.toDouble(),
      precipitationChance: (day['daily_chance_of_rain'] as num?)?.toDouble(),
      sunrise: _parseTime(astro['sunrise'] as String?),
      sunset: _parseTime(astro['sunset'] as String?),
      visibility:
          ((day['avgvis_km'] as num?)?.toDouble() ?? 0.0 * 1000).toInt(),
    );
  }

  /// Factory constructor from WeatherAPI.com hourly forecast response
  factory WeatherModel.fromWeatherApiHourlyJson(
    Map<String, dynamic> hourData,
    Map<String, dynamic> location,
    String date,
  ) {
    final condition = hourData['condition'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: location['name'] as String? ?? 'Unknown',
      countryCode: location['country'] as String? ?? 'Unknown',
      region: location['region'] as String? ?? '',
      temperature: (hourData['temp_c'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (hourData['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      humidity: hourData['humidity'] as int? ?? 0,
      windSpeed: (hourData['wind_kph'] as num?)?.toDouble() ?? 0.0,
      windDirection: (hourData['wind_degree'] as num?)?.toDouble() ?? 0.0,
      pressure: (hourData['pressure_mb'] as num?)?.toInt() ?? 0,
      description: condition['text'] as String? ?? 'Unknown',
      mainCondition: condition['text'] as String? ?? 'Unknown',
      iconCode: condition['icon'] as String? ?? '',
      dateTime: DateTime.parse(
          hourData['time'] as String? ?? DateTime.now().toIso8601String()),
      visibility:
          ((hourData['vis_km'] as num?)?.toDouble() ?? 0.0 * 1000).toInt(),
      uvIndex: (hourData['uv'] as num?)?.toDouble(),
      dewPoint: (hourData['dewpoint_c'] as num?)?.toDouble(),
      cloudiness: hourData['cloud'] as int? ?? 0,
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lon'] as num?)?.toDouble(),
      timezone: location['tz_id'] as String?,
      windGust: (hourData['gust_kph'] as num?)?.toDouble(),
      isDay: (hourData['is_day'] as int? ?? 1) == 1,
      precipitationMm: (hourData['precip_mm'] as num?)?.toDouble(),
      precipitationChance: (hourData['chance_of_rain'] as num?)?.toDouble(),
      windDirection16Point: hourData['wind_dir'] as String?,
    );
  }

  /// Factory constructor from OpenWeatherMap API response (for backward compatibility)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final coord = json['coord'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      countryCode: sys['country'] as String? ?? 'Unknown',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (wind['deg'] as num?)?.toDouble() ?? 0.0,
      pressure: main['pressure'] as int? ?? 0,
      description: weather['description'] as String? ?? 'Unknown',
      mainCondition: weather['main'] as String? ?? 'Unknown',
      iconCode: weather['icon'] as String? ?? '01d',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int? ?? 0) * 1000,
      ),
      tempMin: (main['temp_min'] as num?)?.toDouble(),
      tempMax: (main['temp_max'] as num?)?.toDouble(),
      visibility: json['visibility'] as int?,
      uvIndex: (json['uvi'] as num?)?.toDouble(),
      dewPoint: (main['dew_point'] as num?)?.toDouble(),
      cloudiness:
          (json['clouds'] as Map<String, dynamic>?)?['all'] as int? ?? 0,
      latitude: (coord['lat'] as num?)?.toDouble(),
      longitude: (coord['lon'] as num?)?.toDouble(),
      sunrise: sys['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch((sys['sunrise'] as int) * 1000)
          : null,
      sunset: sys['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch((sys['sunset'] as int) * 1000)
          : null,
      windGust: (wind['gust'] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON for caching and storage
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'countryCode': countryCode,
      'region': region,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'description': description,
      'mainCondition': mainCondition,
      'iconCode': iconCode,
      'dateTime': dateTime.toIso8601String(),
      'tempMin': tempMin,
      'tempMax': tempMax,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'dewPoint': dewPoint,
      'cloudiness': cloudiness,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'timezoneOffset': timezoneOffset,
      'sunrise': sunrise?.toIso8601String(),
      'sunset': sunset?.toIso8601String(),
      'rainVolume1h': rainVolume1h,
      'rainVolume3h': rainVolume3h,
      'snowVolume1h': snowVolume1h,
      'snowVolume3h': snowVolume3h,
      'windGust': windGust,
      'airQualityIndex': airQualityIndex,
      'co': co,
      'no2': no2,
      'o3': o3,
      'so2': so2,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'isDay': isDay,
      'precipitationMm': precipitationMm,
      'precipitationChance': precipitationChance,
      'windDirection16Point': windDirection16Point,
    };
  }

  /// WeatherAPI.com icon URL
  String get iconUrl =>
      iconCode.startsWith('http') ? iconCode : 'https:$iconCode';

  /// Small icon URL for compact displays
  String get smallIconUrl => iconUrl.replaceAll('64x64', '32x32');

  /// Large icon URL for detailed displays
  String get largeIconUrl => iconUrl.replaceAll('64x64', '128x128');

  /// Temperature in Celsius with degree symbol
  String get temperatureString => '${temperature.round()}°C';

  /// Temperature in Fahrenheit
  String get temperatureFahrenheit => '${(temperature * 9 / 5 + 32).round()}°F';

  /// Temperature range string
  String get temperatureRangeString {
    if (tempMin != null && tempMax != null) {
      return '${tempMin!.round()}° / ${tempMax!.round()}°C';
    }
    return temperatureString;
  }

  /// Feels like temperature with label
  String get feelsLikeString => 'Feels like ${feelsLike.round()}°C';

  /// Wind speed in km/h
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} km/h';

  /// Wind speed in m/s
  String get windSpeedMs => '${(windSpeed / 3.6).toStringAsFixed(1)} m/s';

  /// Wind direction in cardinal directions
  String get windDirectionCardinal {
    if (windDirection16Point != null) return windDirection16Point!;

    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    final index = ((windDirection + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Humidity percentage
  String get humidityString => '$humidity%';

  /// Atmospheric pressure
  String get pressureString => '$pressure mb';

  /// Visibility in kilometers
  String get visibilityString => visibility != null
      ? '${(visibility! / 1000).toStringAsFixed(1)} km'
      : 'N/A';

  /// UV Index with description
  String get uvIndexString {
    if (uvIndex == null) return 'N/A';
    final uv = uvIndex!;
    String level;
    if (uv <= 2)
      level = 'Low';
    else if (uv <= 5)
      level = 'Moderate';
    else if (uv <= 7)
      level = 'High';
    else if (uv <= 10)
      level = 'Very High';
    else
      level = 'Extreme';
    return '${uv.toStringAsFixed(1)} ($level)';
  }

  /// Cloudiness percentage
  String get cloudinessString => '$cloudiness%';

  /// Dew point temperature
  String get dewPointString =>
      dewPoint != null ? '${dewPoint!.toStringAsFixed(1)}°C' : 'N/A';

  /// Precipitation amount
  String get precipitationString => precipitationMm != null
      ? '${precipitationMm!.toStringAsFixed(1)} mm'
      : '0 mm';

  /// Precipitation chance
  String get precipitationChanceString => precipitationChance != null
      ? '${precipitationChance!.toStringAsFixed(0)}%'
      : '0%';

  /// Air quality description
  String get airQualityString {
    if (airQualityIndex == null) return 'N/A';
    switch (airQualityIndex!) {
      case 1:
        return 'Good';
      case 2:
        return 'Moderate';
      case 3:
        return 'Unhealthy for Sensitive Groups';
      case 4:
        return 'Unhealthy';
      case 5:
        return 'Very Unhealthy';
      case 6:
        return 'Hazardous';
      default:
        return 'Unknown';
    }
  }

  /// Formatted date and time
  String get formattedDateTime =>
      DateFormat('MMM dd, yyyy HH:mm').format(dateTime);

  /// Formatted date only
  String get formattedDate => DateFormat('MMM dd, yyyy').format(dateTime);

  /// Formatted time only
  String get formattedTime => DateFormat('HH:mm').format(dateTime);

  /// Day of week
  String get dayOfWeek => DateFormat('EEEE').format(dateTime);

  /// Short day of week
  String get shortDayOfWeek => DateFormat('EEE').format(dateTime);

  /// Sunrise time formatted
  String get sunriseString =>
      sunrise != null ? DateFormat('HH:mm').format(sunrise!) : 'N/A';

  /// Sunset time formatted
  String get sunsetString =>
      sunset != null ? DateFormat('HH:mm').format(sunset!) : 'N/A';

  /// Check if weather conditions are favorable for farming activities
  bool get isFavorableForFarming {
    return temperature >= 10 &&
        temperature <= 35 &&
        humidity >= 30 &&
        humidity <= 85 &&
        windSpeed < 25 &&
        !isExtremePrecipitation;
  }

  /// Check for extreme precipitation
  bool get isExtremePrecipitation {
    return (precipitationMm != null && precipitationMm! > 25) ||
        (rainVolume1h != null && rainVolume1h! > 10) ||
        (rainVolume3h != null && rainVolume3h! > 20);
  }

  /// Check if it's currently raining
  bool get isRaining =>
      mainCondition.toLowerCase().contains('rain') ||
      (precipitationMm != null && precipitationMm! > 0);

  /// Check if it's currently snowing
  bool get isSnowing =>
      mainCondition.toLowerCase().contains('snow') ||
      (snowVolume1h != null && snowVolume1h! > 0);

  /// Check if conditions are stormy
  bool get isStormy =>
      mainCondition.toLowerCase().contains('storm') ||
      mainCondition.toLowerCase().contains('thunder');

  /// Check if it's clear/sunny
  bool get isClear =>
      mainCondition.toLowerCase().contains('clear') ||
      mainCondition.toLowerCase().contains('sunny');

  /// Check if it's cloudy
  bool get isCloudy =>
      mainCondition.toLowerCase().contains('cloud') || cloudiness > 50;

  /// Get farming advice based on current weather conditions
  String get farmingAdvice {
    List<String> advice = [];

    // Temperature advice
    if (temperature < 0) {
      advice.add(
          '🥶 Freezing temperatures! Protect all crops from frost damage.');
    } else if (temperature < 5) {
      advice.add(
          '❄️ Very cold conditions. Protect crops from frost and consider greenhouse farming.');
    } else if (temperature < 10) {
      advice.add(
          '🌡️ Cold weather. Monitor for frost damage and delay planting of sensitive crops.');
    } else if (temperature > 45) {
      advice.add(
          '🔥 Extreme heat! Provide shade and increase irrigation significantly.');
    } else if (temperature > 40) {
      advice.add(
          '☀️ Extreme heat. Ensure adequate irrigation and avoid midday field work.');
    } else if (temperature > 35) {
      advice.add(
          '🌡️ Very hot. Increase irrigation frequency and monitor plants for heat stress.');
    } else if (temperature >= 20 && temperature <= 30) {
      advice
          .add('✅ Optimal temperature range for most agricultural activities.');
    }

    // Humidity advice
    if (humidity < 20) {
      advice.add(
          '🏜️ Very low humidity. Increase irrigation significantly and consider mulching.');
    } else if (humidity < 30) {
      advice.add(
          '🌵 Low humidity. Monitor soil moisture and irrigate as needed.');
    } else if (humidity > 90) {
      advice.add(
          '💧 Very high humidity. High disease risk! Ensure excellent ventilation.');
    } else if (humidity > 80) {
      advice.add(
          '💨 High humidity increases disease risk. Monitor for fungal issues.');
    }

    // Wind advice
    if (windGust != null && windGust! > 50) {
      advice.add(
          '🌪️ Dangerous wind gusts! Secure all structures and protect plants.');
    } else if (windSpeed > 25) {
      advice.add(
          '💨 Strong winds. Secure structures and avoid pesticide applications.');
    } else if (windSpeed > 15) {
      advice.add(
          '🌬️ Moderate winds may increase evaporation. Consider additional irrigation.');
    }

    // UV advice
    if (uvIndex != null && uvIndex! > 10) {
      advice.add('☀️ Extreme UV levels. Provide shade for sensitive crops.');
    } else if (uvIndex != null && uvIndex! > 8) {
      advice.add(
          '🕶️ High UV levels. Protect workers from prolonged sun exposure.');
    }

    // Precipitation advice
    if (isExtremePrecipitation) {
      advice.add(
          '🌧️ Heavy precipitation. Avoid field operations and monitor for waterlogging.');
    } else if (isRaining) {
      advice.add(
          '🌦️ Light to moderate precipitation. Good for irrigation but avoid machinery use.');
    }

    // Weather condition specific advice
    if (isStormy) {
      advice.add('⛈️ Thunderstorms. Secure equipment and avoid outdoor work.');
    } else if (isSnowing) {
      advice.add(
          '❄️ Snow conditions. Protect crops and ensure adequate shelter.');
    } else if (isClear) {
      advice.add(
          '☀️ Clear skies are ideal for photosynthesis and field activities.');
    }

    // Air quality advice
    if (airQualityIndex != null && airQualityIndex! > 3) {
      advice.add('😷 Poor air quality. Limit outdoor exposure for workers.');
    }

    return advice.isNotEmpty
        ? advice.join('\n\n')
        : '✅ Weather conditions are generally suitable for normal farming activities.';
  }

  /// Get irrigation recommendation
  String get irrigationAdvice {
    if (isRaining && precipitationMm != null && precipitationMm! > 5) {
      return '💧 Sufficient natural precipitation. Skip scheduled irrigation.';
    }

    if (temperature > 35 && humidity < 50) {
      return '🌡️ Hot and dry conditions. Increase irrigation frequency by 50%.';
    }

    if (windSpeed > 15) {
      return '💨 Windy conditions increase evaporation. Consider additional watering.';
    }

    if (uvIndex != null && uvIndex! > 8) {
      return '☀️ High UV levels increase plant stress. Ensure adequate soil moisture.';
    }

    return '💧 Maintain regular irrigation schedule based on soil moisture.';
  }

  /// Get pest and disease risk assessment
  String get pestDiseaseRisk {
    List<String> risks = [];

    if (humidity > 85 && temperature > 20 && temperature < 30) {
      risks.add('🦠 High fungal disease risk due to warm, humid conditions');
    }

    if (temperature > 28 && humidity < 60) {
      risks.add('🐛 Increased insect pest activity in warm, dry conditions');
    }

    if (isRaining && temperature > 18) {
      risks.add('🍄 Monitor for bacterial and fungal infections after rain');
    }

    if (windSpeed > 20) {
      risks.add('🌪️ Strong winds may spread airborne diseases and pests');
    }

    return risks.isNotEmpty
        ? risks.join('\n')
        : '✅ Low to moderate pest and disease risk';
  }

  /// Create a copy with updated values
  WeatherModel copyWith({
    String? cityName,
    String? countryCode,
    String? region,
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    double? windDirection,
    int? pressure,
    String? description,
    String? mainCondition,
    String? iconCode,
    DateTime? dateTime,
    double? tempMin,
    double? tempMax,
    int? visibility,
    double? uvIndex,
    double? dewPoint,
    int? cloudiness,
    double? latitude,
    double? longitude,
    String? timezone,
    int? timezoneOffset,
    DateTime? sunrise,
    DateTime? sunset,
    double? rainVolume1h,
    double? rainVolume3h,
    double? snowVolume1h,
    double? snowVolume3h,
    double? windGust,
    int? airQualityIndex,
    double? co,
    double? no2,
    double? o3,
    double? so2,
    double? pm2_5,
    double? pm10,
    bool? isDay,
    double? precipitationMm,
    double? precipitationChance,
    String? windDirection16Point,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      countryCode: countryCode ?? this.countryCode,
      region: region ?? this.region,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      description: description ?? this.description,
      mainCondition: mainCondition ?? this.mainCondition,
      iconCode: iconCode ?? this.iconCode,
      dateTime: dateTime ?? this.dateTime,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      dewPoint: dewPoint ?? this.dewPoint,
      cloudiness: cloudiness ?? this.cloudiness,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      rainVolume1h: rainVolume1h ?? this.rainVolume1h,
      rainVolume3h: rainVolume3h ?? this.rainVolume3h,
      snowVolume1h: snowVolume1h ?? this.snowVolume1h,
      snowVolume3h: snowVolume3h ?? this.snowVolume3h,
      windGust: windGust ?? this.windGust,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      co: co ?? this.co,
      no2: no2 ?? this.no2,
      o3: o3 ?? this.o3,
      so2: so2 ?? this.so2,
      pm2_5: pm2_5 ?? this.pm2_5,
      pm10: pm10 ?? this.pm10,
      isDay: isDay ?? this.isDay,
      precipitationMm: precipitationMm ?? this.precipitationMm,
      precipitationChance: precipitationChance ?? this.precipitationChance,
      windDirection16Point: windDirection16Point ?? this.windDirection16Point,
    );
  }

  @override
  String toString() {
    return 'WeatherModel(cityName: $cityName, temperature: $temperatureString, condition: $mainCondition, humidity: $humidityString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherModel &&
        other.cityName == cityName &&
        other.temperature == temperature &&
        other.dateTime == dateTime &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      cityName,
      temperature,
      dateTime,
      latitude,
      longitude,
    );
  }

  /// Helper method to parse time strings from WeatherAPI.com
  static DateTime? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      // Parse time format like "07:05 AM"
      final format = DateFormat('hh:mm a');
      final time = format.parse(timeString);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } catch (e) {
      return null;
    }
  }
}

/// Extension for weather condition categorization
extension WeatherConditionExtension on WeatherModel {
  /// Categorize weather conditions for farming
  WeatherConditionCategory get farmingCategory {
    if (isStormy) return WeatherConditionCategory.severe;
    if (isExtremePrecipitation) return WeatherConditionCategory.challenging;
    if (temperature < 0 || temperature > 45)
      return WeatherConditionCategory.severe;
    if (temperature < 5 || temperature > 40)
      return WeatherConditionCategory.challenging;
    if (windSpeed > 30) return WeatherConditionCategory.severe;
    if (windSpeed > 20) return WeatherConditionCategory.challenging;
    if (isClear && temperature >= 15 && temperature <= 35)
      return WeatherConditionCategory.ideal;
    if (humidity > 90 || humidity < 20)
      return WeatherConditionCategory.challenging;
    if (isCloudy && !isRaining) return WeatherConditionCategory.good;
    return WeatherConditionCategory.moderate;
  }
}

/// Weather condition categories for agricultural activities
enum WeatherConditionCategory {
  ideal,
  good,
  moderate,
  challenging,
  severe,
}
