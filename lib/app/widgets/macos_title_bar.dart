import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class MacOSTitleBar extends StatelessWidget {
  const MacOSTitleBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) {
      return child;
    }

    return Column(
      children: [
        // Custom title bar
        GestureDetector(
          onDoubleTap: () async {
            if (Platform.isMacOS) {
              // Get primary display
              final display = await screenRetriever.getPrimaryDisplay();

              // Set window to fill available screen space (accounting for menu bar and dock)
              final rect = Rect.fromLTWH(
                display.visiblePosition!.dx,
                display.visiblePosition!.dy,
                display.visibleSize!.width,
                display.visibleSize!.height,
              );

              // Animate the window resize with smooth transition
              await windowManager.setBounds(rect, animate: true);
            }
          },
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
          ),
        ),
        // Main content
        Expanded(child: child),
      ],
    );
  }
}
