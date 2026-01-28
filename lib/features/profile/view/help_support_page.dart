import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Help & Support')),
        body: Center(
          child: ConstrainedBox(
            key: const Key('content_constraint'),
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Frequently Asked Questions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const ExpansionTile(
                  title: Text('How to place an order?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'You can pick products from the home page and confirm the selection.',
                      ),
                    ),
                  ],
                ),
                const ExpansionTile(
                  title: Text('Payment methods available?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'We support Credit Cards, E-Wallets, and Cash.',
                      ),
                    ),
                  ],
                ),
                const ExpansionTile(
                  title: Text('Can I cancel an order?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Orders can be cleared before confirmation from the order bar.',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Contact Us',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@kasway.com'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: const Text('WhatsApp Support'),
                  subtitle: const Text('+62 812-3456-7890'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Call Center'),
                  subtitle: const Text('1500-123'),
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
