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
  final GeneratedPost post;

  const PreviewScreen({super.key, required this.draft, required this.post});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late GeneratedPost _post;
  bool _isRegenerating = false;
  final _refineCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _refineCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _post.content));
    if (mounted) {
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

  Future<void> _share() async {
    await Share.share(_post.content, subject: widget.draft.title);
  }

  Future<void> _regenerate() async {
    setState(() => _isRegenerating = true);

    final refineHint = _refineCtrl.text.trim();

    // Append refine hint to description if provided
    if (refineHint.isNotEmpty) {
      ref
          .read(composerProvider.notifier)
          .updateDescription(
            '${widget.draft.description}\n\nUser refinement request: $refineHint',
          );
    }

    await ref.read(composerProvider.notifier).generate();
    final state = ref.read(composerProvider);

    if (state.status == ComposerStatus.done &&
        state.generatedPost != null &&
        mounted) {
      setState(() {
        _post = state.generatedPost!;
        _isRegenerating = false;
        _refineCtrl.clear();
      });
    } else {
      setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          // Copy button
          Tooltip(
            message: 'Copy to clipboard',
            child: IconButton(
              onPressed: _isRegenerating ? null : _copyToClipboard,
              icon: const Icon(Icons.copy_outlined, size: 20),
            ),
          ),
          // Share button
          Tooltip(
            message: 'Share post',
            child: IconButton(
              onPressed: _isRegenerating ? null : _share,
              icon: const Icon(Icons.share_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body:
          _isRegenerating
              ? const Center(
                child: ShimmerLoader(label: 'Refining your post...'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project header
                    _ProjectHeader(draft: widget.draft),

                    const SizedBox(height: 16),

                    // Post preview card
                    PostPreviewCard(
                      platform: _post.platform,
                      content: _post.content,
                    ),

                    const SizedBox(height: 16),

                    // Screenshots (if any)
                    if (widget.draft.imagePaths.isNotEmpty) ...[
                      Text(
                        'Project Screenshots',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              widget.draft.imagePaths
                                  .map(
                                    (p) => Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                        image: DecorationImage(
                                          image: FileImage(File(p)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy_all_rounded, size: 16),
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
                            onPressed: _share,
                            icon: const Icon(Icons.ios_share_rounded, size: 16),
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

                    const SizedBox(height: 20),

                    // Regenerate section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refine & Regenerate',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _refineCtrl,
                            decoration: const InputDecoration(
                              hintText:
                                  'Optional: tell AI what to improve (e.g. "make it shorter", "add more emojis")',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isRegenerating ? null : _regenerate,
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                              ),
                              label: const Text('Regenerate'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accentPurple,
                                side: const BorderSide(
                                  color: AppColors.accentPurple,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final ProjectDraft draft;
  const _ProjectHeader({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.title.isEmpty ? 'Untitled Project' : draft.title,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _Badge(
                    label: draft.platform.toUpperCase(),
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  _Badge(label: draft.tone, color: AppColors.accentPurple),
                ],
              ),
            ],
          ),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
