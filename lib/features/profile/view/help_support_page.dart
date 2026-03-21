import 'package:flutter/material.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MacOSTitleBar(
      child: Scaffold(
        appBar: BlurAppBar(title: Text(l10n.helpTitle)),
        body: Center(
          child: ConstrainedBox(
            key: const Key('content_constraint'),
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.helpFaqTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ExpansionTile(
                  title: Text(l10n.helpHowToPlaceOrder),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(l10n.helpHowToPlaceOrderAnswer),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(l10n.helpPaymentMethods),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(l10n.helpPaymentMethodsAnswer),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(l10n.helpCancelOrder),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(l10n.helpCancelOrderAnswer),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.helpContactUs,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.helpEmailSupport),
                  subtitle: const Text('support@kasway.com'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: Text(l10n.helpWhatsAppSupport),
                  subtitle: const Text('+62 812-3456-7890'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(l10n.helpCallCenter),
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
