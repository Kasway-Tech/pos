import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, this.product, this.defaultCategory});

  final Product? product;
  final String? defaultCategory;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedCategory;
  late List<Addition> _additions;
  late CurrencyState _lastCurrencyState;

  static String _rawPrice(double amount, CurrencyState state) {
    final code = state.selectedCurrency.code.toLowerCase();
    if (state.selectedCurrency.isCrypto) return amount.toStringAsFixed(4);
    if ({'jpy', 'krw', 'idr'}.contains(code)) return amount.toInt().toString();
    return amount.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _lastCurrencyState = context.read<CurrencyCubit>().state;
    final displayPrice = p != null
        ? _lastCurrencyState.idrToDisplay(p.price)
        : null;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
      text: displayPrice != null
          ? _rawPrice(displayPrice, _lastCurrencyState)
          : '',
    );
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _additions = List<Addition>.from(p?.additions ?? []);
    final categories = context.read<HomeBloc>().state.categories;
    _selectedCategory =
        widget.defaultCategory ??
        (categories.isNotEmpty ? categories.first : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Product' : 'Add Product'),
          centerTitle: true,
          actions: [TextButton(onPressed: _submit, child: const Text('Save'))],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        autofocus: !isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      BlocConsumer<CurrencyCubit, CurrencyState>(
                        listenWhen: (prev, curr) =>
                            prev.selectedCurrency.code !=
                                curr.selectedCurrency.code ||
                            prev.exchangeRates != curr.exchangeRates,
                        listener: (context, currencyState) {
                          final displayAmount = double.tryParse(
                            _priceCtrl.text,
                          );
                          if (displayAmount != null) {
                            final idr = _lastCurrencyState.displayToIdr(
                              displayAmount,
                            );
                            _priceCtrl.text = _rawPrice(
                              currencyState.idrToDisplay(idr),
                              currencyState,
                            );
                          }
                          _lastCurrencyState = currencyState;
                        },
                        builder: (context, currencyState) {
                          return TextFormField(
                            controller: _priceCtrl,
                            decoration: InputDecoration(
                              labelText:
                                  'Price (${currencyState.selectedCurrency.code})',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (prev, curr) =>
                            prev.categories != curr.categories,
                        builder: (context, state) {
                          final categories = state.categories;
                          if (!categories.contains(_selectedCategory) &&
                              categories.isNotEmpty) {
                            _selectedCategory = categories.first;
                          }
                          return DropdownButtonFormField<String>(
                            key: ValueKey(_selectedCategory),
                            initialValue: categories.contains(_selectedCategory)
                                ? _selectedCategory
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedCategory = v);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Additions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._additions.asMap().entries.map(
                        (e) => _AdditionRow(
                          addition: e.value,
                          onEdit: () => _showAdditionDialog(index: e.key),
                          onDelete: () =>
                              setState(() => _additions.removeAt(e.key)),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          'Add Addition',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onTap: () => _showAdditionDialog(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAdditionDialog({int? index}) async {
    final existing = index != null ? _additions[index] : null;
    final currencyState = _lastCurrencyState;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null
          ? _rawPrice(currencyState.idrToDisplay(existing.price), currencyState)
          : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Addition>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? 'Edit Addition' : 'New Addition'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Addition Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText:
                      'Extra Price (${currencyState.selectedCurrency.code}, 0 = free)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(
                  Addition(
                    id:
                        existing?.id ??
                        '${nameCtrl.text.trim().replaceAll(' ', '_').toLowerCase()}__${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    price: currencyState.displayToIdr(
                      double.parse(priceCtrl.text),
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _additions[index] = result;
        } else {
          _additions.add(result);
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final currencyState = context.read<CurrencyCubit>().state;
    final idrPrice = currencyState.displayToIdr(double.parse(_priceCtrl.text));
    final product = Product(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      price: idrPrice,
      description: _descCtrl.text.trim(),
      additions: _additions,
    );
    final bloc = context.read<HomeBloc>();
    if (widget.product == null) {
      bloc.add(
        HomeCatalogProductAdded(category: _selectedCategory, product: product),
      );
    } else {
      bloc.add(
        HomeCatalogProductUpdated(
          oldCategory: widget.defaultCategory!,
          category: _selectedCategory,
          product: product,
        ),
      );
    }
    Navigator.of(context).pop();
  }
}

class _AdditionRow extends StatelessWidget {
  const _AdditionRow({
    required this.addition,
    required this.onEdit,
    required this.onDelete,
  });

  final Addition addition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(addition.name),
      subtitle: addition.price > 0
          ? PriceText(addition.price)
          : const Text('Free'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
