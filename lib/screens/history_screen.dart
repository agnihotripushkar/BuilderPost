import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/history_entry.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/post_preview_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (entries.isNotEmpty)
            Tooltip(
              message: 'Clear all history',
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, size: 22),
                onPressed: () => _confirmClearAll(context, ref),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body:
          entries.isEmpty
              ? _EmptyState()
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder:
                    (context, i) => _HistoryCard(
                      entry: entries[i],
                      onDelete:
                          () => ref
                              .read(historyProvider.notifier)
                              .deleteEntry(entries[i].id),
                      onTap: () => _openDetail(context, entries[i]),
                    ),
              ),
    );
  }

  void _openDetail(BuildContext context, HistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _HistoryDetailScreen(entry: entry)),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            title: Text(
              'Clear History',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            content: Text(
              'Delete all saved posts? This cannot be undone.',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final entries = ref.read(historyProvider);
                  for (final e in entries) {
                    ref.read(historyProvider.notifier).deleteEntry(e.id);
                  }
                },
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(color: AppColors.accentOrange),
                ),
              ),
            ],
          ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.entry,
    required this.onDelete,
    required this.onTap,
  });

  Color get _platformColor {
    switch (entry.platform) {
      case 'peerlist':
        return AppColors.peerlist;
      case 'linkedin':
        return AppColors.linkedIn;
      default:
        return AppColors.xTwitter;
    }
  }

  String get _platformEmoji {
    switch (entry.platform) {
      case 'peerlist':
        return '🟢';
      case 'linkedin':
        return '💼';
      default:
        return '𝕏';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _platformColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _platformEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.projectTitle,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _platformColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.platform.toUpperCase(),
                              style: TextStyle(
                                color: _platformColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${entry.tone}  · ${_formatDate(entry.savedAt)}',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textSubtle,
                    size: 20,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view full post',
              style: GoogleFonts.inter(
                color: AppColors.textSubtle,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.history_rounded,
                color: AppColors.textSubtle,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No saved posts yet',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a post and tap\n"Save to History" to keep it here',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail screen ─────────────────────────────────────────────────────────────

class _HistoryDetailScreen extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryDetailScreen({required this.entry});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: entry.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.accentGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Copied to clipboard!',
                style: GoogleFonts.inter(color: AppColors.textPrimary),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.projectTitle),
        actions: [
          IconButton(
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_outlined, size: 20),
            tooltip: 'Copy',
          ),
          IconButton(
            onPressed: () =>
                Share.share(entry.content, subject: entry.projectTitle),
            icon: const Icon(Icons.share_outlined, size: 20),
            tooltip: 'Share',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostPreviewCard(platform: entry.platform, content: entry.content),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy_all_rounded, size: 15),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        () => Share.share(
                          entry.content,
                          subject: entry.projectTitle,
                        ),
                    icon: const Icon(Icons.ios_share_rounded, size: 15),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
