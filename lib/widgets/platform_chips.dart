import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _platforms = [
  _PlatformOption(
    id: 'peerlist',
    label: 'Peerlist',
    color: AppColors.peerlist,
    icon: '🟢',
  ),
  _PlatformOption(
    id: 'linkedin',
    label: 'LinkedIn',
    color: AppColors.linkedIn,
    icon: '💼',
  ),
  _PlatformOption(
    id: 'x',
    label: 'X / Twitter',
    color: AppColors.xTwitter,
    icon: '𝕏',
  ),
];

class _PlatformOption {
  final String id;
  final String label;
  final Color color;
  final String icon;
  const _PlatformOption({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });
}

class PlatformChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PlatformChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _platforms.map((p) {
            final isSelected = selected == p.id;
            return GestureDetector(
              onTap: () => onChanged(p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? p.color.withOpacity(0.18)
                          : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? p.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      p.label,
                      style: TextStyle(
                        color: isSelected ? p.color : AppColors.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
