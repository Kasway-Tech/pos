import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessfulPage extends StatefulWidget {
  const PaymentSuccessfulPage({
    super.key,
    this.title = 'Payment Successful!',
    this.subtitle = 'The transaction has been processed successfully.',
  });

  final String title;
  final String subtitle;

  @override
  State<PaymentSuccessfulPage> createState() => _PaymentSuccessfulPageState();
}

class _PaymentSuccessfulPageState extends State<PaymentSuccessfulPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        context.go('/');
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/kw-complete.json',
                      controller: _lottieController,
                      width: 180,
                      height: 180,
                      onLoaded: (composition) {
                        _lottieController
                          ..duration = composition.duration
                          ..forward().whenComplete(_startCountdown);
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: Text(
                'You will be redirected in $_countdown second${_countdown == 1 ? '' : 's'}...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
