import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kasway/data/models/table_item.dart';

/// Returns the logical width for a table with [seats] seats.
double tableWidth(int seats) {
  return switch (seats) {
    1 => 64,
    2 => 80,
    3 => 96,
    6 => 144,
    8 => 176,
    _ => 112, // 4 seats default
  };
}

const double _tableHeight = 64;
const double _canvasWidth = 2000;
const double _canvasHeight = 1500;

/// Shared canvas widget used in both the editor (edit mode) and the table
/// selection page (read-only mode).
class TableCanvas extends StatefulWidget {
  const TableCanvas({
    super.key,
    required this.tables,
    required this.editMode,
    this.selectedTableId,
    this.onTableTap,
    this.onTableMoved,
    this.onTableRotated,
  });

  final List<TableItem> tables;
  final bool editMode;
  final String? selectedTableId;
  final void Function(String id)? onTableTap;
  final void Function(String id, double x, double y)? onTableMoved;
  final void Function(String id, double rotation)? onTableRotated;

  @override
  State<TableCanvas> createState() => _TableCanvasState();
}

class _TableCanvasState extends State<TableCanvas> {
  bool _isDraggingTable = false;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      panEnabled: !_isDraggingTable,
      minScale: 0.3,
      maxScale: 3.0,
      child: SizedBox(
        width: _canvasWidth,
        height: _canvasHeight,
        child: Stack(
          children: [
            const _GridBackground(),
            ...widget.tables.map((table) => _PositionedTable(
                  key: ValueKey(table.id),
                  table: table,
                  editMode: widget.editMode,
                  isSelected: widget.selectedTableId == table.id,
                  onTap: widget.onTableTap != null
                      ? () => widget.onTableTap!(table.id)
                      : null,
                  onDragStart: () =>
                      setState(() => _isDraggingTable = true),
                  onDragEnd: (x, y) {
                    setState(() => _isDraggingTable = false);
                    widget.onTableMoved?.call(table.id, x, y);
                  },
                  onRotated: (rotation) =>
                      widget.onTableRotated?.call(table.id, rotation),
                )),
          ],
        ),
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(_canvasWidth, _canvasHeight),
      painter: _DotGridPainter(
        color: Theme.of(context).colorScheme.outlineVariant.withAlpha(100),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    final paint = Paint()..color = color;
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PositionedTable extends StatefulWidget {
  const _PositionedTable({
    super.key,
    required this.table,
    required this.editMode,
    required this.isSelected,
    this.onTap,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onRotated,
  });

  final TableItem table;
  final bool editMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback onDragStart;
  final void Function(double x, double y) onDragEnd;
  final void Function(double rotation) onRotated;

  @override
  State<_PositionedTable> createState() => _PositionedTableState();
}

class _PositionedTableState extends State<_PositionedTable> {
  late double _x;
  late double _y;
  late double _rotation;
  double _startDragX = 0;
  double _startDragY = 0;

  @override
  void initState() {
    super.initState();
    _x = widget.table.x;
    _y = widget.table.y;
    _rotation = widget.table.rotation;
  }

  @override
  void didUpdateWidget(_PositionedTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table != widget.table) {
      _x = widget.table.x;
      _y = widget.table.y;
      _rotation = widget.table.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = tableWidth(widget.table.seats);
    const h = _tableHeight;
    // Rotation handle sits 24dp above the top of the table.
    const handleSize = 16.0;
    const handleOffset = 24.0;

    return Positioned(
      left: _x,
      top: _y,
      child: SizedBox(
        // Extra space above for the rotation handle
        width: w + handleSize,
        height: h + handleOffset + handleSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main table shape
            Positioned(
              left: 0,
              top: handleOffset + handleSize,
              child: GestureDetector(
                onTap: widget.onTap,
                onPanStart: widget.editMode
                    ? (details) {
                        _startDragX = _x - details.globalPosition.dx;
                        _startDragY = _y - details.globalPosition.dy;
                        widget.onDragStart();
                      }
                    : null,
                onPanUpdate: widget.editMode
                    ? (details) {
                        setState(() {
                          final sinA = sin(_rotation).abs();
                          final cosA = cos(_rotation).abs();
                          final effectiveW = w * cosA + _tableHeight * sinA;
                          final effectiveH = w * sinA + _tableHeight * cosA;
                          _x = (_startDragX + details.globalPosition.dx)
                              .clamp(0.0, _canvasWidth - effectiveW);
                          _y = (_startDragY + details.globalPosition.dy)
                              .clamp(0.0, _canvasHeight - effectiveH);
                        });
                      }
                    : null,
                onPanEnd: widget.editMode
                    ? (_) => widget.onDragEnd(_x, _y)
                    : null,
                child: Transform.rotate(
                  angle: _rotation,
                  alignment: Alignment.center,
                  child: _TableShape(
                    table: widget.table,
                    width: w,
                    height: h,
                    isSelected: widget.isSelected,
                  ),
                ),
              ),
            ),

            // Rotation handle — only in edit mode
            if (widget.editMode)
              Positioned(
                left: w / 2 - handleSize / 2,
                top: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final center = Offset(_x + w / 2, _y + h / 2);
                    final pointer = Offset(
                      _x + w / 2 + details.localPosition.dx,
                      _y + details.localPosition.dy,
                    );
                    final raw =
                        atan2(pointer.dy - center.dy, pointer.dx - center.dx) +
                            pi / 2;
                    // Snap to nearest 45°
                    const snap = pi / 4;
                    final snapped = (raw / snap).round() * snap;
                    setState(() => _rotation = snapped);
                    widget.onRotated(snapped);
                  },
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rotate_right,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableShape extends StatelessWidget {
  const _TableShape({
    required this.table,
    required this.width,
    required this.height,
    required this.isSelected,
  });

  final TableItem table;
  final double width;
  final double height;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bgColor = table.isOccupied
        ? colorScheme.surfaceContainerHighest
        : isSelected
            ? colorScheme.primaryContainer
            : colorScheme.primary;
    final Color textColor = table.isOccupied
        ? colorScheme.onSurface.withAlpha(100)
        : isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onPrimary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            table.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${table.seats} seats',
            style: TextStyle(
              color: textColor.withAlpha(180),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
