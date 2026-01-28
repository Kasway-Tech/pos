import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericInputGroup extends StatefulWidget {
  const NumericInputGroup({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  State<NumericInputGroup> createState() => _NumericInputGroupState();
}

class _NumericInputGroupState extends State<NumericInputGroup> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(NumericInputGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final currentText = _controller.text;
      final newValueText = widget.value.toString();
      if (currentText != newValueText) {
        _controller.text = newValueText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    final cappedValue = newValue.clamp(widget.min, widget.max);
    widget.onChanged(cappedValue);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.remove,
            color: Colors.red,
            onPressed: widget.value > widget.min
                ? () => _updateValue(widget.value - 1)
                : null,
            isLeft: true,
          ),
          Container(
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (text) {
                final newValue = int.tryParse(text);
                if (newValue != null) {
                  if (newValue > widget.max) {
                    _controller.text = widget.max.toString();
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                    _updateValue(widget.max);
                  } else {
                    _updateValue(newValue);
                  }
                }
              },
            ),
          ),
          _ActionButton(
            icon: Icons.add,
            color: Theme.of(context).colorScheme.primary,
            onPressed: widget.value < widget.max
                ? () => _updateValue(widget.value + 1)
                : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.isLeft,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLeft;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(isLeft ? 7 : 0),
        right: Radius.circular(isLeft ? 0 : 7),
      ),
      child: Ink(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isLeft ? 7 : 0),
            right: Radius.circular(isLeft ? 0 : 7),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 16,
              color: onPressed == null
                  ? Theme.of(context).colorScheme.outline
                  : color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
