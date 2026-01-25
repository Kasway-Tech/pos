import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Order History')),
        body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Order #${1234 + index}'),
                subtitle: Text(
                  'Items: Nasi Goreng, Es Teh\n24 Jan 2026, 06:40',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${(25000 + (index * 5000))}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Completed',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
