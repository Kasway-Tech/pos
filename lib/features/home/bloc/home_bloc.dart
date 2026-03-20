import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:bloc/bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
  })  : _productRepository = productRepository,
        _orderRepository = orderRepository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeProductAdded>(_onProductAdded);
    on<HomeProductWithAdditionsAdded>(_onProductWithAdditionsAdded);
    on<HomeProductRemoved>(_onProductRemoved);
    on<HomeCartCleared>(_onCartCleared);
    on<HomeCartQuantityUpdated>(_onCartQuantityUpdated);
    on<HomeSearchTermChanged>(_onSearchTermChanged);
    on<HomeCatalogProductAdded>(_onCatalogProductAdded);
    on<HomeCatalogProductUpdated>(_onCatalogProductUpdated);
    on<HomeCatalogProductDeleted>(_onCatalogProductDeleted);
    on<HomeCategoryAdded>(_onCategoryAdded);
    on<HomeCategoryRenamed>(_onCategoryRenamed);
    on<HomeCategoryDeleted>(_onCategoryDeleted);
    on<HomeOrderCompleted>(_onOrderCompleted);
  }

  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final categories = await _productRepository.getCategories();
      final itemsByCategory = <String, List<Product>>{};

      for (final category in categories) {
        itemsByCategory[category] =
            await _productRepository.getProductsByCategory(category);
      }

      emit(state.copyWith(
        status: HomeStatus.success,
        categories: categories,
        itemsByCategory: itemsByCategory,
        initialItemsByCategory: itemsByCategory,
      ));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  void _onProductAdded(HomeProductAdded event, Emitter<HomeState> emit) {
    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere(
      (item) =>
          item.product.id == event.product.id && item.selectedAdditions.isEmpty,
    );

    if (index >= 0) {
      final newQuantity = cartItems[index].quantity + 1;
      if (newQuantity <= 99) {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      } else {
        return;
      }
    } else {
      cartItems.add(CartItem(product: event.product, quantity: 1));
    }

    emit(state.copyWith(cartItems: cartItems));
  }

  void _onProductWithAdditionsAdded(
    HomeProductWithAdditionsAdded event,
    Emitter<HomeState> emit,
  ) {
    final cartItems = List<CartItem>.from(state.cartItems);

    final index = cartItems.indexWhere(
      (item) =>
          item.product.id == event.product.id &&
          _compareAdditions(item.selectedAdditions, event.selectedAdditions),
    );

    if (index >= 0) {
      final newQuantity = cartItems[index].quantity + 1;
      if (newQuantity <= 99) {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      } else {
        return;
      }
    } else {
      cartItems.add(
        CartItem(
          product: event.product,
          quantity: 1,
          selectedAdditions: event.selectedAdditions,
        ),
      );
    }
    emit(state.copyWith(cartItems: cartItems));
  }

  bool _compareAdditions(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds) && bIds.containsAll(aIds);
  }

  void _onProductRemoved(HomeProductRemoved event, Emitter<HomeState> emit) {
    final cartItems = List<CartItem>.from(state.cartItems);
    cartItems.removeWhere((item) => item.product.id == event.product.id);
    emit(state.copyWith(cartItems: cartItems));
  }

  void _onCartQuantityUpdated(
    HomeCartQuantityUpdated event,
    Emitter<HomeState> emit,
  ) {
    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere(
      (item) =>
          item.product.id == event.product.id &&
          _compareAdditions(item.selectedAdditions, event.selectedAdditions),
    );

    if (index >= 0) {
      if (event.quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(
          quantity: event.quantity.clamp(1, 99),
        );
      }
      emit(state.copyWith(cartItems: cartItems));
    }
  }

  void _onCartCleared(HomeCartCleared event, Emitter<HomeState> emit) {
    emit(state.copyWith(cartItems: []));
  }

  void _onSearchTermChanged(
    HomeSearchTermChanged event,
    Emitter<HomeState> emit,
  ) {
    final searchTerm = event.searchTerm.toLowerCase();
    final itemsByCategory = <String, List<Product>>{};

    for (final category in state.categories) {
      final initialItems = state.initialItemsByCategory[category] ?? [];
      if (searchTerm.isEmpty) {
        itemsByCategory[category] = initialItems;
      } else {
        itemsByCategory[category] = initialItems
            .where((p) => p.name.toLowerCase().contains(searchTerm))
            .toList();
      }
    }

    emit(state.copyWith(
      searchTerm: event.searchTerm,
      itemsByCategory: itemsByCategory,
    ));
  }

  Future<void> _onCatalogProductAdded(
    HomeCatalogProductAdded event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final List<Product> newList = [
      ...(state.itemsByCategory[event.category] ?? []),
      event.product,
    ];
    final updated = Map<String, List<Product>>.from(state.itemsByCategory)
      ..[event.category] = newList;
    final initial = Map<String, List<Product>>.from(state.initialItemsByCategory)
      ..[event.category] = newList;
    emit(state.copyWith(
        itemsByCategory: updated, initialItemsByCategory: initial));
    try {
      await _productRepository.insertProduct(event.product, event.category);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onCatalogProductUpdated(
    HomeCatalogProductUpdated event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final updated = Map<String, List<Product>>.from(state.itemsByCategory);
    final initial =
        Map<String, List<Product>>.from(state.initialItemsByCategory);

    // Remove from old category
    for (final map in [updated, initial]) {
      map[event.oldCategory] = (map[event.oldCategory] ?? [])
          .where((p) => p.id != event.product.id)
          .toList();
    }

    // Insert into new category (or update in place if same)
    for (final map in [updated, initial]) {
      final list = List<Product>.from(map[event.category] ?? []);
      if (event.oldCategory == event.category) {
        final i = list.indexWhere((p) => p.id == event.product.id);
        if (i >= 0) {
          list[i] = event.product;
        } else {
          list.add(event.product);
        }
      } else {
        list.add(event.product);
      }
      map[event.category] = list;
    }

    // Sync active cart
    final updatedCart = state.cartItems
        .map((item) => item.product.id == event.product.id
            ? item.copyWith(product: event.product)
            : item)
        .toList();

    emit(state.copyWith(
      itemsByCategory: updated,
      initialItemsByCategory: initial,
      cartItems: updatedCart,
    ));
    try {
      await _productRepository.updateProduct(event.product, event.category);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onCatalogProductDeleted(
    HomeCatalogProductDeleted event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final updated = Map<String, List<Product>>.from(state.itemsByCategory);
    final initial =
        Map<String, List<Product>>.from(state.initialItemsByCategory);
    for (final map in [updated, initial]) {
      map[event.category] = (map[event.category] ?? [])
          .where((p) => p.id != event.productId)
          .toList();
    }
    final updatedCart = state.cartItems
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(
      itemsByCategory: updated,
      initialItemsByCategory: initial,
      cartItems: updatedCart,
    ));
    try {
      await _productRepository.deleteProduct(event.productId);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onCategoryAdded(
    HomeCategoryAdded event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final cats = [...state.categories, event.name];
    final updated = {...state.itemsByCategory, event.name: <Product>[]};
    final initial = {
      ...state.initialItemsByCategory,
      event.name: <Product>[],
    };
    emit(state.copyWith(
        categories: cats,
        itemsByCategory: updated,
        initialItemsByCategory: initial));
    try {
      await _productRepository.insertCategory(event.name, cats.length - 1);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onCategoryRenamed(
    HomeCategoryRenamed event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final cats = state.categories
        .map((c) => c == event.oldName ? event.newName : c)
        .toList();

    Map<String, List<Product>> rekey(Map<String, List<Product>> m) => {
          for (final e in m.entries)
            (e.key == event.oldName ? event.newName : e.key): e.value,
        };

    emit(state.copyWith(
      categories: cats,
      itemsByCategory: rekey(state.itemsByCategory),
      initialItemsByCategory: rekey(state.initialItemsByCategory),
    ));
    try {
      await _productRepository.renameCategory(event.oldName, event.newName);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onCategoryDeleted(
    HomeCategoryDeleted event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    final cats = state.categories.where((c) => c != event.name).toList();
    final updated = Map<String, List<Product>>.from(state.itemsByCategory)
      ..remove(event.name);
    final initial =
        Map<String, List<Product>>.from(state.initialItemsByCategory)
          ..remove(event.name);
    emit(state.copyWith(
        categories: cats,
        itemsByCategory: updated,
        initialItemsByCategory: initial));
    try {
      await _productRepository.deleteCategory(event.name);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> _onOrderCompleted(
    HomeOrderCompleted event,
    Emitter<HomeState> emit,
  ) async {
    // Fire-and-forget: persist the order; no state change needed.
    try {
      await _orderRepository.createOrder(
        totalIdr: event.totalIdr,
        kasAmount: event.kasAmount,
        kasIdrRate: event.kasIdrRate,
        txId: event.txId,
        cartItems: event.cartItems,
      );
    } catch (_) {
      // Silently ignore — revenue tracking should not block order flow.
    }
  }
}
