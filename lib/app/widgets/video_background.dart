import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Renders [child] over a looping, muted video background with a subtle
/// black overlay to keep foreground content readable.
class VideoBackground extends StatefulWidget {
  const VideoBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.4,
  });

  final Widget child;

  /// Opacity of the black overlay (0.0–1.0). Defaults to 0.4.
  final double overlayOpacity;

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/gradientbg.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_controller.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, widget.overlayOpacity),
          ),
        ),
        widget.child,
      ],
    );
  }
}
