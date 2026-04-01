import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';

class PostPreviewCard extends StatelessWidget {
  final String platform;
  final String content;

  const PostPreviewCard({super.key, required this.platform, required this.content});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final platformColor = _platformColor(c);
    final platformLabel = _platformLabel(c);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: platformColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: platformColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: platformColor.withOpacity(0.2), shape: BoxShape.circle),
                  child: Center(child: Text(platformLabel.split(' ').first, style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformLabel.split(' ').skip(1).join(' '),
                      style: TextStyle(color: platformColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text('Generated Post', style: TextStyle(color: c.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: c.textPrimary, fontSize: 14, height: 1.6),
                strong: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700),
                em: TextStyle(color: c.accent, fontStyle: FontStyle.italic),
                code: TextStyle(color: c.accentGreen, fontFamily: 'monospace', fontSize: 12, backgroundColor: c.surfaceElevated),
                codeblockDecoration: BoxDecoration(color: c.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                blockquote: TextStyle(color: c.textMuted, fontStyle: FontStyle.italic),
                h1: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                h2: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                h3: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _platformColor(AppColors c) {
    switch (platform.toLowerCase()) {
      case 'peerlist': return AppColors.peerlist;
      case 'linkedin': return AppColors.linkedIn;
      case 'x': return c.xTwitter;
      default: return c.accent;
    }
  }

  String _platformLabel(AppColors c) {
    switch (platform.toLowerCase()) {
      case 'peerlist': return '🟢 Peerlist';
      case 'linkedin': return '💼 LinkedIn';
      case 'x': return '𝕏 X / Twitter';
      default: return platform;
    }
  }
}
