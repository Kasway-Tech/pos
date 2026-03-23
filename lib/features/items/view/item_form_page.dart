import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/currency/currency_state.dart';

import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';

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
  late final TextEditingController _kasCtrl;
  late String _selectedCategory;
  late List<Addition> _additions;
  late CurrencyState _lastCurrencyState;

  bool _updatingFromKas = false;
  bool _updatingFromFiat = false;

  static String _rawPrice(double amount, CurrencyState state) {
    final code = state.selectedCurrency.code.toLowerCase();
    if (state.selectedCurrency.isCrypto) return amount.toStringAsFixed(4);
    if ({'jpy', 'krw', 'idr', 'vnd', 'pkr', 'ngn'}.contains(code)) return amount.toInt().toString();
    return amount.toStringAsFixed(2);
  }

  static String _rawKas(double kas) {
    final s = kas.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? '${s}0' : s;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _lastCurrencyState = context.read<CurrencyCubit>().state;
    final isCrypto = _lastCurrencyState.selectedCurrency.isCrypto;

    // Fiat display price
    final displayPrice = p != null
        ? _lastCurrencyState.idrToDisplay(p.price, kasPrice: p.kasPrice)
        : null;

    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
      text: displayPrice != null && !isCrypto
          ? _rawPrice(displayPrice, _lastCurrencyState)
          : '',
    );
    // KAS price — use stored kasPrice if available, otherwise derive from IDR
    final kasPrice = p?.kasPrice ??
        (p != null && !isCrypto
            ? _lastCurrencyState.displayToKas(
                _lastCurrencyState.idrToDisplay(p.price),
              )
            : null);
    _kasCtrl = TextEditingController(
      text: kasPrice != null ? _rawKas(kasPrice) : '',
    );

    _additions = List<Addition>.from(p?.additions ?? []);
    final categories = context.read<HomeBloc>().state.categories;
    _selectedCategory =
        widget.defaultCategory ??
        (categories.isNotEmpty ? categories.first : '');

    _priceCtrl.addListener(_onFiatChanged);
    _kasCtrl.addListener(_onKasChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _kasCtrl.dispose();
    super.dispose();
  }

  void _onFiatChanged() {
    if (_updatingFromKas) return;
    final fiat = double.tryParse(_priceCtrl.text);
    if (fiat == null) return;
    final kasIdr = _lastCurrencyState.exchangeRates['idr'] ?? 0;
    if (kasIdr <= 0) return;
    final idr = _lastCurrencyState.displayToIdr(fiat);
    final kas = idr / kasIdr;
    _updatingFromFiat = true;
    _kasCtrl.text = _rawKas(kas);
    _updatingFromFiat = false;
  }

  void _onKasChanged() {
    if (_updatingFromFiat) return;
    final kas = double.tryParse(_kasCtrl.text);
    if (kas == null) return;
    final kasIdr = _lastCurrencyState.exchangeRates['idr'] ?? 0;
    if (kasIdr <= 0) return;
    final idr = kas * kasIdr;
    final fiat = _lastCurrencyState.idrToDisplay(idr);
    _updatingFromKas = true;
    _priceCtrl.text = _rawPrice(fiat, _lastCurrencyState);
    _updatingFromKas = false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.l10n.itemFormEditTitle : context.l10n.itemFormAddTitle),
        centerTitle: true,
        actions: [TextButton(onPressed: _submit, child: Text(context.l10n.itemFormSave))],
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
                      decoration: InputDecoration(
                        labelText: context.l10n.itemFormProductName,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? context.l10n.itemFormRequired : null,
                    ),
                    const SizedBox(height: 16),
                    BlocConsumer<CurrencyCubit, CurrencyState>(
                      listenWhen: (prev, curr) {
                        // In KAS mode: only react to currency code changes (not rate updates)
                        if (curr.selectedCurrency.isCrypto) {
                          return prev.selectedCurrency.code != curr.selectedCurrency.code;
                        }
                        return prev.selectedCurrency.code != curr.selectedCurrency.code ||
                            prev.exchangeRates != curr.exchangeRates;
                      },
                      listener: (context, currencyState) {
                        final isCrypto = currencyState.selectedCurrency.isCrypto;
                        if (isCrypto) {
                          // Switching to KAS mode: clear fiat field
                          _priceCtrl.removeListener(_onFiatChanged);
                          _priceCtrl.text = '';
                          _priceCtrl.addListener(_onFiatChanged);
                        } else {
                          // Fiat mode: re-derive fiat from KAS price if available
                          final kas = double.tryParse(_kasCtrl.text);
                          if (kas != null) {
                            final kasIdr = currencyState.exchangeRates['idr'] ?? 0;
                            if (kasIdr > 0) {
                              final idr = kas * kasIdr;
                              final fiat = currencyState.idrToDisplay(idr);
                              _updatingFromKas = true;
                              _priceCtrl.text = _rawPrice(fiat, currencyState);
                              _updatingFromKas = false;
                            }
                          } else {
                            // Re-convert from old fiat display
                            final displayAmount = double.tryParse(_priceCtrl.text);
                            if (displayAmount != null) {
                              final idr = _lastCurrencyState.displayToIdr(displayAmount);
                              _priceCtrl.text = _rawPrice(
                                currencyState.idrToDisplay(idr),
                                currencyState,
                              );
                            }
                          }
                        }
                        _lastCurrencyState = currencyState;
                      },
                      builder: (context, currencyState) {
                        final isCrypto = currencyState.selectedCurrency.isCrypto;
                        return Column(
                          children: [
                            if (!isCrypto) ...[
                              TextFormField(
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
                                    return context.l10n.itemFormRequired;
                                  }
                                  if (double.tryParse(v) == null) {
                                    return context.l10n.itemFormInvalidNumber;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _kasCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.itemFormKasPrice,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return context.l10n.itemFormRequired;
                                }
                                if (double.tryParse(v) == null) {
                                  return context.l10n.itemFormInvalidNumber;
                                }
                                return null;
                              },
                            ),
                          ],
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
                          decoration: InputDecoration(
                            labelText: context.l10n.itemFormCategory,
                          ),
                          items: categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
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
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.itemFormAdditions,
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
                        context.l10n.itemFormAddAddition,
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
    );
  }

  Future<void> _showAdditionDialog({int? index}) async {
    final existing = index != null ? _additions[index] : null;
    final currencyState = _lastCurrencyState;
    final isCrypto = currencyState.selectedCurrency.isCrypto;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');

    // Fiat price field
    final fiatPrice = existing != null && !isCrypto
        ? _rawPrice(
            currencyState.idrToDisplay(
              existing.price,
              kasPrice: existing.kasPrice,
            ),
            currencyState,
          )
        : '';
    final fiatCtrl = TextEditingController(text: fiatPrice);

    // KAS price field
    final kasValue = existing?.kasPrice ??
        (existing != null && !isCrypto
            ? currencyState.displayToKas(
                currencyState.idrToDisplay(existing.price),
              )
            : null);
    final kasCtrl = TextEditingController(
      text: kasValue != null ? _rawKas(kasValue) : '',
    );

    bool updatingFromKas = false;
    bool updatingFromFiat = false;

    void onFiatChanged() {
      if (updatingFromKas) return;
      final fiat = double.tryParse(fiatCtrl.text);
      if (fiat == null) return;
      final kasIdr = currencyState.exchangeRates['idr'] ?? 0;
      if (kasIdr <= 0) return;
      final idr = currencyState.displayToIdr(fiat);
      final kas = idr / kasIdr;
      updatingFromFiat = true;
      kasCtrl.text = _rawKas(kas);
      updatingFromFiat = false;
    }

    void onKasChanged() {
      if (updatingFromFiat) return;
      final kas = double.tryParse(kasCtrl.text);
      if (kas == null) return;
      final kasIdr = currencyState.exchangeRates['idr'] ?? 0;
      if (kasIdr <= 0) return;
      final idr = kas * kasIdr;
      final fiat = currencyState.idrToDisplay(idr);
      updatingFromKas = true;
      fiatCtrl.text = _rawPrice(fiat, currencyState);
      updatingFromKas = false;
    }

    fiatCtrl.addListener(onFiatChanged);
    kasCtrl.addListener(onKasChanged);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Addition>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? context.l10n.itemFormEditAdditionTitle : context.l10n.itemFormNewAdditionTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: context.l10n.itemFormAdditionName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? context.l10n.itemFormRequired : null,
              ),
              const SizedBox(height: 12),
              if (!isCrypto) ...[
                TextFormField(
                  controller: fiatCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.itemFormAdditionPriceLabel(currencyState.selectedCurrency.code),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return context.l10n.itemFormRequired;
                    if (double.tryParse(v) == null) return context.l10n.itemFormInvalidNumber;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: kasCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.itemFormKasPrice,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return context.l10n.itemFormRequired;
                  if (double.tryParse(v) == null) return context.l10n.itemFormInvalidNumber;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.itemFormCancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final kasPrice = double.parse(kasCtrl.text);
                final kasIdr = currencyState.exchangeRates['idr'] ?? 0;
                final idrPrice = isCrypto
                    ? (kasIdr > 0 ? kasPrice * kasIdr : 0.0)
                    : currencyState.displayToIdr(double.parse(fiatCtrl.text));
                Navigator.of(context).pop(
                  Addition(
                    id:
                        existing?.id ??
                        '${nameCtrl.text.trim().replaceAll(' ', '_').toLowerCase()}__${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    price: idrPrice,
                    kasPrice: kasPrice,
                  ),
                );
              }
            },
            child: Text(context.l10n.itemFormSave),
          ),
        ],
      ),
    );

    fiatCtrl.removeListener(onFiatChanged);
    kasCtrl.removeListener(onKasChanged);
    fiatCtrl.dispose();
    kasCtrl.dispose();
    nameCtrl.dispose();

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
    final isCrypto = currencyState.selectedCurrency.isCrypto;

    final kasPrice = double.parse(_kasCtrl.text);
    final kasIdr = currencyState.exchangeRates['idr'] ?? 0;

    final double idrPrice;
    if (isCrypto) {
      idrPrice = kasIdr > 0 ? kasPrice * kasIdr : 0.0;
    } else {
      idrPrice = currencyState.displayToIdr(double.parse(_priceCtrl.text));
    }

    final product = Product(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      price: idrPrice,
      kasPrice: kasPrice,
      description: widget.product?.description ?? '',
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
          ? PriceText(addition.price, kasPrice: addition.kasPrice)
          : Text(context.l10n.itemFormAdditionFree),
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
