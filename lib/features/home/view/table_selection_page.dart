import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    final table =
        context.read<TableCubit>().state.tables.firstWhere((t) => t.id == id);
    if (table.isOccupied) return;
    context.read<TableCubit>().selectTable(id);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Table'),
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
                ),
              ),
              // Horizontal chip list
              _TableChipList(
                tables: state.tables,
                onSelect: (id) => _selectTable(context, id),
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
  });

  final List<TableItem> tables;
  final void Function(String id) onSelect;

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
          return FilterChip(
            label: Text('Table ${table.label}'),
            selected: !table.isOccupied,
            onSelected: table.isOccupied ? null : (_) => onSelect(table.id),
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            disabledColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
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
            'No tables configured',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your floor plan in Profile > Table Layout.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: onGoToLayout,
            child: const Text('Go to Table Layout'),
          ),
        ],
      ),
    );
  }
}
