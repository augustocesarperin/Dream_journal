import 'package:flutter/material.dart';

class AppTema {
  static const Color corPrimaria = Color(0xFF1A1A1A);
  static const Color corSecundaria = Color(0xFFB20000);
  static const Color corFundo = Color(0xFF000000);
  static const Color corTexto = Color(0xFFE0E0E0);
  static const Color corTextoDimmed = Color(0xFF9E9E9E);
  static const Color corAcento = Color(0xFF4A0000);
  static const Color corCortina = Color(0xFFAA0000);

  static ThemeData obterTema() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: corSecundaria,
        secondary: corAcento,
        surface: corPrimaria,
        background: corFundo,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: corFundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: corPrimaria,
        foregroundColor: corTexto,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: 1.2,
        ),
        displayMedium: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.1,
        ),
        displaySmall: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          color: corTexto,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: corTexto,
          fontSize: 14,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: corTextoDimmed,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: corPrimaria,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corSecundaria, width: 2),
        ),
        hintStyle: const TextStyle(color: corTextoDimmed),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corSecundaria,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: corPrimaria,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: corAcento,
        thickness: 1,
      ),
    );
  }
} 