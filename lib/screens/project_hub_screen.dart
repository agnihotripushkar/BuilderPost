import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/drafts_provider.dart';
import '../models/project_draft.dart';
import '../theme/app_colors.dart';
import 'composer_screen.dart';

class ProjectHubScreen extends ConsumerWidget {
  const ProjectHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('⚡', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Text(
              'BuilderPost AI',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.4),
                ),
              ),
              child: Text(
                'Gemini 1.5 Flash',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          drafts.isEmpty
              ? _EmptyState(onNew: () => _openComposer(context))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: drafts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder:
                    (context, i) => _DraftCard(
                      draft: drafts[i],
                      onTap: () => _openComposer(context, draft: drafts[i]),
                      onDelete:
                          () => ref
                              .read(draftsProvider.notifier)
                              .deleteDraft(drafts[i].id),
                    ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Post'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
      ),
    );
  }

  void _openComposer(BuildContext context, {ProjectDraft? draft}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComposerScreen(existingDraft: draft)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onNew;
  const _EmptyState({required this.onNew});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No posts yet',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first developer post\nand share it with the world',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Post'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final ProjectDraft draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  Color get _platformColor {
    switch (draft.platform) {
      case 'peerlist':
        return AppColors.peerlist;
      case 'linkedin':
        return AppColors.linkedIn;
      default:
        return AppColors.xTwitter;
    }
  }

  String get _platformLabel {
    switch (draft.platform) {
      case 'peerlist':
        return '🟢 Peerlist';
      case 'linkedin':
        return '💼 LinkedIn';
      default:
        return '𝕏 X / Twitter';
    }
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _platformColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _platformLabel.split(' ').first,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title.isEmpty ? 'Untitled Project' : draft.title,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _platformColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _platformLabel.split(' ').skip(1).join(' '),
                          style: TextStyle(
                            color: _platformColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${draft.tone}',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 12,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
