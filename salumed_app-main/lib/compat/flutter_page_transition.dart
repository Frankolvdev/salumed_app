import 'package:flutter/material.dart';

enum PageTransitionType {
  slideInRight,
  slideInUp,
}

/// Reemplazo local y compatible con Dart 3 del paquete obsoleto
/// `flutter_page_transition`.
///
/// Mantiene la API utilizada por SaluMed para evitar modificar cada llamada
/// a Navigator.push y conservar las mismas animaciones visuales.
class PageTransition<T> extends PageRouteBuilder<T> {
  PageTransition({
    required Widget child,
    required PageTransitionType type,
    Duration duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : super(
          settings: settings,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          fullscreenDialog: fullscreenDialog,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = switch (type) {
              PageTransitionType.slideInRight => const Offset(1.0, 0.0),
              PageTransitionType.slideInUp => const Offset(0.0, 1.0),
            };

            final offsetAnimation = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).chain(
              CurveTween(curve: Curves.easeInOut),
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
