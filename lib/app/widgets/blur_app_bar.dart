import 'dart:ui';

import 'package:flutter/material.dart';

/// An [AppBar] with a frosted-glass background.
///
/// When content scrolls behind the bar, a [BackdropFilter] blurs the
/// underlying pixels instead of tinting/elevating the surface.
class BlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BlurAppBar({
    super.key,
    this.title,
    this.centerTitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.bottom,
  });

  final Widget? title;
  final bool? centerTitle;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return AppBar(
      title: title,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: surfaceColor.withValues(alpha: 0.30),
          ),
        ),
      ),
    );
  }
}
