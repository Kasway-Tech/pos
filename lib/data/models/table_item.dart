import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_item.freezed.dart';

@freezed
abstract class TableItem with _$TableItem {
  const TableItem._();
  const factory TableItem({
    required String id,
    required String label,
    required int seats,
    required double x,
    required double y,
    @Default(0.0) double rotation,
    @Default(false) bool isOccupied,
    @Default(false) bool isServed,
    String? groupId,
  }) = _TableItem;
}
