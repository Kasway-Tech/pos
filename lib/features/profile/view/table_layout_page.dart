import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/data/repositories/table_repository.dart';
import 'package:kasway/features/home/view/widgets/table_canvas.dart';

class TableLayoutPage extends StatefulWidget {
  const TableLayoutPage({super.key});

  @override
  State<TableLayoutPage> createState() => _TableLayoutPageState();
}

class _TableLayoutPageState extends State<TableLayoutPage> {
  late List<TableItem> _tables;
  bool _hasChanges = false;
  bool _featureEnabled = false;

  @override
  void initState() {
    super.initState();
    final tableState = context.read<TableCubit>().state;
    _tables = List.from(tableState.tables);
    _featureEnabled = tableState.enabled;
  }

  void _addTable(int seats) {
    final repo = context.read<TableRepository>();
    final newTable = TableItem(
      id: repo.newId(),
      label: (_tables.length + 1).toString(),
      seats: seats,
      x: 100,
      y: 100 + (_tables.length * 80.0).clamp(0.0, 1200.0),
    );
    setState(() {
      _tables = [..._tables, newTable];
      _hasChanges = true;
    });
  }

  void _removeTable(String id) {
    setState(() {
      _tables = _tables.where((t) => t.id != id).toList();
      _hasChanges = true;
    });
  }

  void _onTableMoved(String id, double x, double y) {
    setState(() {
      _tables = _tables
          .map((t) => t.id == id ? t.copyWith(x: x, y: y) : t)
          .toList();
      _hasChanges = true;
    });
  }

  void _onTableRotated(String id, double rotation) {
    setState(() {
      _tables = _tables
          .map((t) => t.id == id ? t.copyWith(rotation: rotation) : t)
          .toList();
      _hasChanges = true;
    });
  }

  void _onTableTap(String id) {
    final table = _tables.firstWhere((t) => t.id == id);
    _showLabelDialog(table);
  }

  Future<void> _showLabelDialog(TableItem table) async {
    final controller = TextEditingController(text: table.label);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Table Label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Label',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _tables = _tables
            .map((t) => t.id == table.id ? t.copyWith(label: result) : t)
            .toList();
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Discard them and leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    await context.read<TableCubit>().saveLayout(_tables);
    if (mounted) {
      setState(() => _hasChanges = false);
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableCubit, TableState>(
      builder: (context, tableState) {
        return PopScope(
          canPop: !_hasChanges,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              final nav = Navigator.of(context);
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                nav.pop();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Table Layout'),
              centerTitle: true,
              actions: [
                if (_hasChanges)
                  TextButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Feature toggle banner
                _FeatureToggleBanner(
                  enabled: _featureEnabled,
                  onChanged: (value) async {
                    setState(() => _featureEnabled = value);
                    await context.read<TableCubit>().setEnabled(value);
                  },
                ),
                // Canvas
                Expanded(
                  child: _tables.isEmpty
                      ? _EmptyCanvasHint(onAdd: () => _showAddSheet(context))
                      : TableCanvas(
                          tables: _tables,
                          editMode: true,
                          onTableTap: _onTableTap,
                          onTableMoved: _onTableMoved,
                          onTableRotated: _onTableRotated,
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Table'),
            ),
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddTableSheet(
        onAdd: _addTable,
        onDelete:
            _tables.isNotEmpty ? () => _removeTable(_tables.last.id) : null,
      ),
    );
  }
}

class _FeatureToggleBanner extends StatelessWidget {
  const _FeatureToggleBanner({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          const Icon(Icons.table_restaurant_outlined, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Table Layout',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _EmptyCanvasHint extends StatelessWidget {
  const _EmptyCanvasHint({required this.onAdd});
  final VoidCallback onAdd;

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
            'No tables yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Table" to start building your floor plan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Table'),
          ),
        ],
      ),
    );
  }
}

class _AddTableSheet extends StatelessWidget {
  const _AddTableSheet({required this.onAdd, this.onDelete});

  final void Function(int seats) onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    const seatOptions = [1, 2, 3, 4, 6, 8];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Table',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select table size (number of seats):',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: seatOptions.map((seats) {
              return ActionChip(
                label: Text('$seats seat${seats == 1 ? '' : 's'}'),
                avatar: const Icon(Icons.table_restaurant_outlined, size: 16),
                onPressed: () {
                  Navigator.of(context).pop();
                  onAdd(seats);
                },
              );
            }).toList(),
          ),
          if (onDelete != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Remove last table',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onDelete!();
              },
            ),
          ],
        ],
      ),
    );
  }
}
