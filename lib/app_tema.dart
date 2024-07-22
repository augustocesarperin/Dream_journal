import 'package:flutter/material.dart';

// Tema visual do aplicativo, inspirado em estética noir e tons escuros
// Centraliza as cores e estilos usados em todo o app
class AppTema {

  static const Color corPrimaria = Color(0xFF1A1A1A);
  static const Color corSecundaria = Color(0xFFB20000); // vermelho escuro
  static const Color corFundo = Color(0xFF000000);
  static const Color corTexto = Color(0xFFE0E0E0);
  static const Color corTextoDimmed = Color(0xFF9E9E9E);
  static const Color corAcento = Color(0xFF4A0000);
  static const Color corCortina = Color(0xFFAA0000);

  // TODO: adicionar variações da paleta para diferentes níveis de contraste

  
  static ThemeData obterTema() {
    // Usa o esquema escuro como base
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
      // Configuração da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: corPrimaria,
        foregroundColor: corTexto,
        elevation: 0,
      ),
      // Configuração dos estilos de texto
      // Talvez mudar as fontes no futuro
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 26,
          letterSpacing: 1.2,
        ),
        displayMedium: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.1,
        ),
        displaySmall: TextStyle(
          color: corTexto,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          color: corTexto,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: corTexto,
          fontSize: 13,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: corTextoDimmed,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
      // Estilo dos campos de texto
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

      // Cores para feedback de toque (InkWell)
      splashColor: AppTema.corSecundaria.withOpacity(0.1),
      highlightColor: AppTema.corSecundaria.withOpacity(0.05),
    );
  }
} 