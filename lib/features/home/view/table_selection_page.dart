import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/features/home/view/widgets/table_canvas.dart';

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({super.key});

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  String? _hoveredId;

  void _selectTable(BuildContext context, String id) {
    final cubit = context.read<TableCubit>();
    final table = cubit.state.tables.firstWhere((t) => t.id == id);
    if (table.isOccupied) return;
    cubit.selectTable(id);
    context.pop();
  }

  Future<void> _onTableLongPress(BuildContext context, String id) async {
    final tableCubit = context.read<TableCubit>();
    final table = tableCubit.state.tables.firstWhere((t) => t.id == id);
    if (!table.isOccupied) return;

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.l10n.tableSelectTableLabel(table.label),
                  style: Theme.of(sheetContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              if (!table.isServed)
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.green),
                  title: Text(context.l10n.tableSelectMarkAsServed),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    tableCubit.markServed(id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.event_seat_outlined,
                    color: Colors.orange),
                title: Text(context.l10n.tableSelectFreeTable),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmFreeTable(context, tableCubit, id, table.label);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmFreeTable(
    BuildContext context,
    TableCubit tableCubit,
    String id,
    String label,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.tableSelectFreeTableTitle),
        content: Text(context.l10n.tableSelectFreeTableContent(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.categoryCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              context.l10n.tableSelectFreeTable,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      tableCubit.freeTable(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tableSelectTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<TableCubit, TableState>(
        builder: (context, state) {
          if (state.tables.isEmpty) {
            return _EmptyState(
              onGoToLayout: () {
                context.pop();
                context.push('/profile/table-layout');
              },
            );
          }
          return Column(
            children: [
              // Canvas (read-only)
              Expanded(
                child: TableCanvas(
                  tables: state.tables,
                  editMode: false,
                  selectedTableId: _hoveredId,
                  onTableTap: (id) => _selectTable(context, id),
                  onTableLongPress: (id) => _onTableLongPress(context, id),
                ),
              ),
              // Horizontal chip list
              _TableChipList(
                tables: state.tables,
                onSelect: (id) => _selectTable(context, id),
                onLongPress: (id) => _onTableLongPress(context, id),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TableChipList extends StatelessWidget {
  const _TableChipList({
    required this.tables,
    required this.onSelect,
    required this.onLongPress,
  });

  final List<TableItem> tables;
  final void Function(String id) onSelect;
  final void Function(String id) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: tables.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final table = tables[index];
          final chipBg = tableColors(
            table,
            Theme.of(context).colorScheme,
          ).chip;
          return GestureDetector(
            onLongPress: table.isOccupied ? () => onLongPress(table.id) : null,
            onSecondaryTap: table.isOccupied ? () => onLongPress(table.id) : null,
            child: FilterChip(
              label: Text(context.l10n.tableSelectTableLabel(table.label)),
              selected: false,
              backgroundColor: table.isOccupied ? null : chipBg,
              disabledColor: table.isOccupied ? chipBg : null,
              onSelected: table.isOccupied ? null : (_) => onSelect(table.id),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onGoToLayout});
  final VoidCallback onGoToLayout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.tableSelectNoTables,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tableSelectNoTablesBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: onGoToLayout,
            child: Text(context.l10n.tableSelectGoToLayout),
          ),
        ],
      ),
    );
  }
}
