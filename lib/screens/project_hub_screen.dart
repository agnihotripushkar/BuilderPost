import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/drafts_provider.dart';
import '../models/project_draft.dart';
import '../theme/app_colors.dart';
import '../utils/app_router.dart';
import 'composer_screen.dart';
import 'resume_projects_screen.dart';
import 'history_screen.dart';
import 'api_key_screen.dart';

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
          IconButton(
            onPressed: () => _openHistory(context),
            icon: const Icon(Icons.history_rounded, size: 22),
            tooltip: 'History',
          ),
          IconButton(
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'API Key Settings',
          ),
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
                'Gemini 2.5 Flash',
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
      body: drafts.isEmpty
          ? _EmptyState(onNew: () => _openComposer(context))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _StaggeredCard(
                index: i,
                child: _DraftCard(
                  draft: drafts[i],
                  onTap: () => _openComposer(context, draft: drafts[i]),
                  onDelete: () =>
                      ref.read(draftsProvider.notifier).deleteDraft(drafts[i].id),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'resume_fab',
            onPressed: () => _openResumeProjects(context),
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
            tooltip: 'Import from Resume',
            child: const Icon(Icons.picture_as_pdf_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'new_post_fab',
            onPressed: () => _openComposer(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Post'),
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
        ],
      ),
    );
  }

  void _openComposer(BuildContext context, {ProjectDraft? draft}) {
    Navigator.of(context).push(AppRouter.scale(ComposerScreen(existingDraft: draft)));
  }

  void _openResumeProjects(BuildContext context) {
    Navigator.of(context).push(AppRouter.slide(const ResumeProjectsScreen()));
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(AppRouter.slide(const HistoryScreen()));
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      AppRouter.slide(const ApiKeyScreen(isUpdateMode: true)),
    );
  }
}

// ─── Staggered entrance animation for each draft card ───────────────────────

class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredCard({required this.index, required this.child});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: each card waits (index * 55ms) before animating
    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Empty state with pulsing ⚡ icon ────────────────────────────────────────

class _EmptyState extends StatefulWidget {
  final VoidCallback onNew;
  const _EmptyState({required this.onNew});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing ⚡ badge
          ScaleTransition(
            scale: _pulse,
            child: Container(
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
            onPressed: widget.onNew,
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
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                AppRouter.slide(const ResumeProjectsScreen()),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Import from Resume (PDF)'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Draft card ──────────────────────────────────────────────────────────────

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
