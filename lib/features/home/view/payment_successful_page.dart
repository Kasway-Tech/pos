import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessfulPage extends StatefulWidget {
  const PaymentSuccessfulPage({super.key});

  @override
  State<PaymentSuccessfulPage> createState() => _PaymentSuccessfulPageState();
}

class _PaymentSuccessfulPageState extends State<PaymentSuccessfulPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Lottie.asset(
                'assets/lottie/kw-complete.json',
                controller: _lottieController,
                width: 180,
                height: 180,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward();
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The transaction has been processed successfully. You can now return to the home screen or start a new order.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  context.go('/');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
