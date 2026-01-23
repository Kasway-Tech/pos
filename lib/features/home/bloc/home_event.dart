import 'package:atomikpos/data/models/product.dart';
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

class HomeProductRemoved extends HomeEvent {
  const HomeProductRemoved(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
}

class HomeCartCleared extends HomeEvent {}
