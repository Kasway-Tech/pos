import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/items/view/category_management_page.dart';
import 'package:kasway/features/items/view/item_form_page.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _categoryCount = 0;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _rebuildTabController(List<String> categories) {
    if (categories.length != _categoryCount) {
      _tabController?.dispose();
      _tabController = TabController(length: categories.length, vsync: this);
      _categoryCount = categories.length;
    }
  }

  void _openAddForm(BuildContext context, {String? defaultCategory}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<HomeBloc>(),
        child: ItemFormPage(defaultCategory: defaultCategory),
      ),
    ));
  }

  void _openEditForm(
      BuildContext context, Product product, String category) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<HomeBloc>(),
        child: ItemFormPage(product: product, defaultCategory: category),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.categories != curr.categories ||
          prev.itemsByCategory != curr.itemsByCategory,
      builder: (context, state) {
        final categories = state.categories;
        _rebuildTabController(categories);

        return TitlebarSafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Manage Item'),
              centerTitle: true,
              bottom: categories.isEmpty
                  ? null
                  : TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: categories
                          .map((c) => Tab(text: c))
                          .toList(),
                    ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: 'Manage Categories',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HomeBloc>(),
                      child: const CategoryManagementPage(),
                    ),
                  )),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Item',
                  onPressed: () => _openAddForm(context),
                ),
              ],
            ),
            body: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant),
                        const SizedBox(height: 16),
                        const Text('No categories yet'),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<HomeBloc>(),
                              child: const CategoryManagementPage(),
                            ),
                          )),
                          child: const Text('Add Category'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: categories
                        .map((c) => _CategoryItemList(
                              category: c,
                              onAddTap: () =>
                                  _openAddForm(context, defaultCategory: c),
                              onEditTap: (p) =>
                                  _openEditForm(context, p, c),
                              onDeleteTap: (p) =>
                                  _confirmDelete(context, p, c),
                            ))
                        .toList(),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Product product, String category) async {
    final bloc = context.read<HomeBloc>();
    final inCart =
        bloc.state.cartItems.any((i) => i.product.id == product.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text(inCart
            ? '"${product.name}" is in the active order. Deleting will remove it from the cart too.'
            : 'Delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(HomeCatalogProductDeleted(
          category: category, productId: product.id));
    }
  }
}

class _CategoryItemList extends StatelessWidget {
  const _CategoryItemList({
    required this.category,
    required this.onAddTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  final String category;
  final VoidCallback onAddTap;
  final void Function(Product) onEditTap;
  final void Function(Product) onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.itemsByCategory != curr.itemsByCategory,
      builder: (context, state) {
        final items = state.itemsByCategory[category] ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                const Text('No items in this category'),
                TextButton(
                  onPressed: onAddTap,
                  child: const Text('Add Item'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: items.length + 1,
          separatorBuilder: (_, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index < items.length) {
              final product = items[index];
              return _ProductListTile(
                product: product,
                onEdit: () => onEditTap(product),
                onDelete: () => onDeleteTap(product),
              );
            }
            return _AddItemTile(onTap: onAddTap);
          },
        );
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final additionCount = product.additions.length;
    return ListTile(
      leading: CircleAvatar(
        child: Text(product.name[0].toUpperCase()),
      ),
      title: Text(product.name,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Row(
        children: [
          PriceText(product.price),
          if (additionCount > 0)
            Text(
              ' · $additionCount addition${additionCount == 1 ? '' : 's'}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
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

class _AddItemTile extends StatelessWidget {
  const _AddItemTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.add_circle_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Add item',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: onTap,
    );
  }
}
