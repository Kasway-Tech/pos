import 'package:kasway/data/models/table_item.dart';

// Sentinel value for copyWith to distinguish "set to null" from "keep existing".
const Object _sentinel = Object();

class TableState {
  const TableState({
    this.enabled = false,
    this.tables = const [],
    this.selectedTableId,
  });

  final bool enabled;
  final List<TableItem> tables;
  final String? selectedTableId;

  TableItem? get selectedTable =>
      tables.where((t) => t.id == selectedTableId).firstOrNull;

  TableState copyWith({
    bool? enabled,
    List<TableItem>? tables,
    Object? selectedTableId = _sentinel,
  }) =>
      TableState(
        enabled: enabled ?? this.enabled,
        tables: tables ?? this.tables,
        selectedTableId: selectedTableId == _sentinel
            ? this.selectedTableId
            : selectedTableId as String?,
      );
}
