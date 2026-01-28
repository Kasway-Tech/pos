import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:bloc/bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required ProductRepository productRepository})
    : _productRepository = productRepository,
      super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeProductAdded>(_onProductAdded);
    on<HomeProductWithAdditionsAdded>(_onProductWithAdditionsAdded);
    on<HomeProductRemoved>(_onProductRemoved);
    on<HomeCartCleared>(_onCartCleared);
    on<HomeCartQuantityUpdated>(_onCartQuantityUpdated);
    on<HomeSearchTermChanged>(_onSearchTermChanged);
  }

  final ProductRepository _productRepository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final categories = ['Promo', 'Makanan', 'Minuman', 'Paket', 'Lainnya'];
      final itemsByCategory = <String, List<Product>>{};

      for (final category in categories) {
        final products = await _productRepository.getProductsByCategory(
          category,
        );
        itemsByCategory[category] = products;
      }

      emit(
        state.copyWith(
          status: HomeStatus.success,
          categories: categories,
          itemsByCategory: itemsByCategory,
          initialItemsByCategory: itemsByCategory,
        ),
      );
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
        return; // Don't emit if already at max
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

    // Find existing item with same product ID and same additions
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
        return; // Don't emit if already at max
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

    emit(
      state.copyWith(
        searchTerm: event.searchTerm,
        itemsByCategory: itemsByCategory,
      ),
    );
  }
}
