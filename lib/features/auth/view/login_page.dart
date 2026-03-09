import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/features/auth/cubit/auth_cubit.dart';
import 'package:kasway/features/auth/cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtpSection = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sign in failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
        if (state.status == AuthStatus.otpSent && !_showOtpSection) {
          setState(() => _showOtpSection = true);
          _otpController.clear();
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: (_showOtpSection || state.status == AuthStatus.otpSent)
                    ? _OtpSection(
                        email: _emailController.text,
                        otpController: _otpController,
                        isLoading: isLoading,
                        errorMessage: state.errorMessage,
                        onVerify: () => context
                            .read<AuthCubit>()
                            .verifyOtp(
                              _emailController.text.trim(),
                              _otpController.text.trim(),
                            ),
                        onBack: () {
                          setState(() => _showOtpSection = false);
                          context.read<AuthCubit>().resetToUnauthenticated();
                        },
                      )
                    : _GoogleSection(
                        emailController: _emailController,
                        isLoading: isLoading,
                        onSendOtp: () => context
                            .read<AuthCubit>()
                            .sendOtp(_emailController.text.trim()),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GoogleSection extends StatefulWidget {
  const _GoogleSection({
    required this.emailController,
    required this.isLoading,
    required this.onSendOtp,
  });

  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSendOtp;

  @override
  State<_GoogleSection> createState() => _GoogleSectionState();
}

class _GoogleSectionState extends State<_GoogleSection> {
  bool _showCodeOption = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with your Google account to continue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 48),
        OutlinedButton.icon(
          onPressed: widget.isLoading
              ? null
              : () => context.read<AuthCubit>().signInWithGoogle(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const _GoogleIcon(),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 24),
        if (!_showCodeOption)
          Center(
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () => setState(() => _showCodeOption = true),
              child: Text(
                'Use a code instead',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else ...[
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Enter your email to receive a sign-in code.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => widget.onSendOtp(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: widget.isLoading ||
                    widget.emailController.text.trim().isEmpty
                ? null
                : widget.onSendOtp,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send code'),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showCodeOption = false),
              child: Text(
                'Back to Google sign-in',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpSection extends StatelessWidget {
  const _OtpSection({
    required this.email,
    required this.otpController,
    required this.isLoading,
    required this.onVerify,
    required this.onBack,
    this.errorMessage,
  });

  final String email;
  final TextEditingController otpController;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onBack;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 48),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to $email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onVerify(),
          style: Theme.of(context).textTheme.headlineSmall,
          decoration: InputDecoration(
            hintText: '000000',
            counterText: '',
            border: const OutlineInputBorder(),
            errorText: errorMessage,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isLoading ? null : onVerify,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : onBack,
          child: Text(
            'Back',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ],
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
