import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/data/models/branch.dart';
import 'package:kasway/features/branch/cubit/branch_cubit.dart';
import 'package:kasway/features/branch/cubit/branch_state.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({super.key});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<BranchCubit>().loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: BlocBuilder<BranchCubit, BranchState>(
              builder: (context, state) {
                if (state.status == BranchStatus.loading) {
                  return const CircularProgressIndicator();
                }

                if (state.status == BranchStatus.failure) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Failed to load branches.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            context.read<BranchCubit>().loadBranches(),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }

                if (state.branches.isEmpty &&
                    state.status == BranchStatus.success) {
                  return const Text(
                    'No branches assigned to your account. Contact your store manager.',
                    textAlign: TextAlign.center,
                  );
                }

                // Auto-select if only one branch
                if (state.branches.length == 1 &&
                    state.status == BranchStatus.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _selectBranch(context, state.branches.first);
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Branch',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a branch to operate.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 32),
                    ...state.branches.map(
                      (branch) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton(
                          onPressed: () => _selectBranch(context, branch),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(branch.name),
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
    );
  }

  void _selectBranch(BuildContext context, Branch branch) {
    context.read<BranchCubit>().selectBranch(branch);
    context.read<HomeBloc>().add(
          HomeStarted(branchId: branch.id, storeId: branch.storeId),
        );
    context.go('/');
  }
}
