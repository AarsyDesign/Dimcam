import 'package:flutter/material.dart';

/// Page route dengan animasi slide + fade yang mulus.
Route<T> smoothRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.08, 0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final fadeTween = Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Push dengan smooth transition.
extension SmoothNavigator on BuildContext {
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.of(this).push(smoothRoute<T>(page));
  }

  Future<T?> pushReplaceSmooth<T>(Widget page) {
    return Navigator.of(this).pushReplacement(smoothRoute<T>(page));
  }
}
