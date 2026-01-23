import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                child: Text('We support Credit Cards, E-Wallets, and Cash.'),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Support'),
            subtitle: const Text('support@atomikpos.com'),
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
    );
  }
}
