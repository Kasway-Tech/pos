import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/features/home/view/widgets/table_canvas.dart';

class TableLayoutPage extends StatefulWidget {
  const TableLayoutPage({super.key});

  @override
  State<TableLayoutPage> createState() => _TableLayoutPageState();
}

class _TableLayoutPageState extends State<TableLayoutPage> {
  late List<TableItem> _tables;
  bool _hasChanges = false;
  String? _selectedTableId;

  // Remembered spawn state for seamless single-table placement
  double _lastSpawnX = 80.0;
  double _lastSpawnY = 80.0;
  int _lastSpawnSeats = 4;
  double _lastRotation = 0.0;

  static double _snap(double v) => (v / 40.0).round() * 40.0;

  @override
  void initState() {
    super.initState();
    final tableState = context.read<TableCubit>().state;
    _tables = List.from(tableState.tables);
    if (_tables.isNotEmpty) {
      final last = _tables.last;
      _lastSpawnX = last.x;
      _lastSpawnY = last.y;
      _lastSpawnSeats = last.seats;
      _lastRotation = last.rotation;
    }
  }

  void _addTable(int seats) {
    const gap = 40.0;
    const tableH = 64.0;
    const canvasWidth = 2000.0;

    final prevW = tableWidth(_lastSpawnSeats);
    double newX = _snap(_lastSpawnX + prevW + gap);
    double newY = _lastSpawnY;

    // Wrap to the next row if the new table would go off the right edge
    if (newX + tableWidth(seats) > canvasWidth - 80) {
      newX = _snap(80.0);
      newY = _snap(_lastSpawnY + tableH + gap);
    }

    var newTable = context.read<TableCubit>().buildNewTable(
      seats: seats,
      existingCount: _tables.length,
    );
    newTable = newTable.copyWith(x: newX, y: newY, rotation: _lastRotation);

    setState(() {
      _lastSpawnX = newX;
      _lastSpawnY = newY;
      _lastSpawnSeats = seats;
      _tables = [..._tables, newTable];
      _selectedTableId = newTable.id;
      _hasChanges = true;
    });
  }

  void _addTableGroup(int rows, int cols, int seatsPerTable) {
    final tblW = tableWidth(seatsPerTable);
    const tblH = 64.0;
    const gap = 20.0;

    final baseX = _snap(80.0);
    final baseY = _snap(80.0 + _tables.length * 8.0);

    // Build tables first (to get their IDs)
    final newTables = <TableItem>[];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final tbl = context.read<TableCubit>().buildNewTable(
          seats: seatsPerTable,
          existingCount: _tables.length + newTables.length,
        );
        newTables.add(tbl.copyWith(
          x: _snap(baseX + col * (tblW + gap)),
          y: _snap(baseY + row * (tblH + gap)),
        ));
      }
    }

    // Use the first table's id as the shared groupId
    final groupId = newTables.first.id;
    final groupedTables =
        newTables.map((t) => t.copyWith(groupId: groupId)).toList();

    setState(() {
      _tables = [..._tables, ...groupedTables];
      _selectedTableId = groupedTables.last.id;
      _hasChanges = true;
    });
  }

  void _rotateSelected(bool clockwise) {
    if (_selectedTableId == null) return;
    const snapAngle = pi / 2; // 90 degrees
    setState(() {
      final selectedTable =
          _tables.firstWhere((t) => t.id == _selectedTableId);
      final groupId = selectedTable.groupId;
      double? newSelectedRot;
      _tables = _tables.map((t) {
        if (t.id != _selectedTableId &&
            (groupId == null || t.groupId != groupId)) {
          return t;
        }
        final steps = clockwise ? 1 : -1;
        final newRot =
            (t.rotation / snapAngle).round() * snapAngle + steps * snapAngle;
        if (t.id == _selectedTableId) newSelectedRot = newRot;
        return t.copyWith(rotation: newRot);
      }).toList();
      if (newSelectedRot != null) _lastRotation = newSelectedRot!;
      _hasChanges = true;
    });
  }

  void _onTableDragUpdate(String id, double x, double y) {
    final table = _tables.where((t) => t.id == id).firstOrNull;
    if (table == null) return;
    final groupId = table.groupId;
    if (groupId == null) return; // non-group tables: no live update needed

    final dx = x - table.x;
    final dy = y - table.y;

    setState(() {
      _tables = _tables.map((t) {
        if (t.groupId != groupId) return t;
        if (t.id == id) return t.copyWith(x: x, y: y);
        return t.copyWith(x: t.x + dx, y: t.y + dy);
      }).toList();
    });
  }

  void _onTableMoved(String id, double x, double y) {
    setState(() {
      _selectedTableId = id;
      final table = _tables.firstWhere((t) => t.id == id);
      final groupId = table.groupId;
      if (groupId == null) {
        _tables = _tables
            .map((t) => t.id == id ? t.copyWith(x: x, y: y) : t)
            .toList();
      } else {
        final dx = x - table.x;
        final dy = y - table.y;
        _tables = _tables.map((t) {
          if (t.groupId != groupId) return t;
          if (t.id == id) return t.copyWith(x: x, y: y);
          return t.copyWith(x: t.x + dx, y: t.y + dy);
        }).toList();
      }
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

  void _onTableTap(String id) => setState(() => _selectedTableId = id);

  void _renameSelected(String label) {
    if (_selectedTableId == null || label.isEmpty) return;
    setState(() {
      _tables = _tables
          .map((t) => t.id == _selectedTableId ? t.copyWith(label: label) : t)
          .toList();
      _hasChanges = true;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedTableId == null) return;
    final table = _tables.firstWhere((t) => t.id == _selectedTableId);
    final groupId = table.groupId;
    final isGroup = groupId != null &&
        _tables.where((t) => t.groupId == groupId).length > 1;

    final content = isGroup
        ? 'Remove the entire group (${_tables.where((t) => t.groupId == groupId).length} tables)?'
        : 'Remove table "${table.label}"?';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isGroup ? 'Delete Group' : 'Delete Table'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() {
        _tables = isGroup
            ? _tables.where((t) => t.groupId != groupId).toList()
            : _tables.where((t) => t.id != _selectedTableId).toList();
        _selectedTableId = null;
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
    return BlocConsumer<TableCubit, TableState>(
      // If the page opened before _loadTables() finished, repopulate _tables
      // once the cubit delivers the actual rows (only when we have nothing yet).
      listenWhen: (previous, current) =>
          _tables.isEmpty && current.tables.isNotEmpty,
      listener: (context, tableState) {
        setState(() {
          _tables = List.from(tableState.tables);
          final last = _tables.last;
          _lastSpawnX = last.x;
          _lastSpawnY = last.y;
          _lastSpawnSeats = last.seats;
          _lastRotation = last.rotation;
        });
      },
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
                  enabled: tableState.enabled,
                  onChanged: (value) async {
                    await context.read<TableCubit>().setEnabled(value);
                  },
                ),
                // Canvas + floating inspector panel
                Expanded(
                  child: Stack(
                    children: [
                      TableCanvas(
                        tables: _tables,
                        editMode: true,
                        selectedTableId: _selectedTableId,
                        onTableTap: _onTableTap,
                        onTableMoved: _onTableMoved,
                        onTableDragUpdate: _onTableDragUpdate,
                        onTableRotated: _onTableRotated,
                      ),
                      // Inspector panel — shown when a table is selected
                      if (tableState.enabled && _selectedTableId != null)
                        Builder(builder: (context) {
                          final table = _tables
                              .where((t) => t.id == _selectedTableId)
                              .firstOrNull;
                          if (table == null) return const SizedBox.shrink();
                          return Positioned(
                            top: 12,
                            right: 12,
                            child: _TableInspectorPanel(
                              key: ValueKey(_selectedTableId),
                              table: table,
                              onDeselect: () =>
                                  setState(() => _selectedTableId = null),
                              onRename: _renameSelected,
                              onDelete: _deleteSelected,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: tableState.enabled
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_selectedTableId != null) ...[
                        FloatingActionButton.small(
                          heroTag: 'rotate_ccw',
                          onPressed: () => _rotateSelected(false),
                          tooltip: 'Rotate counter-clockwise',
                          child: const Icon(Icons.rotate_left),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'rotate_cw',
                          onPressed: () => _rotateSelected(true),
                          tooltip: 'Rotate clockwise',
                          child: const Icon(Icons.rotate_right),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FloatingActionButton.extended(
                        heroTag: 'add_table',
                        onPressed: () => _showAddSheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Table'),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddTableSheet(
        onAddSingle: _addTable,
        onAddGroup: _addTableGroup,
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

class _AddTableSheet extends StatelessWidget {
  const _AddTableSheet({required this.onAddSingle, required this.onAddGroup});

  final void Function(int seats) onAddSingle;
  final void Function(int rows, int cols, int seatsPerTable) onAddGroup;

  static const _singleOptions = [
    (seats: 1, name: 'Solo'),
    (seats: 2, name: '2 Seats'),
    (seats: 3, name: '3 Seats'),
    (seats: 4, name: '4 Seats'),
    (seats: 5, name: '5 Seats'),
    (seats: 6, name: '6 Seats'),
    (seats: 8, name: '8 Seats'),
    (seats: 10, name: '10 Seats'),
    (seats: 12, name: '12 Seats'),
  ];

  static const _groupOptions = [
    (rows: 2, cols: 2, seats: 1, name: '2×2 Group'),
    (rows: 3, cols: 3, seats: 1, name: '3×3 Group'),
    (rows: 4, cols: 4, seats: 1, name: '4×4 Group'),
    (rows: 1, cols: 4, seats: 2, name: 'Row of 4'),
    (rows: 2, cols: 4, seats: 2, name: '2×4 Array'),
    (rows: 1, cols: 6, seats: 2, name: 'Row of 6'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Table',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'SINGLE TABLES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _singleOptions.map((opt) {
                  return _TableOptionCard(
                    label: opt.name,
                    painter: _SingleTablePainter(
                      seats: opt.seats,
                      tableColor: colorScheme.primary,
                      seatColor: colorScheme.primaryContainer,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onAddSingle(opt.seats);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'TABLE GROUPS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Places multiple tables at once in a preset arrangement.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _groupOptions.map((opt) {
                  return _TableOptionCard(
                    label: opt.name,
                    painter: _GroupTablePainter(
                      rows: opt.rows,
                      cols: opt.cols,
                      color: colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onAddGroup(opt.rows, opt.cols, opt.seats);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableOptionCard extends StatelessWidget {
  const _TableOptionCard({
    required this.label,
    required this.painter,
    required this.onTap,
  });

  final String label;
  final CustomPainter painter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 76,
              height: 64,
              child: CustomPaint(painter: painter),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleTablePainter extends CustomPainter {
  const _SingleTablePainter({
    required this.seats,
    required this.tableColor,
    required this.seatColor,
  });

  final int seats;
  final Color tableColor;
  final Color seatColor;

  (int top, int bottom, int left, int right) get _layout => switch (seats) {
        1 => (1, 0, 0, 0),
        2 => (1, 1, 0, 0),
        3 => (2, 1, 0, 0),
        4 => (2, 2, 0, 0),
        5 => (2, 2, 0, 1),
        6 => (2, 2, 1, 1),
        8 => (3, 3, 1, 1),
        10 => (4, 4, 1, 1),
        12 => (5, 5, 1, 1),
        _ => (2, 2, 0, 0),
      };

  double get _widthFraction => switch (seats) {
        1 => 0.28,
        2 => 0.38,
        3 => 0.50,
        4 => 0.58,
        5 => 0.64,
        6 => 0.70,
        8 => 0.78,
        10 => 0.78,
        12 => 0.78,
        _ => 0.58,
      };

  @override
  void paint(Canvas canvas, Size size) {
    const tableH = 20.0;
    const seatR = 3.5;
    const seatGap = 2.5;

    final tableW = size.width * _widthFraction;
    final tableLeft = (size.width - tableW) / 2;
    final tableTop = (size.height - tableH) / 2;

    final tablePaint = Paint()..color = tableColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tableLeft, tableTop, tableW, tableH),
        const Radius.circular(4),
      ),
      tablePaint,
    );

    final seatPaint = Paint()..color = seatColor;
    final (top, bottom, left, right) = _layout;

    for (int i = 0; i < top; i++) {
      final x = tableLeft + tableW * (i + 1) / (top + 1);
      canvas.drawCircle(
          Offset(x, tableTop - seatGap - seatR), seatR, seatPaint);
    }
    for (int i = 0; i < bottom; i++) {
      final x = tableLeft + tableW * (i + 1) / (bottom + 1);
      canvas.drawCircle(
          Offset(x, tableTop + tableH + seatGap + seatR), seatR, seatPaint);
    }
    if (left > 0) {
      canvas.drawCircle(
          Offset(tableLeft - seatGap - seatR, tableTop + tableH / 2),
          seatR,
          seatPaint);
    }
    if (right > 0) {
      canvas.drawCircle(
          Offset(tableLeft + tableW + seatGap + seatR, tableTop + tableH / 2),
          seatR,
          seatPaint);
    }
  }

  @override
  bool shouldRepaint(_SingleTablePainter old) =>
      old.seats != seats ||
      old.tableColor != tableColor ||
      old.seatColor != seatColor;
}

class _GroupTablePainter extends CustomPainter {
  const _GroupTablePainter({
    required this.rows,
    required this.cols,
    required this.color,
  });

  final int rows;
  final int cols;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const maxW = 62.0;
    const maxH = 52.0;
    const gap = 3.0;

    final cellW = ((maxW - gap * (cols - 1)) / cols).clamp(5.0, 20.0);
    final cellH = ((maxH - gap * (rows - 1)) / rows).clamp(4.0, 16.0);

    final totalW = cellW * cols + gap * (cols - 1);
    final totalH = cellH * rows + gap * (rows - 1);
    final startX = (size.width - totalW) / 2;
    final startY = (size.height - totalH) / 2;

    final paint = Paint()..color = color;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = startX + c * (cellW + gap);
        final y = startY + r * (cellH + gap);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cellW, cellH),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GroupTablePainter old) =>
      old.rows != rows || old.cols != cols || old.color != color;
}

/// Fixed-position inspector panel shown at the top-right of the canvas when a
/// table is selected in edit mode. Provides inline rename and delete actions.
class _TableInspectorPanel extends StatefulWidget {
  const _TableInspectorPanel({
    super.key,
    required this.table,
    required this.onDeselect,
    required this.onRename,
    required this.onDelete,
  });

  final TableItem table;
  final VoidCallback onDeselect;
  final void Function(String label) onRename;
  final VoidCallback onDelete;

  @override
  State<_TableInspectorPanel> createState() => _TableInspectorPanelState();
}

class _TableInspectorPanelState extends State<_TableInspectorPanel> {
  bool _renaming = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.table.label);
  }

  @override
  void didUpdateWidget(_TableInspectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table.id != widget.table.id) {
      _renaming = false;
      _controller.text = widget.table.label;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRename() => setState(() {
        _controller.text = widget.table.label;
        _renaming = true;
      });

  void _saveRename() {
    final label = _controller.text.trim();
    if (label.isNotEmpty) widget.onRename(label);
    setState(() => _renaming = false);
  }

  void _cancelRename() => setState(() => _renaming = false);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: _renaming ? _buildRenameRow(cs) : _buildInfoRow(cs),
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PanelIconButton(
          icon: Icons.close,
          onPressed: widget.onDeselect,
        ),
        const SizedBox(width: 4),
        Text(
          widget.table.label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          ' · ${widget.table.seats} seats',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.outline),
        ),
        const SizedBox(width: 8),
        _PanelIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Rename',
          onPressed: _startRename,
        ),
        _PanelIconButton(
          icon: Icons.delete_outline,
          tooltip: 'Delete',
          color: cs.error,
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  Widget _buildRenameRow(ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PanelIconButton(
          icon: Icons.close,
          tooltip: 'Cancel',
          onPressed: _cancelRename,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            onSubmitted: (_) => _saveRename(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 4),
        _PanelIconButton(
          icon: Icons.check,
          tooltip: 'Save',
          color: cs.primary,
          onPressed: _saveRename,
        ),
      ],
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      iconSize: 18,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}
