import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/project_draft.dart';
import '../models/generated_post.dart';
import '../providers/composer_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/post_preview_card.dart';
import '../widgets/shimmer_loader.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final ProjectDraft draft;
  final List<GeneratedPost> posts;

  const PreviewScreen({super.key, required this.draft, required this.posts});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late List<GeneratedPost> _posts;
  late PageController _pageCtrl;
  int _currentIndex = 0;
  final _refineCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _posts = widget.posts;
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _refineCtrl.dispose();
    super.dispose();
  }

  GeneratedPost get _currentPost => _posts[_currentIndex];

  Future<void> _copyToClipboard() async {
    final c = context.colors;
    await Clipboard.setData(ClipboardData(text: _currentPost.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: c.accentGreen, size: 18),
            const SizedBox(width: 8),
            Text('Copied to clipboard!', style: GoogleFonts.inter(color: c.textPrimary)),
          ],
        ),
        backgroundColor: c.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _share() async {
    await Share.share(_currentPost.content, subject: widget.draft.title);
  }

  Future<void> _saveToHistory() async {
    final c = context.colors;
    await ref.read(composerProvider.notifier).saveToHistory(_currentIndex);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.bookmark_added_rounded, color: c.accentGreen, size: 18),
            const SizedBox(width: 8),
            Text('Option ${_currentIndex + 1} saved to history!', style: GoogleFonts.inter(color: c.textPrimary)),
          ],
        ),
        backgroundColor: c.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _regenerate() async {
    final refineHint = _refineCtrl.text.trim();
    await ref.read(composerProvider.notifier).regenerateWithHint(
      refineHint,
      originalDescription: widget.draft.description,
    );
    if (!mounted) return;
    final newPosts = ref.read(composerProvider).generatedPosts;
    if (newPosts != null && newPosts.isNotEmpty) {
      setState(() {
        _posts = newPosts;
        _currentIndex = 0;
      });
      _pageCtrl.jumpToPage(0);
      _refineCtrl.clear();
    }
  }

  void _showRefineSheet() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Refine & Regenerate', style: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Tell the AI what to improve — get 3 fresh options', style: GoogleFonts.inter(color: c.textMuted, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: _refineCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. "make it shorter", "add more emojis", "focus on the tech stack"',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _regenerate();
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Regenerate 3 Options'),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.accentPurple,
                    foregroundColor: c.background,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final composerStatus = ref.watch(composerProvider).status;
    final isRegenerating = composerStatus == ComposerStatus.generating ||
        composerStatus == ComposerStatus.fetchingReadme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Post'),
        actions: [
          Tooltip(
            message: 'Copy to clipboard',
            child: IconButton(onPressed: isRegenerating ? null : _copyToClipboard, icon: const Icon(Icons.copy_outlined, size: 20)),
          ),
          Tooltip(
            message: 'Share post',
            child: IconButton(onPressed: isRegenerating ? null : _share, icon: const Icon(Icons.share_outlined, size: 20)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isRegenerating
          ? const Center(child: ShimmerLoader(label: 'Generating 3 new options...'))
          : Column(
              children: [
                _OptionTabs(
                  count: _posts.length,
                  selected: _currentIndex,
                  onTap: (i) {
                    setState(() => _currentIndex = i);
                    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _posts.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (context, i) => _PostPage(draft: widget.draft, post: _posts[i]),
                  ),
                ),
                _BottomActions(onCopy: _copyToClipboard, onShare: _share, onSave: _saveToHistory, onRefine: _showRefineSheet),
              ],
            ),
    );
  }
}

// ── Option selector tabs ──────────────────────────────────────────────────────

class _OptionTabs extends StatelessWidget {
  final int count;
  final int selected;
  final void Function(int) onTap;

  const _OptionTabs({required this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
      child: Row(
        children: List.generate(count, (i) {
          final isSelected = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < count - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? c.accent.withOpacity(0.15) : c.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? c.accent : c.border, width: isSelected ? 1.5 : 1),
                ),
                child: Text(
                  'Option ${i + 1}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isSelected ? c.accent : c.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Single post page ──────────────────────────────────────────────────────────

class _PostPage extends StatelessWidget {
  final ProjectDraft draft;
  final GeneratedPost post;

  const _PostPage({required this.draft, required this.post});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProjectHeader(draft: draft),
          const SizedBox(height: 16),
          PostPreviewCard(platform: post.platform, content: post.content),
          if (draft.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Project Screenshots', style: GoogleFonts.inter(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: draft.imagePaths.map((p) => Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                    image: DecorationImage(image: FileImage(File(p)), fit: BoxFit.cover),
                  ),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onRefine;

  const _BottomActions({required this.onCopy, required this.onShare, required this.onSave, required this.onRefine});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.bookmark_add_rounded, size: 17),
              label: const Text('Save to History'),
              style: FilledButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: c.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_all_rounded, size: 15),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textPrimary,
                    side: BorderSide(color: c.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded, size: 15),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textPrimary,
                    side: BorderSide(color: c.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRefine,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text('Refine'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.accentPurple,
                    side: BorderSide(color: c.accentPurple),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ProjectHeader extends StatelessWidget {
  final ProjectDraft draft;
  const _ProjectHeader({required this.draft});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.title.isEmpty ? 'Untitled Project' : draft.title,
          style: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _Badge(label: draft.platform.toUpperCase(), color: c.accent),
            const SizedBox(width: 6),
            _Badge(label: draft.tone, color: c.accentPurple),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}
