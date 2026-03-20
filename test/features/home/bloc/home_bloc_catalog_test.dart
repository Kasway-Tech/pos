import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class _FakeProduct extends Fake implements Product {}

class _FakeCartItem extends Fake implements CartItem {}

// ─── Fixture helpers ─────────────────────────────────────────────────────────

Product _product({
  String id = 'p1',
  String name = 'Coffee',
  double price = 15000,
}) =>
    Product(id: id, name: name, price: price);

HomeState _catalogState({
  List<String>? categories,
  Map<String, List<Product>>? items,
}) {
  final cats = categories ?? ['Food', 'Drinks'];
  final map = items ??
      {
        'Food': [_product(id: 'p1', name: 'Burger')],
        'Drinks': [_product(id: 'p2', name: 'Cola')],
      };
  return HomeState(
    status: HomeStatus.success,
    categories: cats,
    itemsByCategory: map,
    initialItemsByCategory: map,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProduct());
    registerFallbackValue(_FakeCartItem());
    registerFallbackValue(<CartItem>[]);
  });

  late MockProductRepository productRepo;
  late MockOrderRepository orderRepo;

  setUp(() {
    productRepo = MockProductRepository();
    orderRepo = MockOrderRepository();

    // Default no-op stubs (overridden in specific tests)
    when(() => productRepo.insertProduct(any(), any()))
        .thenAnswer((_) async {});
    when(() => productRepo.updateProduct(any(), any()))
        .thenAnswer((_) async {});
    when(() => productRepo.deleteProduct(any())).thenAnswer((_) async {});
    when(() => productRepo.insertCategory(any(), any()))
        .thenAnswer((_) async {});
    when(() => productRepo.renameCategory(any(), any()))
        .thenAnswer((_) async {});
    when(() => productRepo.deleteCategory(any())).thenAnswer((_) async {});
    when(() => orderRepo.createOrder(
          totalIdr: any(named: 'totalIdr'),
          kasAmount: any(named: 'kasAmount'),
          kasIdrRate: any(named: 'kasIdrRate'),
          txId: any(named: 'txId'),
          network: any(named: 'network'),
          cartItems: any(named: 'cartItems'),
        )).thenAnswer((_) async {});
  });

  HomeBloc buildBloc() => HomeBloc(
        productRepository: productRepo,
        orderRepository: orderRepo,
      );

  // ─── HomeCatalogProductAdded ────────────────────────────────────────────────

  group('HomeCatalogProductAdded', () {
    final newProduct = _product(id: 'p3', name: 'Tea');
    final seed = _catalogState();

    blocTest<HomeBloc, HomeState>(
      'optimistically adds product to category',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductAdded(
        category: 'Drinks',
        product: newProduct,
      )),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.itemsByCategory['Drinks'],
          'Drinks contains new product',
          contains(newProduct),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'adds product to both itemsByCategory and initialItemsByCategory',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductAdded(
        category: 'Food',
        product: newProduct,
      )),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Food'], contains(newProduct));
        expect(bloc.state.initialItemsByCategory['Food'], contains(newProduct));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls insertProduct with correct arguments',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductAdded(
        category: 'Food',
        product: newProduct,
      )),
      verify: (_) {
        verify(() => productRepo.insertProduct(newProduct, 'Food')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back to previous state when insertProduct throws',
      setUp: () {
        when(() => productRepo.insertProduct(any(), any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductAdded(
        category: 'Food',
        product: newProduct,
      )),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.itemsByCategory['Food'], 'Food has new product', contains(newProduct)),
        seed, // rollback
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'adds first product when category had empty list',
      build: buildBloc,
      seed: () => HomeState(
        status: HomeStatus.success,
        categories: ['Empty'],
        itemsByCategory: {'Empty': []},
        initialItemsByCategory: {'Empty': []},
      ),
      act: (bloc) => bloc.add(HomeCatalogProductAdded(
        category: 'Empty',
        product: newProduct,
      )),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Empty'], [newProduct]);
      },
    );
  });

  // ─── HomeCatalogProductUpdated ──────────────────────────────────────────────

  group('HomeCatalogProductUpdated', () {
    final original = _product(id: 'p1', name: 'Burger', price: 15000);
    final updated = _product(id: 'p1', name: 'Cheeseburger', price: 20000);
    final seed = _catalogState(items: {
      'Food': [original],
      'Drinks': [],
    });

    blocTest<HomeBloc, HomeState>(
      'updates product within same category',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductUpdated(
        oldCategory: 'Food',
        category: 'Food',
        product: updated,
      )),
      verify: (bloc) {
        final food = bloc.state.itemsByCategory['Food']!;
        expect(food.length, 1);
        expect(food.first.name, 'Cheeseburger');
        expect(food.first.price, 20000);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'moves product to new category',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductUpdated(
        oldCategory: 'Food',
        category: 'Drinks',
        product: updated,
      )),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Food'], isEmpty);
        expect(bloc.state.itemsByCategory['Drinks'], contains(updated));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'syncs updated product in cart',
      build: buildBloc,
      seed: () => seed.copyWith(
        cartItems: [CartItem(product: original, quantity: 2)],
      ),
      act: (bloc) => bloc.add(HomeCatalogProductUpdated(
        oldCategory: 'Food',
        category: 'Food',
        product: updated,
      )),
      verify: (bloc) {
        final cartItem = bloc.state.cartItems.first;
        expect(cartItem.product.name, 'Cheeseburger');
        expect(cartItem.quantity, 2); // quantity preserved
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls updateProduct with correct arguments',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductUpdated(
        oldCategory: 'Food',
        category: 'Food',
        product: updated,
      )),
      verify: (_) {
        verify(() => productRepo.updateProduct(updated, 'Food')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back to previous state when updateProduct throws',
      setUp: () {
        when(() => productRepo.updateProduct(any(), any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(HomeCatalogProductUpdated(
        oldCategory: 'Food',
        category: 'Food',
        product: updated,
      )),
      expect: () => [
        isA<HomeState>(), // optimistic
        seed,              // rollback
      ],
    );
  });

  // ─── HomeCatalogProductDeleted ──────────────────────────────────────────────

  group('HomeCatalogProductDeleted', () {
    final product = _product(id: 'p1', name: 'Burger');
    final seed = _catalogState(items: {
      'Food': [product],
      'Drinks': [],
    });

    blocTest<HomeBloc, HomeState>(
      'removes product from category',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'p1')),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Food'], isEmpty);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'removes product from cart when deleted',
      build: buildBloc,
      seed: () => seed.copyWith(
        cartItems: [CartItem(product: product, quantity: 1)],
      ),
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'p1')),
      verify: (bloc) {
        expect(bloc.state.cartItems, isEmpty);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'does not remove other products from cart',
      build: buildBloc,
      seed: () {
        final other = _product(id: 'p2', name: 'Cola');
        return _catalogState(items: {
          'Food': [product],
          'Drinks': [other],
        }).copyWith(cartItems: [
          CartItem(product: product, quantity: 1),
          CartItem(product: other, quantity: 2),
        ]);
      },
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'p1')),
      verify: (bloc) {
        expect(bloc.state.cartItems.length, 1);
        expect(bloc.state.cartItems.first.product.id, 'p2');
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls deleteProduct with correct id',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'p1')),
      verify: (_) {
        verify(() => productRepo.deleteProduct('p1')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back when deleteProduct throws',
      setUp: () {
        when(() => productRepo.deleteProduct(any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'p1')),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.itemsByCategory['Food'],
          'Food is temporarily empty',
          isEmpty,
        ),
        seed, // rollback
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'deleting non-existent product ID is a no-op (empty list stays empty)',
      build: buildBloc,
      seed: () => _catalogState(items: {'Food': [], 'Drinks': []}),
      act: (bloc) =>
          bloc.add(HomeCatalogProductDeleted(category: 'Food', productId: 'nonexistent')),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Food'], isEmpty);
      },
    );
  });

  // ─── HomeCategoryAdded ──────────────────────────────────────────────────────

  group('HomeCategoryAdded', () {
    final seed = _catalogState();

    blocTest<HomeBloc, HomeState>(
      'appends new category to categories list',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryAdded('Desserts')),
      verify: (bloc) {
        expect(bloc.state.categories, contains('Desserts'));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'initializes empty product list for new category',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryAdded('Desserts')),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory['Desserts'], isEmpty);
        expect(bloc.state.initialItemsByCategory['Desserts'], isEmpty);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls insertCategory with correct name and sort_order',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryAdded('Desserts')),
      verify: (_) {
        // seed has 2 categories, new one gets index 2
        verify(() => productRepo.insertCategory('Desserts', 2)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back when insertCategory throws',
      setUp: () {
        when(() => productRepo.insertCategory(any(), any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryAdded('Desserts')),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.categories, 'categories', contains('Desserts')),
        seed, // rollback
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'adding a category to empty list sets sort_order 0',
      build: buildBloc,
      seed: () => const HomeState(status: HomeStatus.success),
      act: (bloc) => bloc.add(const HomeCategoryAdded('First')),
      verify: (_) {
        verify(() => productRepo.insertCategory('First', 0)).called(1);
      },
    );
  });

  // ─── HomeCategoryRenamed ────────────────────────────────────────────────────

  group('HomeCategoryRenamed', () {
    final food = _product(id: 'p1', name: 'Burger');
    final seed = _catalogState(
      categories: ['Food', 'Drinks'],
      items: {
        'Food': [food],
        'Drinks': [],
      },
    );

    blocTest<HomeBloc, HomeState>(
      'renames category in categories list',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(
          const HomeCategoryRenamed(oldName: 'Food', newName: 'Snacks')),
      verify: (bloc) {
        expect(bloc.state.categories, contains('Snacks'));
        expect(bloc.state.categories, isNot(contains('Food')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rekeys itemsByCategory to new name',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(
          const HomeCategoryRenamed(oldName: 'Food', newName: 'Snacks')),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory.containsKey('Food'), isFalse);
        expect(bloc.state.itemsByCategory['Snacks'], contains(food));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rekeys initialItemsByCategory to new name',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(
          const HomeCategoryRenamed(oldName: 'Food', newName: 'Snacks')),
      verify: (bloc) {
        expect(bloc.state.initialItemsByCategory.containsKey('Food'), isFalse);
        expect(bloc.state.initialItemsByCategory['Snacks'], contains(food));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls renameCategory with correct old and new names',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(
          const HomeCategoryRenamed(oldName: 'Food', newName: 'Snacks')),
      verify: (_) {
        verify(() => productRepo.renameCategory('Food', 'Snacks')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back when renameCategory throws',
      setUp: () {
        when(() => productRepo.renameCategory(any(), any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(
          const HomeCategoryRenamed(oldName: 'Food', newName: 'Snacks')),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.categories,
          'optimistic rename',
          contains('Snacks'),
        ),
        seed, // rollback
      ],
    );
  });

  // ─── HomeCategoryDeleted ────────────────────────────────────────────────────

  group('HomeCategoryDeleted', () {
    final seed = _catalogState(
      categories: ['Food', 'Drinks'],
      items: {
        'Food': [],
        'Drinks': [],
      },
    );

    blocTest<HomeBloc, HomeState>(
      'removes category from list',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryDeleted('Food')),
      verify: (bloc) {
        expect(bloc.state.categories, isNot(contains('Food')));
        expect(bloc.state.categories, contains('Drinks'));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'removes category key from itemsByCategory and initialItemsByCategory',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryDeleted('Food')),
      verify: (bloc) {
        expect(bloc.state.itemsByCategory.containsKey('Food'), isFalse);
        expect(bloc.state.initialItemsByCategory.containsKey('Food'), isFalse);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls deleteCategory with correct name',
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryDeleted('Food')),
      verify: (_) {
        verify(() => productRepo.deleteCategory('Food')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'rolls back when deleteCategory throws',
      setUp: () {
        when(() => productRepo.deleteCategory(any()))
            .thenThrow(Exception('DB error'));
      },
      build: buildBloc,
      seed: () => seed,
      act: (bloc) => bloc.add(const HomeCategoryDeleted('Food')),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.categories,
          'optimistic delete',
          isNot(contains('Food')),
        ),
        seed, // rollback
      ],
    );
  });

  // ─── HomeProductRemoved ─────────────────────────────────────────────────────

  group('HomeProductRemoved', () {
    final p1 = _product(id: 'p1');
    final p2 = _product(id: 'p2', name: 'Tea');

    blocTest<HomeBloc, HomeState>(
      'removes product from cart (all quantities)',
      build: buildBloc,
      seed: () => HomeState(cartItems: [
        CartItem(product: p1, quantity: 3),
        CartItem(product: p2, quantity: 1),
      ]),
      act: (bloc) => bloc.add(HomeProductRemoved(p1)),
      verify: (bloc) {
        expect(bloc.state.cartItems.length, 1);
        expect(bloc.state.cartItems.first.product.id, 'p2');
      },
    );

    blocTest<HomeBloc, HomeState>(
      'removing a product not in cart emits same state (no-op emit)',
      build: buildBloc,
      seed: () => HomeState(cartItems: [CartItem(product: p2, quantity: 1)]),
      act: (bloc) => bloc.add(HomeProductRemoved(p1)),
      verify: (bloc) {
        // p2 still in cart
        expect(bloc.state.cartItems.length, 1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'clears cart when only item is removed',
      build: buildBloc,
      seed: () => HomeState(cartItems: [CartItem(product: p1, quantity: 5)]),
      act: (bloc) => bloc.add(HomeProductRemoved(p1)),
      expect: () => [const HomeState(cartItems: [])],
    );
  });

  // ─── HomeOrderCompleted ─────────────────────────────────────────────────────

  group('HomeOrderCompleted', () {
    final cartItem = CartItem(
      product: _product(id: 'p1', name: 'Coffee', price: 15000),
      quantity: 2,
    );

    blocTest<HomeBloc, HomeState>(
      'does not emit any state — fire and forget',
      build: buildBloc,
      act: (bloc) => bloc.add(HomeOrderCompleted(
        totalIdr: 30000,
        cartItems: [cartItem],
        kasAmount: 20.0,
        kasIdrRate: 1500.0,
        txId: 'abc123',
        network: 'mainnet',
      )),
      expect: () => [],
    );

    blocTest<HomeBloc, HomeState>(
      'calls orderRepository.createOrder with correct args',
      build: buildBloc,
      act: (bloc) => bloc.add(HomeOrderCompleted(
        totalIdr: 30000,
        cartItems: [cartItem],
        kasAmount: 20.0,
        kasIdrRate: 1500.0,
        txId: 'tx-001',
        network: 'mainnet',
      )),
      verify: (_) {
        verify(() => orderRepo.createOrder(
              totalIdr: 30000,
              kasAmount: 20.0,
              kasIdrRate: 1500.0,
              txId: 'tx-001',
              network: 'mainnet',
              cartItems: [cartItem],
            )).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'silently ignores repository throw — no error propagated',
      setUp: () {
        when(() => orderRepo.createOrder(
              totalIdr: any(named: 'totalIdr'),
              kasAmount: any(named: 'kasAmount'),
              kasIdrRate: any(named: 'kasIdrRate'),
              txId: any(named: 'txId'),
              network: any(named: 'network'),
              cartItems: any(named: 'cartItems'),
            )).thenThrow(Exception('DB failure'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(HomeOrderCompleted(
        totalIdr: 30000,
        cartItems: [cartItem],
        kasAmount: 20.0,
        kasIdrRate: 1500.0,
        txId: 'tx-001',
        network: 'mainnet',
      )),
      expect: () => [], // no state emitted and no error thrown
    );

    blocTest<HomeBloc, HomeState>(
      'handles empty cartItems list without error',
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeOrderCompleted(
        totalIdr: 0,
        cartItems: [],
        kasAmount: 0,
        kasIdrRate: 0,
        txId: '',
        network: 'mainnet',
      )),
      expect: () => [],
    );
  });

  // ─── HomeCartQuantityUpdated — boundary ─────────────────────────────────────

  group('HomeCartQuantityUpdated — additional edge cases', () {
    final p = _product();

    blocTest<HomeBloc, HomeState>(
      'negative quantity removes item (treated as <= 0)',
      build: buildBloc,
      seed: () => HomeState(cartItems: [CartItem(product: p, quantity: 2)]),
      act: (bloc) => bloc.add(HomeCartQuantityUpdated(p, -1)),
      verify: (bloc) {
        expect(bloc.state.cartItems, isEmpty);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'quantity exactly 1 keeps item',
      build: buildBloc,
      seed: () => HomeState(cartItems: [CartItem(product: p, quantity: 5)]),
      act: (bloc) => bloc.add(HomeCartQuantityUpdated(p, 1)),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.cartItems.first.quantity,
          'quantity',
          1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'no state emitted when product not found in cart',
      build: buildBloc,
      seed: () => HomeState(
        cartItems: [CartItem(product: _product(id: 'other'), quantity: 2)],
      ),
      act: (bloc) =>
          bloc.add(HomeCartQuantityUpdated(_product(id: 'notfound'), 5)),
      expect: () => [],
    );
  });

  // ─── HomeProductWithAdditionsAdded — max quantity ───────────────────────────

  group('HomeProductWithAdditionsAdded — max quantity boundary', () {
    final p = _product();
    final add = const Addition(id: 'a1', name: 'Cheese', price: 500);

    blocTest<HomeBloc, HomeState>(
      'does not exceed 99 for product with additions',
      build: buildBloc,
      seed: () => HomeState(
        cartItems: [
          CartItem(product: p, quantity: 99, selectedAdditions: [add]),
        ],
      ),
      act: (bloc) =>
          bloc.add(HomeProductWithAdditionsAdded(p, [add])),
      expect: () => [], // capped, no emission
    );
  });
}
