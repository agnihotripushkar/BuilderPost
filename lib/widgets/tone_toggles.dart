import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _tones = [
  _ToneOption(id: 'professional', label: 'Professional', emoji: '💼'),
  _ToneOption(id: 'witty', label: 'Witty', emoji: '😄'),
  _ToneOption(id: 'casual', label: 'Casual', emoji: '☕'),
  _ToneOption(id: 'academic', label: 'Academic', emoji: '🎓'),
];

class _ToneOption {
  final String id;
  final String label;
  final String emoji;
  const _ToneOption({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

class ToneToggles extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ToneToggles({
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
          _tones.map((t) {
            final isSelected = selected == t.id;
            return GestureDetector(
              onTap: () => onChanged(t.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.accent.withOpacity(0.12)
                          : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      t.label,
                      style: TextStyle(
                        color:
                            isSelected ? AppColors.accent : AppColors.textMuted,
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
