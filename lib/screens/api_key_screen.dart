import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/service_providers.dart';
import '../services/key_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_router.dart';
import 'project_hub_screen.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  final bool isUpdateMode;
  final bool embedded;

  const ApiKeyScreen({super.key, this.isUpdateMode = false, this.embedded = false});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = context.colors;
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Please paste your Gemini API key.');
      return;
    }
    if (!key.startsWith('AIza')) {
      setState(() => _error = 'That doesn\'t look like a valid Gemini API key.\nKeys usually start with "AIza".');
      return;
    }

    setState(() { _saving = true; _error = null; });
    await KeyStorageService.saveKey(key);
    ref.invalidate(apiKeyProvider);
    if (!mounted) return;
    setState(() => _saving = false);

    if (widget.isUpdateMode && !widget.embedded) {
      Navigator.of(context).pop();
    } else if (widget.isUpdateMode && widget.embedded) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('API key updated.', style: GoogleFonts.inter(color: c.textPrimary)),
          backgroundColor: c.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else {
      Navigator.of(context).pushReplacement(AppRouter.fade(const ProjectHubScreen()));
    }
  }

  Future<void> _clearKey() async {
    await KeyStorageService.deleteKey();
    ref.invalidate(apiKeyProvider);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(AppRouter.fade(const ApiKeyScreen()), (_) => false);
  }

  Future<void> _openAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/apikey');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isUpdateMode) ...[
              const SizedBox(height: 40),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.accent.withOpacity(0.3)),
                ),
                child: const Center(child: Text('⚡', style: TextStyle(fontSize: 30))),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to\nBuilderPost AI',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'To generate posts, you need a free Google Gemini API key. Your key is stored only on this device — never shared.',
                style: GoogleFonts.inter(fontSize: 15, color: c.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Your Gemini API key is stored securely on this device.',
                style: GoogleFonts.inter(fontSize: 14, color: c.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            _StepCard(
              step: '1',
              title: 'Get your free API key',
              subtitle: 'Visit Google AI Studio and create a key. It\'s free.',
              c: c,
              action: TextButton.icon(
                onPressed: _openAiStudio,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Open Google AI Studio'),
                style: TextButton.styleFrom(foregroundColor: c.accent, padding: EdgeInsets.zero),
              ),
            ),

            const SizedBox(height: 12),

            _StepCard(step: '2', title: 'Paste your API key below', subtitle: null, c: c, action: null),

            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              focusNode: _focusNode,
              obscureText: _obscure,
              style: GoogleFonts.jetBrainsMono(color: c.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'AIza...',
                hintStyle: GoogleFonts.jetBrainsMono(color: c.textSubtle, fontSize: 13),
                errorText: _error,
                errorStyle: GoogleFonts.inter(color: c.accentOrange, fontSize: 12, height: 1.4),
                errorMaxLines: 3,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: c.textMuted, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _save(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: c.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.isUpdateMode ? 'Update Key' : 'Save & Continue',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
              ),
            ),

            if (widget.isUpdateMode) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearKey,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.accentOrange,
                    side: BorderSide(color: c.accentOrange.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Clear Key & Sign Out', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: c.textSubtle),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Your key is stored in your device\'s secure keychain (iOS) or encrypted storage (Android). It is never sent to any server other than Google\'s Gemini API.',
                    style: GoogleFonts.inter(fontSize: 12, color: c.textSubtle, height: 1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: widget.isUpdateMode
          ? AppBar(title: const Text('API Key Settings'), leading: const BackButton())
          : null,
      body: body,
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String? subtitle;
  final Widget? action;
  final AppColors c;

  const _StepCard({required this.step, required this.title, this.subtitle, this.action, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: c.accent.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(child: Text(step, style: GoogleFonts.inter(color: c.accent, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: GoogleFonts.inter(color: c.textMuted, fontSize: 13)),
                ],
                if (action != null) ...[const SizedBox(height: 4), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
