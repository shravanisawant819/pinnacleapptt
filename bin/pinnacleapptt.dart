import 'package:flutter/material.dart';

class PinnacleApp extends StatelessWidget {
  const PinnacleApp({super.key});

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _bg      = Color(0xFF0E0A07);
  static const _surface = Color(0xFF1C1208);
  static const _orange  = Color(0xFFFF6B2B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinnacle TT Club',
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      // ── Scaffold & canvas ─────────────────────────────────────────────────
      scaffoldBackgroundColor: _bg,
      canvasColor: _bg,

      // ── Colour scheme ─────────────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:          _orange,
        onPrimary:        Colors.black,
        secondary:        _orange,
        onSecondary:      Colors.black,
        surface:          _surface,
        onSurface:        Colors.white,
        error:            Color(0xFFFF5C5C),
        onError:          Colors.white,
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:     _bg,
        foregroundColor:     Colors.white,
        elevation:           0,
        scrolledUnderElevation: 0,
        centerTitle:         false,
        titleTextStyle: TextStyle(
          color:       Colors.white,
          fontSize:    18,
          fontWeight:  FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white70),
      ),

      // ── Elevated button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  _orange,
          foregroundColor:  Colors.black,
          elevation:        0,
          minimumSize:      const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize:    15,
            fontWeight:  FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _orange,
          textStyle: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: const Color(0xFF140D06),
        hintStyle: TextStyle(
          color:    Colors.white.withOpacity(0.2),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color:    Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIconColor: Colors.white30,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: _orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFFF5C5C), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFFF5C5C), width: 1.2),
        ),
        errorStyle: const TextStyle(
            color: Color(0xFFFF5C5C), fontSize: 11),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:        _surface,
        elevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     Colors.white.withOpacity(0.08),
        thickness: 1,
        space:     1,
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: Colors.white70, size: 22),

      // ── Snack bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:   _surface,
        contentTextStyle:  const TextStyle(color: Colors.white, fontSize: 13),
        actionTextColor:   _orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:   Colors.transparent,
        modalBarrierColor: Colors.black54,
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _orange,
      ),

      // ── Checkbox ─────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _orange;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ── Text ─────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontSize: 48,
            fontWeight: FontWeight.w900, letterSpacing: -1),
        headlineLarge: TextStyle(
            color: Colors.white, fontSize: 32,
            fontWeight: FontWeight.w800, letterSpacing: -0.8),
        headlineMedium: TextStyle(
            color: Colors.white, fontSize: 24,
            fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(
            color: Colors.white, fontSize: 18,
            fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleMedium: TextStyle(
            color: Colors.white, fontSize: 15,
            fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(
            color: Colors.white, fontSize: 15),
        bodyMedium: TextStyle(
            color: Colors.white, fontSize: 13),
        bodySmall: TextStyle(
            color: Color(0x66FFFFFF), fontSize: 11),
        labelSmall: TextStyle(
            color: Color(0x4DFFFFFF), fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
    );
  }
}