import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import 'api_key_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final currentMode = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Appearance ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance', icon: Icons.palette_outlined, c: c),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                _ThemeOption(
                  label: 'System Default',
                  subtitle: 'Follows your device setting',
                  icon: Icons.brightness_auto_rounded,
                  mode: ThemeMode.system,
                  current: currentMode,
                  c: c,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                ),
                Divider(height: 1, color: c.border),
                _ThemeOption(
                  label: 'Light',
                  subtitle: 'Always use light theme',
                  icon: Icons.light_mode_rounded,
                  mode: ThemeMode.light,
                  current: currentMode,
                  c: c,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                ),
                Divider(height: 1, color: c.border),
                _ThemeOption(
                  label: 'Dark',
                  subtitle: 'Always use dark theme',
                  icon: Icons.dark_mode_rounded,
                  mode: ThemeMode.dark,
                  current: currentMode,
                  c: c,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── API Key ─────────────────────────────────────────────────────────
          _SectionHeader(label: 'Gemini API Key', icon: Icons.key_rounded, c: c),
          const SizedBox(height: 10),
          const ApiKeyScreen(isUpdateMode: true, embedded: true),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors c;

  const _SectionHeader({required this.label, required this.icon, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: c.textMuted),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: c.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Theme option row ──────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode current;
  final AppColors c;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.current,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? c.accent.withOpacity(0.12) : c.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? c.accent : c.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: c.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: c.accent, size: 20)
            else
              Icon(Icons.radio_button_unchecked_rounded, color: c.textSubtle, size: 20),
          ],
        ),
      ),
    );
  }
}
