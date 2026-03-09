import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/repositories/transaction_repository.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:bloc/bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
  })  : _productRepository = productRepository,
        _transactionRepository = transactionRepository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeProductAdded>(_onProductAdded);
    on<HomeProductWithAdditionsAdded>(_onProductWithAdditionsAdded);
    on<HomeProductRemoved>(_onProductRemoved);
    on<HomeCartCleared>(_onCartCleared);
    on<HomeCartQuantityUpdated>(_onCartQuantityUpdated);
    on<HomeSearchTermChanged>(_onSearchTermChanged);
    on<HomeTransactionSubmitted>(_onTransactionSubmitted);
  }

  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      branchId: event.branchId,
      storeId: event.storeId,
    ));
    try {
      final result = await _productRepository.getItemsForBranch(
        branchId: event.branchId,
        storeId: event.storeId,
      );

      emit(
        state.copyWith(
          status: HomeStatus.success,
          categories: result.categories,
          itemsByCategory: result.itemsByCategory,
          initialItemsByCategory: result.itemsByCategory,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> _onTransactionSubmitted(
    HomeTransactionSubmitted event,
    Emitter<HomeState> emit,
  ) async {
    final storeId = state.storeId;
    if (storeId == null) return;

    emit(state.copyWith(transactionStatus: TransactionStatus.saving));
    try {
      final total = state.cartItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      await _transactionRepository.saveTransaction(
        storeId: storeId,
        paymentMethod: event.paymentMethod,
        cartItems: state.cartItems,
        totalAmount: total,
      );
      emit(state.copyWith(
        transactionStatus: TransactionStatus.saved,
        cartItems: [],
      ));
    } catch (_) {
      emit(state.copyWith(transactionStatus: TransactionStatus.failure));
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

    emit(
      state.copyWith(
        searchTerm: event.searchTerm,
        itemsByCategory: itemsByCategory,
      ),
    );
  }
}
