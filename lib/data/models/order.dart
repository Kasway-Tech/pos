import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required double totalIdr,
    required DateTime createdAt,
  }) = _Order;
}
