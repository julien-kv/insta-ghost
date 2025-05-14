import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // COLORS
  static const Color primaryColor = Color(0xFF405DE6);
  static const Color secondaryColor = Color(0xFFE1306C);
  static const Color accentColor = Color(0xFFF56040);
  
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  
  // NEUTRAL COLORS
  static const Color neutral100 = Color(0xFFFAFAFA);
  static const Color neutral200 = Color(0xFFF5F5F5);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  
  // SPACING
  static const double spaceXXSmall = 4;
  static const double spaceXSmall = 8;
  static const double spaceSmall = 16;
  static const double spaceMedium = 24;
  static const double spaceLarge = 32;
  static const double spaceXLarge = 40;
  static const double spaceXXLarge = 48;
  
  // TYPOGRAPHY
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        textStyle: base.displayLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -1.5,
        ),
      ),
      displayMedium: GoogleFonts.inter(
        textStyle: base.displayMedium!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
      displaySmall: GoogleFonts.inter(
        textStyle: base.displaySmall!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0,
        ),
      ),
      headlineMedium: GoogleFonts.inter(
        textStyle: base.headlineMedium!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.25,
        ),
      ),
      headlineSmall: GoogleFonts.inter(
        textStyle: base.headlineSmall!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.15,
        ),
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.25,
        ),
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 1.25,
        ),
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
      labelSmall: GoogleFonts.inter(
        textStyle: base.labelSmall!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
  
  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      background: Colors.white,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: neutral900),
      titleTextStyle: TextStyle(
        color: neutral900,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      elevation: 0,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutral200,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      hintStyle: const TextStyle(color: neutral500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: neutral600,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
    ),
  );

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      elevation: 0,
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      hintStyle: const TextStyle(color: neutral500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: neutral500,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
    ),
  );
}