import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';

class PostPreviewCard extends StatelessWidget {
  final String platform;
  final String content;

  const PostPreviewCard({
    super.key,
    required this.platform,
    required this.content,
  });

  Color get _platformColor {
    switch (platform.toLowerCase()) {
      case 'peerlist':
        return AppColors.peerlist;
      case 'linkedin':
        return AppColors.linkedIn;
      case 'x':
        return AppColors.xTwitter;
      default:
        return AppColors.accent;
    }
  }

  String get _platformLabel {
    switch (platform.toLowerCase()) {
      case 'peerlist':
        return '🟢 Peerlist';
      case 'linkedin':
        return '💼 LinkedIn';
      case 'x':
        return '𝕏 X / Twitter';
      default:
        return platform;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _platformColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _platformColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _platformColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _platformLabel.split(' ').first,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _platformLabel.split(' ').skip(1).join(' '),
                      style: TextStyle(
                        color: _platformColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      'Generated Post',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
                strong: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                em: const TextStyle(
                  color: AppColors.accent,
                  fontStyle: FontStyle.italic,
                ),
                code: const TextStyle(
                  color: AppColors.accentGreen,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  backgroundColor: AppColors.surfaceElevated,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquote: const TextStyle(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                h1: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                h2: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                h3: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
