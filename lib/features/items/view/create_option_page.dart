import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/items/view/category_management_page.dart';
import 'package:kasway/features/items/view/item_form_page.dart';

class CreateOptionPage extends StatelessWidget {
  const CreateOptionPage({super.key, this.currentCategory});

  /// The currently active category tab, used for "New Item in [category]".
  /// Null when no categories exist yet.
  final String? currentCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(title: const Text('Create'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('New Category'),
                subtitle: const Text('Add a new product category'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _openCategoryManagement(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(
                  currentCategory != null
                      ? 'New Item in "$currentCategory"'
                      : 'New Item',
                ),
                subtitle: Text(
                  currentCategory != null
                      ? 'Add a product to "$currentCategory"'
                      : 'Select a category tab first',
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                enabled: currentCategory != null,
                onTap: currentCategory != null
                    ? () => _openItemForm(context, currentCategory!)
                    : null,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('New Category & Items'),
                subtitle: const Text('Create a category then add products'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _createCategoryThenItems(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategoryManagement(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CategoryManagementPage()));
  }

  void _openItemForm(BuildContext context, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemFormPage(defaultCategory: category),
      ),
    );
  }

  Future<void> _createCategoryThenItems(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final nameCtrl = TextEditingController();

    final created = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) Navigator.of(context).pop(name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created == null || !context.mounted) return;

    bloc.add(HomeCategoryAdded(created));

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemFormPage(defaultCategory: created)),
    );
  }
}
