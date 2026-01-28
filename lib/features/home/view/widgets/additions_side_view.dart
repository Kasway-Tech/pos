import 'package:atomikpos/data/models/addition.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdditionsSideView extends StatefulWidget {
  const AdditionsSideView({
    super.key,
    required this.product,
    required this.onConfirm,
    required this.onBack,
  });

  final Product product;
  final void Function(List<Addition> selectedAdditions) onConfirm;
  final VoidCallback onBack;

  @override
  State<AdditionsSideView> createState() => _AdditionsSideViewState();
}

class _AdditionsSideViewState extends State<AdditionsSideView> {
  final Set<String> _selectedAdditionIds = {};

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 0,
  );

  double get _additionsTotal {
    return widget.product.additions
        .where((a) => _selectedAdditionIds.contains(a.id))
        .fold(0.0, (sum, a) => sum + a.price);
  }

  double get _total => widget.product.price + _additionsTotal;

  void _toggleAddition(Addition addition) {
    setState(() {
      if (_selectedAdditionIds.contains(addition.id)) {
        _selectedAdditionIds.remove(addition.id);
      } else {
        _selectedAdditionIds.add(addition.id);
      }
    });
  }

  void _confirm() {
    final selectedAdditions = widget.product.additions
        .where((a) => _selectedAdditionIds.contains(a.id))
        .toList();
    widget.onConfirm(selectedAdditions);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final padding = isTablet ? 12.0 : 16.0;

    final content = Column(
      children: [
        AppBar(
          toolbarHeight: isTablet
              ? kToolbarHeight + 8.0
              : kToolbarHeight + 16.0,
          title: Text(widget.product.name),
          centerTitle: false,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            child: widget.product.additions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.tune,
                          size: 64,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No additions available',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: padding,
                      crossAxisSpacing: padding,
                      childAspectRatio: 2,
                    ),
                    itemCount: widget.product.additions.length,
                    itemBuilder: (context, index) {
                      final addition = widget.product.additions[index];
                      final isSelected = _selectedAdditionIds.contains(
                        addition.id,
                      );
                      return _AdditionCard(
                        addition: addition,
                        isSelected: isSelected,
                        onTap: () => _toggleAddition(addition),
                      );
                    },
                  ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 24.0,
            vertical: isTablet ? 12.0 : 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _currencyFormat.format(_total),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
          child: SizedBox(
            height: isTablet ? kToolbarHeight + 8.0 : kToolbarHeight + 16.0,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add to Order',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.add_shopping_cart),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(body: content);
  }
}

class _AdditionCard extends StatelessWidget {
  const _AdditionCard({
    required this.addition,
    required this.isSelected,
    required this.onTap,
  });

  final Addition addition;
  final bool isSelected;
  final VoidCallback onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final padding = isTablet ? 12.0 : 16.0;

    return Bounce(
      onTap: onTap,
      tapDelay: const Duration(milliseconds: 50),
      duration: const Duration(milliseconds: 75),
      scaleFactor: 0.96,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
        child: Container(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      addition.name,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                    Text(
                      addition.price > 0
                          ? '+${_currencyFormat.format(addition.price)}'
                          : 'Free',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
