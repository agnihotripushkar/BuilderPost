import 'package:flutter/material.dart';

/// Custom page transition factory.
/// Use these instead of [MaterialPageRoute] everywhere for consistent,
/// polished animations throughout the app.
class AppRouter {
  AppRouter._();

  /// Subtle slide-right + fade — used for standard forward navigation
  /// (History, Settings, Resume import).
  static Route<T> slide<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween(
          begin: const Offset(0.045, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

        // Outgoing screen fades slightly (secondary)
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

  /// Scale from 94% + fade — used for the Composer screen.
  /// Feels like "opening a canvas" / creating something.
  static Route<T> scale<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 270),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final scaleTween = Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final fadeTween = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return ScaleTransition(
          scale: scaleTween,
          child: FadeTransition(opacity: fadeTween, child: child),
        );
      },
    );
  }

  /// Pure crossfade — used for splash→home and screen replacement transitions.
  /// No direction, just seamless.
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}
