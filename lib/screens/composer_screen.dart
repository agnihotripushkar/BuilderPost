import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/composer_provider.dart';
import '../providers/drafts_provider.dart';
import '../models/project_draft.dart';
import '../theme/app_colors.dart';
import '../widgets/platform_chips.dart';
import '../widgets/tone_toggles.dart';
import '../widgets/image_upload_strip.dart';
import 'preview_screen.dart';

class ComposerScreen extends ConsumerStatefulWidget {
  final ProjectDraft? existingDraft;

  const ComposerScreen({super.key, this.existingDraft});

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(composerProvider.notifier);
      if (widget.existingDraft != null) {
        final d = widget.existingDraft!;
        _titleCtrl.text = d.title;
        _descCtrl.text = d.description;
        _urlCtrl.text = d.projectUrl;
        notifier.updateTitle(d.title);
        notifier.updateDescription(d.description);
        notifier.updateProjectUrl(d.projectUrl);
        notifier.updatePlatform(d.platform);
        notifier.updateTone(d.tone);
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final current = ref.read(composerProvider).draft.imagePaths.length;
    final remaining = 3 - current;
    if (remaining <= 0) return;

    final xFiles = await _picker.pickMultiImage(limit: remaining);
    for (final xFile in xFiles) {
      ref.read(composerProvider.notifier).addImage(xFile.path);
    }
  }

  Future<void> _generate() async {
    final composer = ref.read(composerProvider);
    if (composer.draft.description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a project description first.'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    await ref.read(composerProvider.notifier).generate();

    final state = ref.read(composerProvider);
    if (state.status == ComposerStatus.done &&
        state.generatedPosts != null &&
        state.generatedPosts!.isNotEmpty) {
      // Save to drafts
      final draft = state.draft.copyWith(
        title:
            _titleCtrl.text.trim().isEmpty
                ? 'Untitled Project'
                : _titleCtrl.text.trim(),
      );
      ref.read(draftsProvider.notifier).addDraft(draft);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) =>
                    PreviewScreen(draft: draft, posts: state.generatedPosts!),
          ),
        );
      }
    } else if (state.status == ComposerStatus.error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Generation failed.'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);
    final isLoading =
        state.status == ComposerStatus.generating ||
        state.status == ComposerStatus.fetchingReadme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Composer'),
        leading: BackButton(
          onPressed: () {
            ref.read(composerProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Project Info
            _SectionLabel(label: '🗂  Project Info'),
            const SizedBox(height: 10),
            TextField(
              controller: _titleCtrl,
              onChanged: ref.read(composerProvider.notifier).updateTitle,
              decoration: const InputDecoration(
                hintText: 'Project name (e.g. BuilderPost AI)',
                prefixIcon: Icon(
                  Icons.folder_outlined,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              onChanged: ref.read(composerProvider.notifier).updateDescription,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Describe your project — what it does, your tech stack, challenges you solved...',
              ),
            ),

            const SizedBox(height: 16),

            // Section: Project Link
            _SectionLabel(
              label: '🔗  Project Link (optional)',
              sub: 'GitHub repo, deployed app, Play Store, or any sharable URL',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlCtrl,
              onChanged: ref.read(composerProvider.notifier).updateProjectUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://...',
                prefixIcon: Icon(
                  Icons.link_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section: Screenshots
            _SectionLabel(
              label: '🖼  Screenshots (up to 3)',
              sub: 'AI analyzes your UI to improve the post copy',
            ),
            const SizedBox(height: 10),
            ImageUploadStrip(
              imagePaths: state.draft.imagePaths,
              onAdd: _pickImage,
              onRemove: ref.read(composerProvider.notifier).removeImage,
            ),

            const SizedBox(height: 16),

            // Section: Platform
            _SectionLabel(label: '📡  Target Platform'),
            const SizedBox(height: 10),
            PlatformChips(
              selected: state.draft.platform,
              onChanged: ref.read(composerProvider.notifier).updatePlatform,
            ),

            const SizedBox(height: 16),

            // Section: Tone
            _SectionLabel(label: '🎛  Tone'),
            const SizedBox(height: 10),
            ToneToggles(
              selected: state.draft.tone,
              onChanged: ref.read(composerProvider.notifier).updateTone,
            ),

            const SizedBox(height: 28),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _generate,
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                  isLoading
                      ? (state.status == ComposerStatus.fetchingReadme
                          ? 'Fetching README...'
                          : 'Generating 3 options...')
                      : 'Generate 3 Options',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isLoading
                          ? AppColors.accent.withOpacity(0.5)
                          : AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? sub;
  const _SectionLabel({required this.label, this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(
            sub!,
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
