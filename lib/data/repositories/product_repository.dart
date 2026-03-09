import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches items grouped by category name for a given branch.
  /// If the branch has no entries in branch_items, all store items are returned.
  Future<({List<String> categories, Map<String, List<Product>> itemsByCategory})>
      getItemsForBranch({
    required String branchId,
    required String storeId,
  }) async {
    // Check if the branch restricts to specific items
    final branchItemRows = await _client
        .from('branch_items')
        .select('item_id')
        .eq('branch_id', branchId);

    final branchItemIds = (branchItemRows as List)
        .map((r) => r['item_id'] as String)
        .toList();

    // Fetch categories for this store (preserves defined order)
    final categoryRows = await _client
        .from('categories')
        .select('id, name')
        .eq('store_id', storeId);

    final categoryIdToName = {
      for (final row in categoryRows as List)
        row['id'] as String: row['name'] as String,
    };
    final categories = categoryRows
        .map((r) => r['name'] as String)
        .toList()
        .cast<String>();

    // Fetch items with their additions
    final baseQuery = _client
        .from('items')
        .select('id, name, price, category_id, item_additions(id, name, price)')
        .eq('store_id', storeId);

    final filteredQuery = branchItemIds.isEmpty
        ? baseQuery
        : baseQuery.inFilter('id', branchItemIds);

    final itemRows = await filteredQuery.order('sequence');

    // Group products by category name
    final itemsByCategory = <String, List<Product>>{
      for (final c in categories) c: [],
    };

    for (final row in itemRows as List) {
      final categoryId = row['category_id'] as String?;
      final categoryName = categoryId != null
          ? categoryIdToName[categoryId] ?? 'General'
          : 'General';

      final additions = (row['item_additions'] as List)
          .map(
            (a) => Addition(
              id: a['id'] as String,
              name: a['name'] as String,
              price: (a['price'] as num).toDouble(),
            ),
          )
          .toList();

      final product = Product(
        id: row['id'] as String,
        name: row['name'] as String,
        price: (row['price'] as num).toDouble(),
        additions: additions,
      );

      itemsByCategory.putIfAbsent(categoryName, () => []).add(product);
    }

    // Return only categories that actually have items
    final nonEmptyCategories =
        categories.where((c) => itemsByCategory[c]?.isNotEmpty ?? false).toList();

    return (
      categories: nonEmptyCategories,
      itemsByCategory: itemsByCategory,
    );
  }
}
