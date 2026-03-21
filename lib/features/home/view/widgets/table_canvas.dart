import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kasway/data/models/table_item.dart';

const double snapGrid = 40.0;
double snapToGrid(double v) => (v / snapGrid).round() * snapGrid;

/// Returns the logical width for a table with [seats] seats.
double tableWidth(int seats) {
  return switch (seats) {
    1 => 64,
    2 => 80,
    3 => 96,
    5 => 128,
    6 => 144,
    8 => 176,
    10 => 208,
    12 => 240,
    _ => 112, // 4 seats default
  };
}

typedef TableStatusColors = ({Color bg, Color text, Color seat, Color? chip});

/// Derives the three rendering colors for a table based on its occupancy state.
/// [isSelected] is only relevant when the table is not occupied.
TableStatusColors tableColors(
  TableItem table,
  ColorScheme cs, {
  bool isSelected = false,
}) {
  if (table.isOccupied && table.isServed) {
    return (
      bg: Colors.green.shade400,
      text: Colors.white,
      seat: Colors.green.shade200,
      chip: Colors.green.shade100,
    );
  }
  if (table.isOccupied) {
    return (
      bg: Colors.amber.shade600,
      text: Colors.white,
      seat: Colors.amber.shade300,
      chip: Colors.amber.shade100,
    );
  }
  if (isSelected) {
    return (
      bg: cs.primaryContainer,
      text: cs.onPrimaryContainer,
      seat: cs.primary.withAlpha(180),
      chip: cs.primaryContainer,
    );
  }
  return (
    bg: cs.primary,
    text: cs.onPrimary,
    seat: cs.primaryContainer,
    chip: cs.primaryContainer,
  );
}

/// Returns the (top, bottom, left, right) seat count for a given seat number.
(int, int, int, int) seatLayout(int seats) => switch (seats) {
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

const double tableHeight = 64;
const double canvasWidth = 2000;
const double canvasHeight = 1500;

// Seat-circle geometry constants
const double _seatR = 6.0;
const double _seatGap = 3.5;
const double _seatPad = _seatR + _seatGap; // extra space on each side for seats

/// Shared canvas widget used in both the editor (edit mode) and the table
/// selection page (read-only mode).
class TableCanvas extends StatefulWidget {
  const TableCanvas({
    super.key,
    required this.tables,
    required this.editMode,
    this.selectedTableId,
    this.onTableTap,
    this.onTableLongPress,
    this.onTableMoved,
    this.onTableDragUpdate,
  });

  final List<TableItem> tables;
  final bool editMode;
  final String? selectedTableId;
  final void Function(String id)? onTableTap;

  /// Called with the table id when a table is long-pressed.
  /// Only active when [editMode] is false.
  final void Function(String id)? onTableLongPress;
  final void Function(String id, double x, double y)? onTableMoved;
  final void Function(String id, double x, double y)? onTableDragUpdate;

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
        width: canvasWidth,
        height: canvasHeight,
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
                  onLongPress: !widget.editMode && widget.onTableLongPress != null
                      ? () => widget.onTableLongPress!(table.id)
                      : null,
                  onDragStart: () =>
                      setState(() => _isDraggingTable = true),
                  onDragEnd: (x, y) {
                    setState(() => _isDraggingTable = false);
                    widget.onTableMoved?.call(table.id, x, y);
                  },
                  onDragUpdate: (x, y) =>
                      widget.onTableDragUpdate?.call(table.id, x, y),
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
      size: const Size(canvasWidth, canvasHeight),
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
    this.onLongPress,
    required this.onDragStart,
    required this.onDragEnd,
    this.onDragUpdate,
  });

  final TableItem table;
  final bool editMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDragStart;
  final void Function(double x, double y) onDragEnd;
  final void Function(double x, double y)? onDragUpdate;

  @override
  State<_PositionedTable> createState() => _PositionedTableState();
}

class _PositionedTableState extends State<_PositionedTable> {
  late double _x;
  late double _y;
  late double _rotation;
  double _startDragX = 0;
  double _startDragY = 0;
  bool _isDragging = false;

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
    // Only sync from parent when NOT dragging, to avoid fighting local drag state
    if (!_isDragging && oldWidget.table != widget.table) {
      _x = widget.table.x;
      _y = widget.table.y;
      _rotation = widget.table.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = tableWidth(widget.table.seats);
    const h = tableHeight;

    return Positioned(
      left: _x - _seatPad,
      top: _y - _seatPad,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onSecondaryTap: widget.onLongPress,
        onPanStart: widget.editMode
            ? (details) {
                _startDragX =
                    (_x - _seatPad) - details.globalPosition.dx;
                _startDragY =
                    (_y - _seatPad) - details.globalPosition.dy;
                _isDragging = true;
                widget.onDragStart();
              }
            : null,
        onPanUpdate: widget.editMode
            ? (details) {
                setState(() {
                  final sinA = sin(_rotation).abs();
                  final cosA = cos(_rotation).abs();
                  final effectiveW = w * cosA + h * sinA;
                  final effectiveH = w * sinA + h * cosA;
                  final rawX =
                      (_startDragX + details.globalPosition.dx) + _seatPad;
                  final rawY =
                      (_startDragY + details.globalPosition.dy) + _seatPad;
                  _x = snapToGrid(rawX).clamp(0.0, canvasWidth - effectiveW);
                  _y = snapToGrid(rawY).clamp(0.0, canvasHeight - effectiveH);
                });
                widget.onDragUpdate?.call(_x, _y);
              }
            : null,
        onPanEnd: widget.editMode
            ? (_) {
                _isDragging = false;
                widget.onDragEnd(_x, _y);
              }
            : null,
        child: Transform.rotate(
          angle: _rotation,
          alignment: Alignment.center,
          child: _TableShape(
            table: widget.table,
            width: w,
            height: h,
            isSelected: widget.isSelected,
            rotation: _rotation,
          ),
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
    required this.rotation,
  });

  final TableItem table;
  final double width;
  final double height;
  final bool isSelected;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = tableColors(table, cs, isSelected: isSelected);
    final bgColor = colors.bg;
    final textColor = colors.text;
    final seatColor = colors.seat;

    return SizedBox(
      width: width + 2 * _seatPad,
      height: height + 2 * _seatPad,
      child: Stack(
        children: [
          // Seat circles + table body via CustomPaint
          CustomPaint(
            size: Size(width + 2 * _seatPad, height + 2 * _seatPad),
            painter: _TableWithSeatsPainter(
              tableW: width,
              tableH: height,
              seats: table.seats,
              bgColor: bgColor,
              seatColor: seatColor,
              borderColor: isSelected ? cs.primary : null,
            ),
          ),
          // Counter-rotated label — always stays horizontal
          Positioned(
            left: _seatPad,
            top: _seatPad,
            child: SizedBox(
              width: width,
              height: height,
              child: Center(
                child: Transform.rotate(
                  angle: -rotation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableWithSeatsPainter extends CustomPainter {
  const _TableWithSeatsPainter({
    required this.tableW,
    required this.tableH,
    required this.seats,
    required this.bgColor,
    required this.seatColor,
    this.borderColor,
  });

  final double tableW;
  final double tableH;
  final int seats;
  final Color bgColor;
  final Color seatColor;
  final Color? borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Table rect starts at (_seatPad, _seatPad) within this canvas
    const left = _seatPad;
    const top = _seatPad;

    // --- Draw seat circles first (behind table) ---
    final seatPaint = Paint()..color = seatColor;
    final (topS, bottomS, leftS, rightS) = seatLayout(seats);

    for (int i = 0; i < topS; i++) {
      final cx = left + tableW * (i + 1) / (topS + 1);
      const cy = top - _seatGap - _seatR;
      canvas.drawCircle(Offset(cx, cy), _seatR, seatPaint);
    }
    for (int i = 0; i < bottomS; i++) {
      final cx = left + tableW * (i + 1) / (bottomS + 1);
      final cy = top + tableH + _seatGap + _seatR;
      canvas.drawCircle(Offset(cx, cy), _seatR, seatPaint);
    }
    for (int i = 0; i < leftS; i++) {
      const cx = left - _seatGap - _seatR;
      final cy = top + tableH / 2;
      canvas.drawCircle(Offset(cx, cy), _seatR, seatPaint);
    }
    for (int i = 0; i < rightS; i++) {
      final cx = left + tableW + _seatGap + _seatR;
      final cy = top + tableH / 2;
      canvas.drawCircle(Offset(cx, cy), _seatR, seatPaint);
    }

    // --- Draw table rectangle ---
    final tablePaint = Paint()..color = bgColor;
    final tableRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, tableW, tableH),
      const Radius.circular(12),
    );
    canvas.drawRRect(tableRect, tablePaint);

    // --- Draw selection border ---
    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(tableRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_TableWithSeatsPainter old) =>
      old.tableW != tableW ||
      old.tableH != tableH ||
      old.seats != seats ||
      old.bgColor != bgColor ||
      old.seatColor != seatColor ||
      old.borderColor != borderColor;
}
