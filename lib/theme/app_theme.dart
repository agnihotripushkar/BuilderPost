import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    const c = AppColors.dark;
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.dark(
        surface: c.surface,
        primary: c.accent,
        secondary: c.accentGreen,
        onSurface: c.textPrimary,
        onPrimary: c.background,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        titleLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        bodyLarge: GoogleFonts.inter(color: c.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: c.textMuted, fontSize: 13),
        bodySmall: GoogleFonts.jetBrainsMono(color: c.textMuted, fontSize: 12),
        labelLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0D1117),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accent.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.accent);
          }
          return IconThemeData(color: c.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.inter(color: c.textMuted, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceElevated,
        selectedColor: c.accent.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(color: c.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.accent, width: 1.5)),
        hintStyle: GoogleFonts.inter(color: c.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.background,
        elevation: 2,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent.withOpacity(0.3) : c.border,
        ),
      ),
    );
  }

  static ThemeData get light {
    const c = AppColors.light;
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.light(
        surface: c.surface,
        primary: c.accent,
        secondary: c.accentGreen,
        onSurface: c.textPrimary,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        titleLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        bodyLarge: GoogleFonts.inter(color: c.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: c.textMuted, fontSize: 13),
        bodySmall: GoogleFonts.jetBrainsMono(color: c.textMuted, fontSize: 12),
        labelLarge: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFFFFFFF),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accent.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.accent);
          }
          return IconThemeData(color: c.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.inter(color: c.textMuted, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceElevated,
        selectedColor: c.accent.withOpacity(0.15),
        labelStyle: GoogleFonts.inter(color: c.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.accent, width: 1.5)),
        hintStyle: GoogleFonts.inter(color: c.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent.withOpacity(0.3) : c.border,
        ),
      ),
    );
  }
}
