import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String productName,
    required double unitPrice,
    required int quantity,
    @Default([]) List<OrderItemAddition> additions,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
abstract class OrderItemAddition with _$OrderItemAddition {
  const factory OrderItemAddition({
    required String name,
    required double price,
  }) = _OrderItemAddition;

  factory OrderItemAddition.fromJson(Map<String, dynamic> json) =>
      _$OrderItemAdditionFromJson(json);
}
