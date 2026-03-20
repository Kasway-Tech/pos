import 'package:flutter/material.dart';

/// An animated pulse-ring widget that briefly scales and fades a circular
/// border behind [child] whenever [controller] is driven forward.
///
/// Parameters:
/// - [controller]: the [AnimationController] that drives the pulse animation.
/// - [child]: the widget displayed at the centre (e.g. a DAA score [Text]).
/// - [scaleFactor]: how much the ring expands (added on top of 1.0).
///   Defaults to 0.15 (15 % expansion).
/// - [size]: diameter of the pulse ring in logical pixels. Defaults to 72.
class PulseDisplay extends StatelessWidget {
  const PulseDisplay({
    super.key,
    required this.controller,
    required this.child,
    this.scaleFactor = 0.15,
    this.size = 72,
  });

  final AnimationController controller;
  final Widget child;
  final double scaleFactor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, innerChild) {
        final opacity = (1.0 - controller.value).clamp(0.0, 1.0);
        final scale = 1.0 + controller.value * scaleFactor;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (controller.value > 0)
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(80),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            innerChild!,
          ],
        );
      },
      child: child,
    );
  }
}
