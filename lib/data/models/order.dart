import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasway/data/models/order_item.dart';

part 'order.freezed.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required double totalIdr,
    required DateTime createdAt,
    @Default(0.0) double kasAmount,
    @Default(0.0) double kasIdrRate,
    @Default('') String txId,
    @Default([]) List<OrderItem> items,
  }) = _Order;
}
