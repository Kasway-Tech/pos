import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          // User Info Section
          const _ProfileHeader(name: 'John Doe', email: 'john.doe@example.com'),
          const SizedBox(height: 32.0),

          // Menus Section
          _ProfileMenuItem(
            icon: Icons.history,
            title: 'Order History',
            onTap: () => context.push('/profile/orders'),
          ),
          _ProfileMenuItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () => context.push('/profile/payments'),
          ),
          _ProfileMenuItem(
            icon: Icons.palette_outlined,
            title: 'Theme Settings',
            onTap: () => context.push('/profile/theme'),
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.push('/profile/settings'),
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push('/profile/help'),
          ),
          const Divider(height: 32.0),

          // Actions Section
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showConfirmationDialog(
              context,
              title: 'Logout',
              content: 'Are you sure you want to log out?',
              confirmLabel: 'Logout',
              isDestructive: true,
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showConfirmationDialog(
              context,
              title: 'Delete Account',
              content:
                  'This action is permanent and cannot be undone. All your data will be removed.',
              confirmLabel: 'Delete',
              isDestructive: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(color: isDestructive ? Colors.red : null),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Logic for confirmation would go here
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 50,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
