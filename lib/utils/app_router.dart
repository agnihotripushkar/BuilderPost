import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/history_entry.dart';
import '../models/generated_post.dart';
import '../models/project_draft.dart';
import '../screens/api_key_screen.dart';
import '../screens/composer_screen.dart';
import '../screens/history_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/preview_screen.dart';
import '../screens/project_hub_screen.dart';
import '../screens/resume_projects_screen.dart';
import '../screens/splash_screen.dart';

/// Centralized, type-safe navigation for the app built on [GoRouter].
///
/// Route names are exposed as constants so call sites stay refactor-safe
/// (`context.go(AppRoutes.hub)` instead of stringly-typed paths). Custom
/// page transitions (slide / scale / fade) are preserved via
/// [CustomTransitionPage] to keep the polished feel of the original
/// [Navigator]-based flow.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String apiKey = '/api-key';
  static const String hub = '/hub';
  static const String composer = '/composer';
  static const String resume = '/resume';
  static const String preview = '/preview';
  static const String historyDetail = '/history-detail';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (_, state) => _fade(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.apiKey,
      pageBuilder: (_, state) => _fade(state, const ApiKeyScreen()),
    ),
    GoRoute(
      path: AppRoutes.hub,
      pageBuilder: (_, state) => _fade(state, const ProjectHubScreen()),
    ),
    GoRoute(
      path: AppRoutes.composer,
      pageBuilder: (_, state) {
        final draft = state.extra as ProjectDraft?;
        return _scale(state, ComposerScreen(existingDraft: draft));
      },
    ),
    GoRoute(
      path: AppRoutes.resume,
      pageBuilder: (_, state) => _slide(state, const ResumeProjectsScreen()),
    ),
    GoRoute(
      path: AppRoutes.preview,
      pageBuilder: (_, state) {
        final args = state.extra as ({ProjectDraft draft, List<GeneratedPost> posts});
        return _slide(
          state,
          PreviewScreen(draft: args.draft, posts: args.posts),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.historyDetail,
      pageBuilder: (_, state) {
        final entry = state.extra as HistoryEntry;
        return _slide(state, HistoryDetailScreen(entry: entry));
      },
    ),
  ],
);

// ─── Transition page builders ─────────────────────────────────────────────────

/// Subtle slide-right + fade — standard forward navigation.
CustomTransitionPage<T> _slide<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final slide = Tween(
        begin: const Offset(0.045, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final fadePrevious = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );
      return FadeTransition(
        opacity: fadePrevious,
        child: SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        ),
      );
    },
  );
}

/// Scale from 94% + fade — used for the Composer ("opening a canvas").
CustomTransitionPage<T> _scale<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 270),
    transitionsBuilder: (_, animation, __, child) {
      final scaleTween = Tween<double>(begin: 0.94, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      final fadeTween = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return ScaleTransition(
        scale: scaleTween,
        child: FadeTransition(opacity: fadeTween, child: child),
      );
    },
  );
}

/// Pure crossfade — replacement transitions (splash, onboarding, api key, hub).
CustomTransitionPage<T> _fade<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}
