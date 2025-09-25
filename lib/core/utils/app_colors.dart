import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Earth Green (representing fertile soil)
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF1B5E20);

  // Secondary Colors - Fresh Green (representing healthy crops)
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Accent Colors - Bright Green (representing growth)
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color accentLight = Color(0xFFAED581);
  static const Color accentDark = Color(0xFF689F38);

  // Farmer-friendly colors
  static const Color soilBrown = Color(0xFF8D6E63);
  static const Color wheatGold = Color(0xFFFFB74D);
  static const Color skyBlue = Color(0xFF64B5F6);
  static const Color sunYellow = Color(0xFFFFC107);
  static const Color leafGreen = Color(0xFF66BB6A);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Weather Colors
  static const Color sunnyColor = Color(0xFFFFB300);
  static const Color cloudyColor = Color(0xFF78909C);
  static const Color rainyColor = Color(0xFF1976D2);
  static const Color stormyColor = Color(0xFF424242);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFAFAFA)],
  );

  // Farmer-themed gradients
  static const LinearGradient farmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue, leafGreen],
  );

  static const LinearGradient soilGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [soilBrown, Color(0xFFA1887F)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [wheatGold, sunYellow],
  );

  static const LinearGradient cropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentLight, secondaryColor],
  );

  // Material Color Swatch for Theme
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color lightShadowColor = Color(0x0A000000);

  // Crop Type Colors
  static const Map<String, Color> cropTypeColors = {
    'Cereals': Color(0xFFFFB74D),
    'Pulses': Color(0xFF81C784),
    'Oilseeds': Color(0xFFF06292),
    'Vegetables': Color(0xFF4CAF50),
    'Fruits': Color(0xFFFF8A65),
    'Spices': Color(0xFFAED581),
    'Cash Crops': Color(0xFF64B5F6),
    'Fodder Crops': Color(0xFF9575CD),
  };

  // Severity Colors for Pest Detection
  static const Map<String, Color> severityColors = {
    'Low': successColor,
    'Medium': warningColor,
    'High': errorColor,
    'Critical': Color(0xFFD32F2F),
  };

  // Helper Methods
  static Color getShade(Color color, int shade) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (shade / 900).clamp(0.1, 0.9);
    return hsl.withLightness(lightness).toColor();
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0)) ?? color1;
  }
}
