import 'package:flutter/material.dart';

class AppColors {
  static const Color frostPrimary = Color(0xFF0EA5E9);
  static const Color frostPrimaryDark = Color(0xFF0369A1);
  static const Color frostSecondary = Color(0xFF38BDF8);
  static const Color auroraViolet = Color(0xFF8B5CF6);
  static const Color glacialBlue = Color(0xFF0F172A);
  static const Color iceBackground = Color(0xFFE0F2FE);
  static const Color snowSurface = Color(0xFFF5FBFF);
  static const Color frostedGlass = Color(0xCCFFFFFF);
  static const Color mutedText = Color(0xFF475569);

  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [frostPrimary, frostSecondary, auroraViolet],
  );

  static const LinearGradient iceSheetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFD0EBFF)],
  );

  static const List<BoxShadow> softDropShadow = [
    BoxShadow(color: Color(0x330273B9), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

class WinterTheme {
  static ThemeData build() {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.frostPrimary,
        secondary: AppColors.frostSecondary,
        tertiary: AppColors.auroraViolet,
        surface: AppColors.snowSurface,
        background: AppColors.iceBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.glacialBlue,
      ),
      scaffoldBackgroundColor: AppColors.iceBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.glacialBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.glacialBlue,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.glacialBlue),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.glacialBlue,
        displayColor: AppColors.glacialBlue,
        fontFamily: 'Poppins',
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.frostedGlass,
        elevation: 12,
        selectedItemColor: AppColors.frostPrimary,
        unselectedItemColor: AppColors.mutedText,
        showUnselectedLabels: true,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.snowSurface,
        selectedColor: AppColors.frostPrimary.withOpacity(0.15),
        labelStyle: const TextStyle(color: AppColors.glacialBlue),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.frostPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  static BoxDecoration pageBackground() {
    return const BoxDecoration(gradient: AppColors.iceSheetGradient);
  }

  static BoxDecoration frostedCard() {
    return BoxDecoration(
      color: AppColors.frostedGlass,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppColors.softDropShadow,
      border: Border.all(color: Colors.white.withOpacity(0.4)),
    );
  }
}
