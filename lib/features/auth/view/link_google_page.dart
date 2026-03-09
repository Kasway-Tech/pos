import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/data/repositories/auth_repository.dart';
import 'package:kasway/features/auth/cubit/auth_cubit.dart';
import 'package:kasway/features/auth/cubit/auth_state.dart';

class LinkGooglePage extends StatefulWidget {
  const LinkGooglePage({super.key});

  @override
  State<LinkGooglePage> createState() => _LinkGooglePageState();
}

class _LinkGooglePageState extends State<LinkGooglePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to link account'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
        if (state.status == AuthStatus.authenticated) {
          final name = _nameController.text.trim();
          context
              .read<AuthRepository>()
              .activateBranchMember(name: name.isNotEmpty ? name : null)
              .ignore();
        }
      },
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state.status == AuthStatus.loading;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.link_rounded, size: 56),
                      const SizedBox(height: 24),
                      Text(
                        'One last step',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter your name and link your Google account to complete setup.',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          hintText: 'e.g., Alex Johnson',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: (isLoading ||
                                _nameController.text.trim().isEmpty)
                            ? null
                            : () =>
                                context.read<AuthCubit>().linkGoogle(),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const _GoogleIcon(),
                        label: const Text('Link Google Account'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            isLoading ? null : () => context.read<AuthCubit>().signOut(),
                        child: Text(
                          'Sign out',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
        color: Colors.white,
      ),
    );
  }
}
