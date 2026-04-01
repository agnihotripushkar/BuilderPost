import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ImageUploadStrip extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ImageUploadStrip({
    super.key,
    required this.imagePaths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (imagePaths.length < 3) _AddImageCard(onTap: onAdd),
          ...imagePaths.asMap().entries.map(
            (e) => _ImageThumbnail(path: e.value, index: e.key, onRemove: onRemove),
          ),
        ],
      ),
    );
  }
}

class _AddImageCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: c.accent, size: 22),
            const SizedBox(height: 4),
            Text('Add', style: TextStyle(color: c.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String path;
  final int index;
  final ValueChanged<int> onRemove;

  const _ImageThumbnail({required this.path, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Container(
          width: 80, height: 80,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border),
            image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2, right: 12,
          child: GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(color: c.accentOrange, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
