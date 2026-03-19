import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';

class KaspaPaymentPage extends StatefulWidget {
  const KaspaPaymentPage({super.key});

  @override
  State<KaspaPaymentPage> createState() => _KaspaPaymentPageState();
}

class _KaspaPaymentPageState extends State<KaspaPaymentPage> {
  List<CartItem> _cartItems = [];
  double _totalIdr = 0;
  bool _initialized = false;
  String? _merchantAddress;
  bool _loadingAddress = true;
  String? _addressError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final state = context.read<HomeBloc>().state;
    _cartItems = state.cartItems;
    _totalIdr = _cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

    Future.microtask(_loadAddress);
  }

  Future<void> _loadAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mnemonic = prefs.getString('wallet_mnemonic');
      if (mnemonic == null || mnemonic.isEmpty) {
        setState(() {
          _addressError = 'No wallet mnemonic found. Please set up your wallet first.';
          _loadingAddress = false;
        });
        return;
      }
      final address = KaspaWalletService().deriveAddress(mnemonic);
      setState(() {
        _merchantAddress = address;
        _loadingAddress = false;
      });
    } catch (e) {
      setState(() {
        _addressError = 'Failed to derive wallet address: $e';
        _loadingAddress = false;
      });
    }
  }

  String _buildQrString(
    String address,
    double kasAmount,
    List<CartItem> items,
    double totalIdr,
  ) {
    final payload = jsonEncode({
      'items': items
          .map((i) => {
                'name': i.product.name,
                'qty': i.quantity,
                'price_idr': i.product.price,
              })
          .toList(),
      'total_idr': totalIdr,
    });
    final b64 = base64Url.encode(utf8.encode(payload));
    var kasStr = kasAmount.toStringAsFixed(8);
    kasStr = kasStr.replaceAll(RegExp(r'0+$'), '');
    if (kasStr.endsWith('.')) kasStr += '00000001';
    final bare = address.startsWith('kaspa:') ? address.substring(6) : address;
    return 'kaspa:$bare?amount=$kasStr&payload=$b64';
  }

  /// Format a price with the currency symbol/code after the number.
  String _formatSuffixed(
    double idrPrice,
    CurrencyState currencyState,
    String kasSymbol,
  ) {
    final code = currencyState.selectedCurrency.code;
    final kasIdr = currencyState.exchangeRates['idr'] ?? 0;

    if (code == 'IDR' || kasIdr <= 0) {
      final amount = NumberFormat('#,###', 'id_ID').format(idrPrice);
      return '$amount IDR';
    }
    if (currencyState.selectedCurrency.isCrypto) {
      final kas = idrPrice / kasIdr;
      return '${kas.toStringAsFixed(4)} $kasSymbol';
    }
    final kasTarget = currencyState.exchangeRates[code.toLowerCase()] ?? 0;
    if (kasTarget <= 0) return '-- $code';
    final converted = (idrPrice / kasIdr) * kasTarget;
    final decimals = {'JPY', 'KRW'}.contains(code) ? 0 : 2;
    final amount = NumberFormat(
      decimals == 0 ? '#,###' : '#,##0.${'0' * decimals}',
    ).format(converted);
    return '$amount $code';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaspa Payment')),
      body: BlocBuilder<CurrencyCubit, CurrencyState>(
        builder: (context, currencyState) {
          if (_loadingAddress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_addressError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _addressError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }

          final kasIdr = currencyState.exchangeRates['idr'] ?? 0;
          if (kasIdr <= 0) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching exchange rates…'),
                ],
              ),
            );
          }

          final kasAmount = _totalIdr / kasIdr;
          final qrData = _buildQrString(
            _merchantAddress!,
            kasAmount,
            _cartItems,
            _totalIdr,
          );

          return BlocBuilder<NetworkCubit, NetworkState>(
            builder: (context, networkState) {
              final kasSymbol = networkState.kasSymbol;
              final kasStr = kasAmount
                  .toStringAsFixed(8)
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        '$kasStr $kasSymbol',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (!currencyState.selectedCurrency.isCrypto)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: PriceText(
                            _totalIdr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Center(
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 280,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Scan with your Kaspa wallet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Send $kasSymbol only. Sending any other asset will result in permanent loss of funds.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      ..._cartItems.map((item) {
                        final hasAdditions = item.selectedAdditions.isNotEmpty;
                        final qtyStr = item.quantity % 1 == 0
                            ? item.quantity.toInt().toString()
                            : item.quantity.toString();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} × $qtyStr',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    _formatSuffixed(
                                        item.totalPrice, currencyState, kasSymbol),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                              if (hasAdditions)
                                ...item.selectedAdditions.map((a) => Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, left: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '+ ${a.name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                  ),
                                            ),
                                          ),
                                          a.price > 0
                                              ? Text(
                                                  _formatSuffixed(a.price,
                                                      currencyState, kasSymbol),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .outline,
                                                      ),
                                                )
                                              : Text(
                                                  'FREE',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .outline,
                                                      ),
                                                ),
                                        ],
                                      ),
                                    )),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
