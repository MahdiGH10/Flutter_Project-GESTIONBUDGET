import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors from design tokens ──
  static const Color primary900 = Color(0xFF1F2C37);
  static const Color primary800 = Color(0xFF2A3B47);
  static const Color primary700 = Color(0xFF354A56);
  static const Color primary100 = Color(0xFFF7F9FC);
  static const Color primary50 = Color(0xFFFAFBFC);

  static const Color success500 = Color(0xFF4CD964);
  static const Color success400 = Color(0xFF6EE084);
  static const Color success100 = Color(0xFFE8F9EC);
  static const Color success50 = Color(0xFFF3FDF5);

  static const Color danger500 = Color(0xFFFF3B30);
  static const Color danger400 = Color(0xFFFF6B63);
  static const Color danger100 = Color(0xFFFFE8E7);
  static const Color danger50 = Color(0xFFFFF3F2);

  static const Color neutral900 = Color(0xFF1F2C37);
  static const Color neutral700 = Color(0xFF3D4F5F);
  static const Color neutral500 = Color(0xFF78828A);
  static const Color neutral400 = Color(0xFFA5B0B9);
  static const Color neutral300 = Color(0xFFC5CCD2);
  static const Color neutral200 = Color(0xFFE8ECF0);
  static const Color neutral100 = Color(0xFFF7F9FC);
  static const Color neutral0 = Color(0xFFFFFFFF);

  // Category colors
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTransport = Color(0xFF4ECDC4);
  static const Color catShopping = Color(0xFF45B7D1);
  static const Color catEntertainment = Color(0xFF96CEB4);
  static const Color catHealth = Color(0xFFFFEAA7);
  static const Color catHousing = Color(0xFFDDA0DD);
  static const Color catUtilities = Color(0xFF98D8C8);
  static const Color catEducation = Color(0xFFF7DC6F);

  // ── Spacing ──
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;
  static const double spacing3xl = 64;

  // ── Border Radius ──
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusFull = 9999;

  // ── Shadows ──
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 8,
      color: primary900.withOpacity(0.06),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 20,
      color: primary900.withOpacity(0.08),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 30,
      color: primary900.withOpacity(0.12),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      offset: const Offset(0, 25),
      blurRadius: 80,
      color: primary900.withOpacity(0.15),
    ),
  ];

  // ── Typography ──
  static TextStyle get h1Bold => GoogleFonts.urbanist(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.5,
    color: neutral900,
  );

  static TextStyle get h2Bold => GoogleFonts.urbanist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.3,
    color: neutral900,
  );

  static TextStyle get h3SemiBold => GoogleFonts.urbanist(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
    color: neutral900,
  );

  static TextStyle get bodyRegular => GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: neutral900,
  );

  static TextStyle get bodyMedium => GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: neutral900,
  );

  static TextStyle get bodySemiBold => GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: neutral900,
  );

  static TextStyle get captionRegular => GoogleFonts.urbanist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: neutral500,
  );

  static TextStyle get captionMedium => GoogleFonts.urbanist(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: neutral500,
  );

  static TextStyle get smallMedium => GoogleFonts.urbanist(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: neutral500,
  );

  static TextStyle get balanceDisplay => GoogleFonts.urbanist(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 48 / 42,
    letterSpacing: -1,
    color: neutral0,
  );

  static TextStyle get amountLarge => GoogleFonts.urbanist(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -1,
  );

  // ── ThemeData ──
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: neutral100,
    colorScheme: ColorScheme.light(
      primary: primary900,
      secondary: success500,
      error: danger500,
      surface: neutral0,
      onPrimary: neutral0,
      onSecondary: neutral0,
      onError: neutral0,
      onSurface: neutral900,
    ),
    textTheme: GoogleFonts.urbanistTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: neutral0,
      foregroundColor: neutral900,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.urbanist(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: neutral900,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary900,
        foregroundColor: neutral0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary900,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: const BorderSide(color: neutral200, width: 2),
        textStyle: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutral0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: neutral200, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: neutral200, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary900, width: 2),
      ),
      hintStyle: GoogleFonts.urbanist(color: neutral400, fontSize: 16),
      labelStyle: GoogleFonts.urbanist(
        color: neutral500,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: neutral0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: neutral0,
      selectedItemColor: primary900,
      unselectedItemColor: neutral400,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary900,
      foregroundColor: neutral0,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
    ),
  );
}
