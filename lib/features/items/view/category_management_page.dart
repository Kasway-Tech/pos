import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/l10n.dart';

import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categoryManageTitle), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, curr) => prev.categories != curr.categories,
            builder: (context, state) {
              final categories = state.categories;
              return ListView.separated(
                itemCount: categories.length + 1,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index < categories.length) {
                    final name = categories[index];
                    final count = state.itemsByCategory[name]?.length ?? 0;
                    return _CategoryTile(
                      name: name,
                      count: count,
                      onRename: () => _showRenameDialog(context, name),
                      onDelete: () => _confirmDelete(context, name, count),
                    );
                  }
                  return ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      context.l10n.categoryAddCategory,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () => _showAddDialog(context),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.categoryNewCategory),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.categoryNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.categoryCancel),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                context.read<HomeBloc>().add(
                  HomeCategoryAdded(nameCtrl.text.trim()),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(context.l10n.categoryAdd),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, String current) async {
    final nameCtrl = TextEditingController(text: current);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.categoryRenameTitle),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.categoryNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.categoryCancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty && newName != current) {
                context.read<HomeBloc>().add(
                  HomeCategoryRenamed(oldName: current, newName: newName),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: Text(context.l10n.categoryRename),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String name,
    int count,
  ) async {
    final content = count > 0
        ? context.l10n.categoryDeleteWithItems(name, count, count == 1 ? '' : 's')
        : context.l10n.categoryDeleteEmpty(name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.categoryDeleteTitle),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.categoryCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.categoryDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      context.read<HomeBloc>().add(HomeCategoryDeleted(name));
    }
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.name,
    required this.count,
    required this.onRename,
    required this.onDelete,
  });

  final String name;
  final int count;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(context.l10n.categoryItemCount(count, count == 1 ? '' : 's')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onRename,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
