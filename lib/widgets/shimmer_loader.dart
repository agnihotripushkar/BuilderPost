import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  final String label;

  const ShimmerLoader({super.key, this.label = 'AI is thinking...'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.surfaceElevated,
          highlightColor: AppColors.accent.withOpacity(0.3),
          period: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              _bar(width: 280, height: 16),
              const SizedBox(height: 10),
              _bar(width: 220, height: 14),
              const SizedBox(height: 10),
              _bar(width: 240, height: 14),
              const SizedBox(height: 10),
              _bar(width: 200, height: 14),
              const SizedBox(height: 10),
              _bar(width: 260, height: 14),
              const SizedBox(height: 10),
              _bar(width: 180, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
