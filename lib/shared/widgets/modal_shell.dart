import 'dart:ui';

import 'package:flutter/material.dart';

/// Contenedor reutilizable para pantallas adicionales con formato modal.
class ModalShell extends StatelessWidget {
  const ModalShell({super.key, required this.child, this.backgroundDim});

  final Widget child;
  final Color? backgroundDim;

  @override
  Widget build(BuildContext context) {
    final overlayColor = backgroundDim ??
        Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.04,
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: overlayColor),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact =
                    constraints.maxWidth < 600 || constraints.maxHeight < 600;
                final widthFactor = compact ? 1.0 : 0.8;
                final heightFactor = compact ? 1.0 : 0.9;
                final radius = BorderRadius.circular(compact ? 0 : 24);

                return Center(
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    heightFactor: heightFactor,
                    child: Material(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: radius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                              if (!compact)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 16),
                                ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
