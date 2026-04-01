import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/extracted_project.dart';
import '../models/project_draft.dart';
import '../providers/service_providers.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_router.dart';
import 'composer_screen.dart';

class ResumeProjectsScreen extends ConsumerStatefulWidget {
  const ResumeProjectsScreen({super.key});

  @override
  ConsumerState<ResumeProjectsScreen> createState() => _ResumeProjectsScreenState();
}

class _ResumeProjectsScreenState extends ConsumerState<ResumeProjectsScreen> {
  bool _isLoading = false;
  List<ExtractedProject> _projects = [];
  String? _error;

  Future<void> _pickAndParsePdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return;

      final apiKey = await ref.read(apiKeyProvider.future);
      if (apiKey == null) {
        setState(() => _error = 'No API key found. Please add your Gemini API key in Settings.');
        return;
      }

      setState(() { _isLoading = true; _error = null; _projects = []; });

      final path = result.files.single.path!;
      final projects = await GeminiService(apiKey).extractProjectsFromPdf(path);

      setState(() {
        _isLoading = false;
        _projects = projects;
        if (projects.isEmpty) _error = 'No projects found in this PDF.';
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Failed to parse PDF.\n\nDetails:\n$e'; });
    }
  }

  void _selectProject(ExtractedProject project) {
    final draft = ProjectDraft.create(title: project.title, description: project.description);
    Navigator.of(context).pushReplacement(AppRouter.scale(ComposerScreen(existingDraft: draft)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Import from Resume')),
      body: _buildBody(c),
      floatingActionButton: _projects.isEmpty && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _pickAndParsePdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Select PDF'),
              backgroundColor: c.accent,
              foregroundColor: c.background,
            )
          : null,
    );
  }

  Widget _buildBody(AppColors c) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: c.accent),
            const SizedBox(height: 16),
            Text(
              'AI is reading your resume...\nExtracting projects...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: c.textMuted, height: 1.5),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: c.accentOrange, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.inter(color: c.accentOrange)),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: _pickAndParsePdf, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: c.surfaceElevated, shape: BoxShape.circle),
              child: Icon(Icons.document_scanner_outlined, size: 48, color: c.textMuted),
            ),
            const SizedBox(height: 24),
            Text(
              'Import your Resume',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your PDF resume or LinkedIn profile.\nWe will extract your projects to turn into posts.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: c.textMuted, height: 1.5),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = _projects[i];
        return InkWell(
          onTap: () => _selectProject(p),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_special_outlined, color: c.accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: c.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  p.description,
                  style: GoogleFonts.inter(color: c.textMuted, fontSize: 14, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
