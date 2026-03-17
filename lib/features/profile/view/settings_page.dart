import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text(
                    'Receive alerts about orders and promos',
                  ),
                  value: _notifications,
                  onChanged: (val) => setState(() => _notifications = val),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable dark theme'),
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
                ListTile(
                  title: const Text('Language'),
                  subtitle: const Text('English (US)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                BlocBuilder<CurrencyCubit, CurrencyState>(
                  builder: (context, state) => ListTile(
                    title: const Text('Default Currency'),
                    subtitle: Text(state.selectedCurrency.displayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/profile/currency'),
                  ),
                ),
                BlocBuilder<CurrencyCubit, CurrencyState>(
                  builder: (context, state) => SwitchListTile(
                    title: const Text('Dynamic Pricing'),
                    subtitle: const Text(
                      'Auto-update prices every 60 seconds',
                    ),
                    value: state.dynamicPricing,
                    onChanged: (val) =>
                        context.read<CurrencyCubit>().setDynamicPricing(val),
                  ),
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
      ),
    );
  }
}
