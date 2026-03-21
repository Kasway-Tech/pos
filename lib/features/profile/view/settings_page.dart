import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/locale/locale_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/language_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: BlurAppBar(title: Text(l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, state) => ListTile(
                  title: Text(l10n.settingsLanguage),
                  subtitle: Text(state.language.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LanguagePickerSheet.show(context),
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) => ListTile(
                  title: Text(l10n.settingsDisplayCurrency),
                  subtitle: Text(state.selectedCurrency.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/currency'),
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) {
                  final isKas = state.selectedCurrency.isCrypto;
                  return SwitchListTile(
                    title: Text(l10n.settingsDynamicPricing),
                    subtitle: Text(
                      isKas
                          ? l10n.settingsDynamicPricingUnavailable
                          : l10n.settingsDynamicPricingSubtitle,
                    ),
                    value: state.dynamicPricing,
                    onChanged: isKas
                        ? null
                        : (val) => context
                              .read<CurrencyCubit>()
                              .setDynamicPricing(val),
                  );
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.settingsAppInfo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.settingsAppVersion),
                trailing: const Text('1.0.0 (build 123)'),
              ),
              ListTile(
                title: Text(l10n.settingsTermsOfService),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
