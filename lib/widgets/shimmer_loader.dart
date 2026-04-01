import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  final String label;

  const ShimmerLoader({super.key, this.label = 'AI is thinking...'});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: c.surfaceElevated,
          highlightColor: c.accent.withOpacity(0.3),
          period: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              _bar(c, width: 280, height: 16),
              const SizedBox(height: 10),
              _bar(c, width: 220, height: 14),
              const SizedBox(height: 10),
              _bar(c, width: 240, height: 14),
              const SizedBox(height: 10),
              _bar(c, width: 200, height: 14),
              const SizedBox(height: 10),
              _bar(c, width: 260, height: 14),
              const SizedBox(height: 10),
              _bar(c, width: 180, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: c.textMuted, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _bar(AppColors c, {required double width, required double height}) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(color: c.surfaceElevated, borderRadius: BorderRadius.circular(6)),
    );
  }
}
