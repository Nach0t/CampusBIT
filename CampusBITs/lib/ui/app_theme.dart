import 'package:flutter/material.dart';

/// Paleta de CampusBIT (los celestes de siempre, en un solo lugar).
abstract final class AppColors {
  /// Celeste agua: parte superior del fondo.
  static const celesteAgua = Color(0xFFB0E0E6);

  /// Celeste cielo: parte inferior del fondo y acentos suaves.
  static const celeste = Color(0xFF87CEEB);

  /// Celeste oscuro: barras, botones principales y títulos.
  static const celesteOscuro = Color(0xFF4682B4);

  /// Azul petróleo: superficies secundarias (resumen del carrito, etc.).
  static const petroleo = Color(0xFF5F9EA0);

  /// Texto sobre fondos claros (mejor contraste que el blanco).
  static const texto = Color(0xFF1F3A52);
  static const textoSecundario = Color(0xFF4F6577);

  static const exito = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);

  static const fondo = LinearGradient(
    colors: [celesteAgua, celeste],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

const String appFont = 'Exo2';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.celesteOscuro,
    primary: AppColors.celesteOscuro,
    secondary: AppColors.petroleo,
    error: AppColors.error,
    surface: Colors.white,
  );

  final rounded12 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  return ThemeData(
    colorScheme: scheme,
    fontFamily: appFont,
    scaffoldBackgroundColor: AppColors.celesteAgua,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: appFont,
          bodyColor: AppColors.texto,
          displayColor: AppColors.texto,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.celesteOscuro,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontFamily: appFont,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.celesteOscuro,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: rounded12,
        elevation: 3,
        textStyle: const TextStyle(
          fontFamily: appFont,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.celesteOscuro,
        side: const BorderSide(color: AppColors.celesteOscuro, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: rounded12,
        textStyle: const TextStyle(
          fontFamily: appFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.celesteOscuro),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.celeste),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.celeste),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.celesteOscuro, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      // Flotantes: no tapan los botones de la parte inferior.
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontFamily: appFont, fontSize: 15),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.celesteOscuro,
      unselectedItemColor: AppColors.textoSecundario,
      type: BottomNavigationBarType.fixed,
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.celesteOscuro),
  );
}
