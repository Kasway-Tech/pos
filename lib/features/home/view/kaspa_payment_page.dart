import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kasway/data/services/payload_codec.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/wallet/wallet_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:kasway/app/widgets/line_item_row.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/view/kaspa_confirmation_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    _totalIdr = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

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
            ws.add(
              jsonEncode({
                'id': _reqId++,
                'method': 'getUtxosByAddresses',
                'params': {
                  'addresses': [address],
                },
              }),
            );
          } catch (_) {}
        }

        send();
        _pollSub = Stream.periodic(
          const Duration(seconds: 1),
        ).listen((_) => send());

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

      final invoiceSompi = (_totalIdr / kasIdr * 1e8).floor();

      bool changed = false;

      for (final entry in entries) {
        final key = _outpointKey(entry);
        if (key == null || _knownOutpoints.contains(key)) continue;

        final utxoEntry = entry['utxoEntry'] as Map<String, dynamic>?;
        if (utxoEntry == null) continue;
        final amount =
            int.tryParse(utxoEntry['amount']?.toString() ?? '0') ?? 0;

        if (amount < 1000) continue; // skip dust

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
          '[wRPC] UTXO +$amount sompi  total=$_receivedSompi/$invoiceSompi  txId=$txId',
        );
      }

      if (!changed) return;

      // Payment complete (1 % tolerance).
      if (_receivedSompi >= (invoiceSompi * 0.99).floor()) {
        _wsDisposed = true;
        _pollSub?.cancel();
        _ws?.close().catchError((_) {});

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KaspaConfirmationPage(
                detectedDaaScore: _lastDaaScore,
                totalIdr: _totalIdr,
                cartItems: _cartItems,
                txId: _lastTxId,
              ),
            ),
          );
        }
      } else {
        setState(() {}); // partial — update remaining amount in UI
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
    final p = KaswayPayloadCodec.encode(items, totalIdr);
    var kasStr = kasAmount.toStringAsFixed(8);
    kasStr = kasStr.replaceAll(RegExp(r'0+$'), '');
    if (kasStr.endsWith('.')) kasStr += '00000001';
    return '$address?amount=$kasStr&p=$p';
  }

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
      appBar: BlurAppBar(title: const Text('Payment')),
      body: BlocListener<WalletCubit, WalletState>(
        listenWhen: (prev, curr) => prev.address != curr.address,
        listener: (context, walletState) {
          _wsDisposed = true;
          _pollSub?.cancel();
          _pollSub = null;
          // Use Future.value() fallback so .then() fires even when _ws is null
          // (e.g. address derived before the WebSocket had time to connect).
          (_ws?.close().catchError((_) {}) ?? Future<void>.value()).then((_) {
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
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            }

            if (kasIdr <= 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Fetching exchange rates…',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait a moment.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () =>
                            context.read<CurrencyCubit>().fetchRates(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final totalKas = _totalIdr / kasIdr;
            final receivedKas = _receivedSompi / 1e8;
            final remainingKas = (totalKas - receivedKas).clamp(
              0.0,
              double.infinity,
            );
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

                // --- Left panel: amount, QR, address, warning ---
                final leftChildren = <Widget>[
                  const SizedBox(height: 8),

                  // Amount header
                  Text(
                    '$remainingStr $kasSymbol',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (!hasPartial && !currencyState.selectedCurrency.isCrypto)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: PriceText(
                        _totalIdr,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),

                  // Partial payment progress
                  if (hasPartial) ...[
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: (receivedKas / totalKas).clamp(0.0, 1.0),
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$receivedStr of $totalStr $kasSymbol received',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // QR code
                  Center(
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Address
                  Text(
                    _merchantAddress,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Warning
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Send $kasSymbol only, and exactly the amount shown above. Sending any other asset or incorrect amount might result in funds being lost.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];

                // --- Right panel: items card ---
                final itemsCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      children: _cartItems
                          .map(
                            (item) => LineItemRow(
                              productName: item.product.name,
                              quantity: item.quantity,
                              lineTotal: item.totalPrice,
                              additions: item.selectedAdditions
                                  .map((a) => (name: a.name, price: a.price))
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 720;

                    if (isWide) {
                      // Two-panel layout: 70% left / 30% right
                      return SafeArea(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left — scrollable, content centered at 400px max
                            Expanded(
                              flex: 7,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight - 48,
                                  ),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 400,
                                      ),
                                      child: Column(children: leftChildren),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Right — full-height card with scrollable list
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8,
                                  24,
                                  24,
                                  24,
                                ),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          8,
                                        ),
                                        child: Text(
                                          'Order List',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          children: _cartItems
                                              .map(
                                                (item) => LineItemRow(
                                                  productName:
                                                      item.product.name,
                                                  quantity: item.quantity,
                                                  lineTotal: item.totalPrice,
                                                  additions: item
                                                      .selectedAdditions
                                                      .map(
                                                        (a) => (
                                                          name: a.name,
                                                          price: a.price,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Single-column layout (mobile / portrait tablet)
                    return SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            ...leftChildren,
                            const SizedBox(height: 8),
                            itemsCard,
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    ));
  }
}
