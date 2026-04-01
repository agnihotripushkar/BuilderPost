import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.accent,
    required this.accentGreen,
    required this.accentOrange,
    required this.accentPurple,
    required this.textPrimary,
    required this.textMuted,
    required this.textSubtle,
    required this.xTwitter,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color accent;
  final Color accentGreen;
  final Color accentOrange;
  final Color accentPurple;
  final Color textPrimary;
  final Color textMuted;
  final Color textSubtle;
  final Color xTwitter;

  // Platform colors that never change with theme
  static const Color peerlist = Color(0xFF00AA45);
  static const Color linkedIn = Color(0xFF0A66C2);

  static const AppColors dark = AppColors._(
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceElevated: Color(0xFF1C2128),
    border: Color(0xFF30363D),
    accent: Color(0xFF58A6FF),
    accentGreen: Color(0xFF7EE787),
    accentOrange: Color(0xFFF78166),
    accentPurple: Color(0xFFD2A8FF),
    textPrimary: Color(0xFFE6EDF3),
    textMuted: Color(0xFF8B949E),
    textSubtle: Color(0xFF484F58),
    xTwitter: Color(0xFFE7E9EA),
  );

  static const AppColors light = AppColors._(
    background: Color(0xFFF6F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEAF0F6),
    border: Color(0xFFD0D7DE),
    accent: Color(0xFF0969DA),
    accentGreen: Color(0xFF1A7F37),
    accentOrange: Color(0xFFCF222E),
    accentPurple: Color(0xFF8250DF),
    textPrimary: Color(0xFF1F2328),
    textMuted: Color(0xFF656D76),
    textSubtle: Color(0xFFAFBAC9),
    xTwitter: Color(0xFF14171A),
  );
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
}
