import 'package:atomikpos/data/models/cart_item.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

enum HomeStatus { initial, loading, success, failure }

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default([]) List<String> categories,
    @Default({}) Map<String, List<Product>> itemsByCategory,
    @Default({}) Map<String, List<Product>> initialItemsByCategory,
    @Default('') String searchTerm,
    @Default([]) List<CartItem> cartItems,
  }) = _HomeState;
}
