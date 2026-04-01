import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/key_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_router.dart';
import 'onboarding_screen.dart';
import 'api_key_screen.dart';
import 'project_hub_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ⚡ Logo badge: elastic scale 0.4 → 1.0
  late final Animation<double> _logoScale;

  // App name: fade in + slide up
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameSlide;

  // Tagline: fade in slightly later
  late final Animation<double> _tagOpacity;

  // Subtle glow pulse on the badge (opacity 0.15 → 0.35 → 0.15)
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // Logo: 0ms–900ms with elasticOut for a satisfying "pop"
    _logoScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.69, curve: Curves.elasticOut),
      ),
    );

    // App name: 350ms–900ms
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.27, 0.72, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.27, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline: 550ms–1100ms
    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.42, 0.88, curve: Curves.easeOut),
      ),
    );

    // Glow: fades in as logo appears
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();

    // Navigate after animation + brief pause
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final apiKey = await KeyStorageService.getKey();

    if (!mounted) return;

    Widget next;
    if (!onboardingDone) {
      next = const OnboardingScreen();
    } else if (apiKey == null) {
      next = const ApiKeyScreen();
    } else {
      next = const ProjectHubScreen();
    }

    Navigator.of(context).pushReplacement(AppRouter.fade(next));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⚡ Logo with glow
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow layer
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withOpacity(
                            _glowOpacity.value,
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // App name
            SlideTransition(
              position: _nameSlide,
              child: FadeTransition(
                opacity: _nameOpacity,
                child: Text(
                  'BuilderPost AI',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            FadeTransition(
              opacity: _tagOpacity,
              child: Text(
                'Share what you build',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
