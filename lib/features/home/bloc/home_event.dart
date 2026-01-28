import 'package:kasway/data/models/addition.dart';
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
