import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {}

class HomeProductAdded extends HomeEvent {
  const HomeProductAdded(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
}

class HomeProductWithAdditionsAdded extends HomeEvent {
  const HomeProductWithAdditionsAdded(this.product, this.selectedAdditions);
  final Product product;
  final List<Addition> selectedAdditions;

  @override
  List<Object?> get props => [product, selectedAdditions];
}

class HomeProductRemoved extends HomeEvent {
  const HomeProductRemoved(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
}

class HomeCartQuantityUpdated extends HomeEvent {
  const HomeCartQuantityUpdated(
    this.product,
    this.quantity, {
    this.selectedAdditions = const [],
  });
  final Product product;
  final double quantity;
  final List<Addition> selectedAdditions;

  @override
  List<Object?> get props => [product, quantity, selectedAdditions];
}

class HomeCartCleared extends HomeEvent {}

class HomeSearchTermChanged extends HomeEvent {
  const HomeSearchTermChanged(this.searchTerm);
  final String searchTerm;

  @override
  List<Object?> get props => [searchTerm];
}

// Catalog product events
class HomeCatalogProductAdded extends HomeEvent {
  const HomeCatalogProductAdded({
    required this.category,
    required this.product,
  });
  final String category;
  final Product product;

  @override
  List<Object?> get props => [category, product];
}

class HomeCatalogProductUpdated extends HomeEvent {
  const HomeCatalogProductUpdated({
    required this.oldCategory,
    required this.category,
    required this.product,
  });
  final String oldCategory;
  final String category;
  final Product product;

  @override
  List<Object?> get props => [oldCategory, category, product];
}

class HomeCatalogProductDeleted extends HomeEvent {
  const HomeCatalogProductDeleted({
    required this.category,
    required this.productId,
  });
  final String category;
  final String productId;

  @override
  List<Object?> get props => [category, productId];
}

// Catalog category events
class HomeCategoryAdded extends HomeEvent {
  const HomeCategoryAdded(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

class HomeCategoryRenamed extends HomeEvent {
  const HomeCategoryRenamed({required this.oldName, required this.newName});
  final String oldName;
  final String newName;

  @override
  List<Object?> get props => [oldName, newName];
}

class HomeCategoryDeleted extends HomeEvent {
  const HomeCategoryDeleted(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

class HomeOrderCompleted extends HomeEvent {
  const HomeOrderCompleted({
    required this.totalIdr,
    required this.cartItems,
    required this.kasAmount,
    required this.kasIdrRate,
    required this.txId,
  });
  final double totalIdr;
  final List<CartItem> cartItems;
  final double kasAmount;
  final double kasIdrRate;
  final String txId;

  @override
  List<Object?> get props => [totalIdr, cartItems, kasAmount, kasIdrRate, txId];
}
