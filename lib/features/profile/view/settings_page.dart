import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/locale/locale_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/language_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, state) => ListTile(
                  title: const Text('Language'),
                  subtitle: Text(state.language.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LanguagePickerSheet.show(context),
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) => ListTile(
                  title: const Text('Display Currency'),
                  subtitle: Text(state.selectedCurrency.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/currency'),
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) {
                  final isKas = state.selectedCurrency.isCrypto;
                  return SwitchListTile(
                    title: const Text('Dynamic Pricing'),
                    subtitle: Text(
                      isKas
                          ? 'Not available for KAS display currency'
                          : 'Auto-update prices every 60 seconds',
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'App Info',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const ListTile(
                title: Text('App Version'),
                trailing: Text('1.0.0 (build 123)'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
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
