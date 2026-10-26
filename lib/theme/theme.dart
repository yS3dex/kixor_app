import 'package:flutter/material.dart';

/// Paleta de cores oficial do KIXOR — Dark Mode Premium.
class AppColors {
  AppColors._();

  // Fundos e Superfícies
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1A1A1C);
  static const Color surfaceElevated = Color(0xFF232325);
  static const Color inputFill = Color(0xFF141416);
  static const Color border = Color(0xFF2A2A2D);

  // Gradiente oficial da marca: Roxo Escuro/Magenta -> Laranja Vivo -> Amarelo Dourado
  static const Color gradientStart = Color(0xFF7B1FA2);
  static const Color gradientMid = Color(0xFFFF6B00);
  static const Color gradientEnd = Color(0xFFFFD200);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAEAEB4);
  static const Color textMuted = Color(0xFF7A7A80);

  static const Color liveRed = Color(0xFFFF3B30);
  static const Color upcomingBlue = Color(0xFF2F80ED);
  static const Color winnerGreen = Color(0xFF34C759);
}

class AppGradients {
  AppGradients._();

  static const List<Color> _stops = [
    AppColors.gradientStart,
    AppColors.gradientMid,
    AppColors.gradientEnd,
  ];

  static const LinearGradient primary = LinearGradient(
    colors: _stops,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryDiagonal = LinearGradient(
    colors: _stops,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tag = LinearGradient(
    colors: [AppColors.gradientStart, Color(0xFFE91E8C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Shader textShader(Rect bounds) => primary.createShader(bounds);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle brandTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle slogan = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: AppColors.textSecondary,
  );
}

/// Configuração do ThemeData do Flutter.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gradientMid,
        secondary: AppColors.gradientStart,
        surface: AppColors.surface,
        error: AppColors.liveRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.gradientMid,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
