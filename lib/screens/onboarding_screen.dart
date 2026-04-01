import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/service_providers.dart';
import '../theme/app_colors.dart';
import '../utils/app_router.dart';
import 'api_key_screen.dart';
import 'project_hub_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [_Page1(), _Page2(), _Page3()];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    final apiKey = await ref.read(apiKeyProvider.future);

    if (!mounted) return;
    final next = apiKey != null ? const ProjectHubScreen() : const ApiKeyScreen();
    Navigator.of(context).pushReplacement(AppRouter.fade(next));
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLast ? 0.0 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    child: Text('Skip', style: GoogleFonts.inter(color: c.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? c.accent : c.textSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isLast
                        ? SizedBox(
                            key: const ValueKey('getstarted'),
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _finish,
                              style: FilledButton.styleFrom(
                                backgroundColor: c.accent,
                                foregroundColor: c.background,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Get Started  ✦', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          )
                        : Row(
                            key: const ValueKey('next'),
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton.icon(
                                onPressed: _next,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                label: const Text('Next'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: c.accent,
                                  foregroundColor: c.background,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1 ──────────────────────────────────────────────────────────────────

class _Page1 extends StatefulWidget {
  const _Page1();

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _opacity,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: c.accent.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: c.accent.withOpacity(0.15), blurRadius: 40, spreadRadius: 5)],
                ),
                child: const Center(child: Text('⚡', style: TextStyle(fontSize: 50))),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _opacity,
              child: Column(
                children: [
                  Text('Turn Projects Into\nViral Posts', textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.25, letterSpacing: -0.4)),
                  const SizedBox(height: 16),
                  Text('Describe your project once.\nBuilderPost crafts platform-perfect\nposts for you instantly.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 15, color: c.textMuted, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2 ──────────────────────────────────────────────────────────────────

class _Page2 extends StatefulWidget {
  const _Page2();

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Animation<double> _itemScale(int i) => Tween<double>(begin: 0.4, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Interval(i * 0.15, 0.45 + i * 0.15, curve: Curves.elasticOut)));

  Animation<double> _itemOpacity(int i) => Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Interval(i * 0.15, 0.35 + i * 0.1, curve: Curves.easeOut)));

  Animation<Offset> _textSlide() => Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
    CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)));

  Animation<double> _textOpacity() => Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.85, curve: Curves.easeOut)));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final platforms = [
      ('🟢', 'Peerlist', AppColors.peerlist),
      ('💼', 'LinkedIn', AppColors.linkedIn),
      ('𝕏', 'X / Twitter', c.xTwitter),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(platforms.length, (i) {
              final (emoji, label, color) = platforms[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => ScaleTransition(
                    scale: _itemScale(i),
                    child: FadeTransition(
                      opacity: _itemOpacity(i),
                      child: Column(
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: color.withOpacity(0.35)),
                            ),
                            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
                          ),
                          const SizedBox(height: 8),
                          Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 44),
          SlideTransition(
            position: _textSlide(),
            child: FadeTransition(
              opacity: _textOpacity(),
              child: Column(
                children: [
                  Text('3 Platforms, One Tap', textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.25, letterSpacing: -0.4)),
                  const SizedBox(height: 16),
                  Text("Generate tailored posts for Peerlist,\nLinkedIn, and X/Twitter — each\noptimized for that platform's audience.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 15, color: c.textMuted, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3 ──────────────────────────────────────────────────────────────────

class _Page3 extends StatefulWidget {
  const _Page3();

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends State<_Page3> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale, _iconOpacity, _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..forward();
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65, curve: Curves.elasticOut)));
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _iconScale,
            child: FadeTransition(
              opacity: _iconOpacity,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: c.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: c.accentGreen.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: c.accentGreen.withOpacity(0.12), blurRadius: 40, spreadRadius: 5)],
                ),
                child: const Center(child: Text('🔐', style: TextStyle(fontSize: 48))),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  Text('Your Key,\nYour Privacy', textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.25, letterSpacing: -0.4)),
                  const SizedBox(height: 16),
                  Text("Use your own free Gemini API key.\nIt's stored securely on your device\nand never shared with anyone.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 15, color: c.textMuted, height: 1.6)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeatureChip(icon: Icons.lock_outline_rounded, label: 'On-device only', color: c.accentGreen),
                      const SizedBox(width: 10),
                      _FeatureChip(icon: Icons.cloud_off_outlined, label: 'Never uploaded', color: c.accent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
