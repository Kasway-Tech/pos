import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/line_item_row.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/wallet/wallet_state.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/view/kaspa_confirmation_page.dart';

class KaspaPaymentPage extends StatefulWidget {
  const KaspaPaymentPage({super.key});

  @override
  State<KaspaPaymentPage> createState() => _KaspaPaymentPageState();
}

class _KaspaPaymentPageState extends State<KaspaPaymentPage> {
  List<CartItem> _cartItems = [];
  double _totalIdr = 0;
  bool _initialized = false;
  String _merchantAddress = '';

  WebSocket? _ws;
  bool _wsDisposed = false;
  int _reqId = 1;
  StreamSubscription<void>? _pollSub;

  final Set<String> _knownOutpoints = {};
  bool _baselineLoaded = false;

  // Partial payment tracking
  int _receivedSompi = 0;
  final List<({int amountSompi, String txId})> _partialPayments = [];
  int _lastDaaScore = 0;
  String _lastTxId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final state = context.read<HomeBloc>().state;
    _cartItems = state.cartItems;
    _totalIdr = _cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

    _merchantAddress = context.read<WalletCubit>().state.address;
    Future.microtask(_connectWrpc);
  }

  @override
  void dispose() {
    _wsDisposed = true;
    _pollSub?.cancel();
    _ws?.close();
    super.dispose();
  }

  Future<void> _connectWrpc() async {
    if (!mounted || _merchantAddress.isEmpty) return;
    final jsonUrl = context.read<NetworkCubit>().state.activeUrl;
    final address = _merchantAddress;

    while (!_wsDisposed) {
      try {
        final ws = await WebSocket.connect(jsonUrl);
        if (_wsDisposed) {
          await ws.close();
          return;
        }
        _ws = ws;

        void send() {
          if (_wsDisposed || ws.readyState != WebSocket.open) return;
          try {
            ws.add(jsonEncode({
              'id': _reqId++,
              'method': 'getUtxosByAddresses',
              'params': {'addresses': [address]},
            }));
          } catch (_) {}
        }

        send();
        _pollSub =
            Stream.periodic(const Duration(seconds: 1)).listen((_) => send());

        await for (final raw in ws) {
          if (_wsDisposed) break;
          if (raw is String) _handleResponse(raw);
        }
      } catch (e) {
        debugPrint('[wRPC] error: $e');
      } finally {
        await _pollSub?.cancel();
        _pollSub = null;
      }

      if (_wsDisposed) return;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  void _handleResponse(String raw) {
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      final params = msg['params'] as Map<String, dynamic>?;
      if (params == null) return;
      final entries = params['entries'] as List<dynamic>?;
      if (entries == null) return;

      if (!_baselineLoaded) {
        for (final entry in entries) {
          final key = _outpointKey(entry);
          if (key != null) _knownOutpoints.add(key);
        }
        _baselineLoaded = true;
        debugPrint('[wRPC] baseline: ${_knownOutpoints.length} existing UTXOs');
        return;
      }

      final kasIdr =
          context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
      if (kasIdr <= 0) return;

      // Full invoice amount in sompi (no pre-applied tolerance here — we apply
      // it to the accumulated total below).
      final invoiceSompi = (_totalIdr / kasIdr * 1e8).floor();

      bool changed = false;

      for (final entry in entries) {
        final key = _outpointKey(entry);
        if (key == null || _knownOutpoints.contains(key)) continue;

        final utxoEntry = entry['utxoEntry'] as Map<String, dynamic>?;
        if (utxoEntry == null) continue;
        final amount =
            int.tryParse(utxoEntry['amount']?.toString() ?? '0') ?? 0;

        // Skip dust (< 1000 sompi).
        if (amount < 1000) continue;

        // Mark as seen so we never double-count.
        _knownOutpoints.add(key);

        final daaScore =
            int.tryParse(utxoEntry['blockDaaScore']?.toString() ?? '0') ?? 0;
        final txId =
            (entry['outpoint'] as Map<String, dynamic>?)?['transactionId']
                    ?.toString() ??
                '';

        _receivedSompi += amount;
        _lastDaaScore = daaScore;
        _lastTxId = txId;
        _partialPayments.add((amountSompi: amount, txId: txId));
        changed = true;

        debugPrint(
            '[wRPC] UTXO +$amount sompi  total=$_receivedSompi/$invoiceSompi  txId=$txId');
      }

      if (!changed) return;

      // 1 % tolerance on the accumulated total.
      if (_receivedSompi >= (invoiceSompi * 0.99).floor()) {
        _wsDisposed = true;
        _pollSub?.cancel();
        _ws?.close().catchError((_) {});

        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => KaspaConfirmationPage(
              detectedDaaScore: _lastDaaScore,
              totalIdr: _totalIdr,
              cartItems: _cartItems,
              txId: _lastTxId,
            ),
          ));
        }
      } else {
        // Partial — update UI to show remaining amount.
        setState(() {});
      }
    } catch (e) {
      debugPrint('[wRPC] parse error: $e');
    }
  }

  String? _outpointKey(dynamic entry) {
    final outpoint =
        (entry as Map<String, dynamic>?)?['outpoint'] as Map<String, dynamic>?;
    if (outpoint == null) return null;
    final txId = outpoint['transactionId']?.toString() ?? '';
    final index = outpoint['index']?.toString() ?? '0';
    return '$txId:$index';
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
    return '$address?amount=$kasStr&payload=$b64';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(title: const Text('Kaspa Payment')),
      body: BlocListener<WalletCubit, WalletState>(
        listenWhen: (prev, curr) => prev.address != curr.address,
        listener: (context, walletState) {
          _wsDisposed = true;
          _pollSub?.cancel();
          _pollSub = null;
          _ws?.close().catchError((_) {}).then((_) {
            if (!mounted) return;
            setState(() {
              _wsDisposed = false;
              _ws = null;
              _merchantAddress = walletState.address;
              _knownOutpoints.clear();
              _baselineLoaded = false;
              _receivedSompi = 0;
              _partialPayments.clear();
              _lastDaaScore = 0;
              _lastTxId = '';
            });
            Future.microtask(_connectWrpc);
          });
        },
        child: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            final kasIdr = currencyState.exchangeRates['idr'] ?? 0;

            if (_merchantAddress.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No wallet configured. Please set up your wallet first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            if (kasIdr <= 0) {
              return BlocBuilder<NetworkCubit, NetworkState>(
                builder: (context, networkState) => Center(
                  child: Text(
                    '-- ${networkState.kasSymbol}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            final totalKas = _totalIdr / kasIdr;
            final receivedKas = _receivedSompi / 1e8;
            final remainingKas =
                (totalKas - receivedKas).clamp(0.0, double.infinity);
            final hasPartial = _partialPayments.isNotEmpty;

            final qrData = _buildQrString(
              _merchantAddress,
              remainingKas,
              _cartItems,
              _totalIdr,
            );

            return BlocBuilder<NetworkCubit, NetworkState>(
              builder: (context, networkState) {
                final kasSymbol = networkState.kasSymbol;

                String kasFormat(double kas) => kas
                    .toStringAsFixed(8)
                    .replaceAll(RegExp(r'0+$'), '')
                    .replaceAll(RegExp(r'\.$'), '');

                final remainingStr = kasFormat(remainingKas);
                final totalStr = kasFormat(totalKas);
                final receivedStr = kasFormat(receivedKas);

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // --- Amount header ---
                        if (hasPartial) ...[
                          Text(
                            '$remainingStr $kasSymbol',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'remaining of $totalStr $kasSymbol',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Text(
                            '$remainingStr $kasSymbol',
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                            ),
                        ],

                        // --- Partial payment banner ---
                        if (hasPartial) ...[
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.amber.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.amber.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: Colors.amber.shade800, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Partial payment received',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Colors.amber.shade900,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$receivedStr $kasSymbol received · $remainingStr $kasSymbol still needed',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color:
                                                      Colors.amber.shade800),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Please scan the updated QR code to pay the remaining amount.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color:
                                                      Colors.amber.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // --- QR code ---
                        Center(
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _merchantAddress,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan with your Kaspa wallet',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // --- KAS-only warning ---
                        Card(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
                        ..._cartItems.map((item) => LineItemRow(
                              productName: item.product.name,
                              quantity: item.quantity,
                              lineTotal: item.totalPrice,
                              additions: item.selectedAdditions
                                  .map((a) =>
                                      (name: a.name, price: a.price))
                                  .toList(),
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
