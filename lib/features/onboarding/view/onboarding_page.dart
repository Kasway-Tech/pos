import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:kasway/data/services/data_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/items/view/item_management_page.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.prefs,
    required this.onboardingNotifier,
  });

  final SharedPreferences prefs;
  final ValueNotifier<bool> onboardingNotifier;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _loading = false;

  Future<void> _completeOnboarding() async {
    await widget.prefs.setBool(PreferenceKeys.onboardingComplete, true);
    widget.onboardingNotifier.value = true;
    if (mounted) context.go('/');
  }

  Future<void> _importCatalog() async {
    setState(() => _loading = true);
    try {
      final dataService = DataService(ProductRepository(), WithdrawalRepository());
      final result = await dataService.importData();
      if (!mounted) return;
      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.onboardingImportFailed(result.error!)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _loading = false);
        return;
      }
      if (result.imported == 0) {
        // User cancelled the file picker — stay on onboarding.
        setState(() => _loading = false);
        return;
      }
      context.read<HomeBloc>().add(HomeStarted());
      await _completeOnboarding();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.onboardingImportFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  void _startFresh() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ItemManagementPage(onSetupComplete: _completeOnboarding),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return MacOSTitleBar(
      child: Scaffold(
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            l10n.onboardingTitle,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            l10n.onboardingSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          _OnboardingCard(
                            icon: Icons.download,
                            title: l10n.onboardingImportTitle,
                            subtitle: l10n.onboardingImportSubtitle,
                            onTap: _importCatalog,
                          ),
                          const SizedBox(height: 16.0),
                          _OnboardingCard(
                            icon: Icons.inventory_2_outlined,
                            title: l10n.onboardingManualTitle,
                            subtitle: l10n.onboardingManualSubtitle,
                            onTap: _startFresh,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
