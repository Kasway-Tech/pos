import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required Product product,
    required double quantity,
    @Default([]) List<Addition> selectedAdditions,
  }) = _CartItem;

  const CartItem._();

  double get totalPrice {
    final additionPrice = selectedAdditions.fold<double>(
      0,
      (sum, addition) => sum + addition.price,
    );
    return (product.price + additionPrice) * quantity;
  }

  /// Returns total in KAS only if all components have kasPrice set.
  /// Returns null if any component is missing kasPrice (fall back to IDR).
  double? get totalKas {
    final pk = product.kasPrice;
    if (pk == null) return null;
    double addKas = 0;
    for (final a in selectedAdditions) {
      if (a.kasPrice == null) return null;
      addKas += a.kasPrice!;
    }
    return (pk + addKas) * quantity;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
