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
import 'settings_screen.dart';

class ProjectHubScreen extends ConsumerStatefulWidget {
  const ProjectHubScreen({super.key});

  @override
  ConsumerState<ProjectHubScreen> createState() => _ProjectHubScreenState();
}

class _ProjectHubScreenState extends ConsumerState<ProjectHubScreen> {
  int _selectedIndex = 0;

  static const _titles = ['BuilderPost AI', 'History', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⚡', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'BuilderPost AI',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                _titles[_selectedIndex],
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: c.textPrimary,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.accentGreen.withOpacity(0.4)),
              ),
              child: Text(
                'Gemini 2.5 Flash',
                style: GoogleFonts.jetBrainsMono(
                  color: c.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(
            onOpenComposer: (draft) => _openComposer(context, draft: draft),
            onOpenResumeProjects: () => _openResumeProjects(context),
          ),
          const HistoryScreen(embedded: true),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'resume_fab',
                  onPressed: () => _openResumeProjects(context),
                  backgroundColor: c.surfaceElevated,
                  foregroundColor: c.textPrimary,
                  tooltip: 'Import from Resume',
                  child: const Icon(Icons.picture_as_pdf_outlined),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'new_post_fab',
                  onPressed: () => _openComposer(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Post'),
                  backgroundColor: c.accent,
                  foregroundColor: c.background,
                ),
              ],
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
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
}

// ─── Home tab body ────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  final void Function(ProjectDraft? draft) onOpenComposer;
  final VoidCallback onOpenResumeProjects;

  const _HomeTab({required this.onOpenComposer, required this.onOpenResumeProjects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsProvider);
    return drafts.isEmpty
        ? _EmptyState(onNew: () => onOpenComposer(null))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _StaggeredCard(
              index: i,
              child: _DraftCard(
                draft: drafts[i],
                onTap: () => onOpenComposer(drafts[i]),
                onDelete: () =>
                    ref.read(draftsProvider.notifier).deleteDraft(drafts[i].id),
              ),
            ),
          );
  }
}

// ─── Staggered entrance animation for each draft card ────────────────────────

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
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

// ─── Empty state with pulsing ⚡ icon ─────────────────────────────────────────

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
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
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: const Center(child: Text('⚡', style: TextStyle(fontSize: 38))),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No posts yet',
            style: GoogleFonts.inter(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first developer post\nand share it with the world',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: c.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: widget.onNew,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Post'),
            style: FilledButton.styleFrom(
              backgroundColor: c.accent,
              foregroundColor: c.background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(AppRouter.slide(const ResumeProjectsScreen()));
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Import from Resume (PDF)'),
            style: TextButton.styleFrom(foregroundColor: c.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Draft card ───────────────────────────────────────────────────────────────

class _DraftCard extends StatelessWidget {
  final ProjectDraft draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({required this.draft, required this.onTap, required this.onDelete});

  Color _platformColor(AppColors c) {
    switch (draft.platform) {
      case 'peerlist': return AppColors.peerlist;
      case 'linkedin': return AppColors.linkedIn;
      default: return c.xTwitter;
    }
  }

  String get _platformLabel {
    switch (draft.platform) {
      case 'peerlist': return '🟢 Peerlist';
      case 'linkedin': return '💼 LinkedIn';
      default: return '𝕏 X / Twitter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final platformColor = _platformColor(c);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: platformColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(_platformLabel.split(' ').first, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title.isEmpty ? 'Untitled Project' : draft.title,
                    style: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: platformColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _platformLabel.split(' ').skip(1).join(' '),
                          style: TextStyle(color: platformColor, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('· ${draft.tone}', style: GoogleFonts.inter(color: c.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: c.textSubtle, size: 20),
              tooltip: 'Delete',
            ),
            Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
