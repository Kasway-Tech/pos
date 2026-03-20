import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/donation/donation_cubit.dart';
import 'package:kasway/app/donation/donation_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/repositories/donation_repository.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';

class KaspaConfirmationPage extends StatefulWidget {
  const KaspaConfirmationPage({
    super.key,
    required this.detectedDaaScore,
    required this.totalIdr,
    required this.cartItems,
    required this.txId,
    this.excessSompi = 0,
  });

  final int detectedDaaScore;
  final double totalIdr;
  final List<CartItem> cartItems;
  final String txId;
  /// Sompi overpaid by the customer. When > 0 a refund is attempted after
  /// the transaction is confirmed so the indexer has time to persist it.
  final int excessSompi;

  @override
  State<KaspaConfirmationPage> createState() => _KaspaConfirmationPageState();
}

class _KaspaConfirmationPageState extends State<KaspaConfirmationPage> {
  static const int _required = 100;

  WebSocket? _ws;
  bool _wsDisposed = false;
  int _reqId = 1;
  StreamSubscription<void>? _pollSub;

  int _currentDaaScore = 0;

  int get _confirmations => _currentDaaScore == 0
      ? 0
      : (_currentDaaScore - widget.detectedDaaScore).clamp(0, _required);

  @override
  void initState() {
    super.initState();
    Future.microtask(_connect);
  }

  @override
  void dispose() {
    _wsDisposed = true;
    _pollSub?.cancel();
    _ws?.close();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!mounted) return;
    final jsonUrl = context.read<NetworkCubit>().state.activeUrl;

    while (!_wsDisposed) {
      try {
        final ws = await WebSocket.connect(jsonUrl);
        if (_wsDisposed) {
          await ws.close();
          return;
        }
        _ws = ws;

        void send() {
          if (!_wsDisposed) {
            ws.add(jsonEncode({
              'id': _reqId++,
              'method': 'getBlockDagInfo',
              'params': {},
            }));
          }
        }

        send();
        _pollSub =
            Stream.periodic(const Duration(seconds: 1)).listen((_) => send());

        await for (final raw in ws) {
          if (_wsDisposed) break;
          if (raw is String) _handleResponse(raw);
        }
      } catch (e) {
        debugPrint('[confirm] error: $e');
      } finally {
        await _pollSub?.cancel();
        _pollSub = null;
      }

      if (_wsDisposed) return;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  void _handleResponse(String raw) {
    if (_wsDisposed) return;
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      debugPrint('[confirm] raw: $msg');
      final params = msg['params'] as Map<String, dynamic>?;
      if (params == null) {
        debugPrint('[confirm] no params');
        return;
      }
      final scoreRaw = params['virtualDaaScore'];
      debugPrint('[confirm] virtualDaaScore=$scoreRaw detectedDaaScore=${widget.detectedDaaScore}');
      if (scoreRaw == null) return;
      final score =
          scoreRaw is int ? scoreRaw : int.tryParse(scoreRaw.toString()) ?? 0;
      setState(() => _currentDaaScore = score);
      debugPrint('[confirm] confirmations=$_confirmations/$_required');
      if (_confirmations >= _required) _onConfirmed();
    } catch (e) {
      debugPrint('[confirm] parse error: $e  raw=$raw');
    }
  }

  void _onConfirmed() {
    if (!mounted) return;
    _wsDisposed = true; // stop polling
    final network = context.read<NetworkCubit>().state.network.name;
    _tryAutoDonate(network: network);
    if (widget.excessSompi > 2600) {
      final networkState = context.read<NetworkCubit>().state;
      _tryRefund(
        excessSompi: widget.excessSompi,
        txId: widget.txId,
        hrp: networkState.addressHrp,
        activeUrl: networkState.activeUrl,
      );
    }
    final kasIdr =
        context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
    final kasAmount = kasIdr > 0 ? widget.totalIdr / kasIdr : 0.0;
    context.read<HomeBloc>()
      ..add(HomeOrderCompleted(
        totalIdr: widget.totalIdr,
        cartItems: widget.cartItems,
        kasAmount: kasAmount,
        kasIdrRate: kasIdr,
        txId: widget.txId,
        network: network,
      ))
      ..add(HomeCartCleared());
    context.go('/payment-success');
  }

  void _tryAutoDonate({required String network}) {
    final donationState = context.read<DonationCubit>().state;
    if (!donationState.autoEnabled) return;
    final networkState = context.read<NetworkCubit>().state;
    final hrp = networkState.addressHrp;
    if (hrp != 'kaspa') return; // mainnet only
    final walletState = context.read<WalletCubit>().state;
    if (walletState.mnemonic.isEmpty) return;
    final kasIdr =
        context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
    if (kasIdr <= 0) return;

    final double donationKas;
    if (donationState.mode == DonationMode.percentage) {
      final totalKas = widget.totalIdr / kasIdr;
      donationKas = totalKas * (donationState.percentageValue / 100);
    } else {
      donationKas = donationState.fixedKasAmount;
    }
    if (donationKas <= 0) return;

    // Capture repository before async gap to avoid stale context access.
    final repo = context.read<DonationRepository>();
    _doAutoDonate(
      mnemonic: walletState.mnemonic,
      donationKas: donationKas,
      hrp: hrp,
      activeUrl: networkState.activeUrl,
      network: network,
      repo: repo,
    );
  }

  // ---------------------------------------------------------------------------
  // Overpayment refund — called post-confirmation so the indexer has the tx
  // ---------------------------------------------------------------------------

  Future<void> _tryRefund({
    required int excessSompi,
    required String txId,
    required String hrp,
    required String activeUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mnemonic = prefs.getString('wallet_mnemonic') ?? '';
      if (mnemonic.isEmpty) {
        debugPrint('[refund] no mnemonic, skipping');
        return;
      }

      final senderAddress = await _resolveSenderAddress(
        txId: txId,
        hrp: hrp,
        activeUrl: activeUrl,
      );
      if (senderAddress == null) {
        debugPrint('[refund] sender address unresolvable for $txId');
        return;
      }

      debugPrint('[refund] returning $excessSompi sompi → $senderAddress');

      final result = await KaspaWalletService().sendTransaction(
        mnemonic: mnemonic,
        toAddress: senderAddress,
        amountSompi: excessSompi,
        payloadNote:
            'kasway:refund:${DateTime.now().toUtc().toIso8601String()}',
        hrp: hrp,
        activeUrl: activeUrl,
      );

      if (result.error.isNotEmpty) {
        debugPrint('[refund] send failed: ${result.error}');
      } else {
        debugPrint('[refund] success txId=${result.txId}');
      }
    } catch (e) {
      debugPrint('[refund] error: $e');
    }
  }

  Future<String?> _resolveSenderAddress({
    required String txId,
    required String hrp,
    required String activeUrl,
  }) async {
    final wRpcAddress = await _resolveSenderViaWrpc(
        txId: txId, hrp: hrp, activeUrl: activeUrl);
    if (wRpcAddress != null) return wRpcAddress;

    if (hrp != 'kaspa') return null;
    return _resolveSenderViaRest(txId: txId);
  }

  Future<String?> _resolveSenderViaWrpc({
    required String txId,
    required String hrp,
    required String activeUrl,
  }) async {
    final payingTx =
        await _fetchTransactionWrpc(txId: txId, activeUrl: activeUrl);
    if (payingTx == null) {
      debugPrint('[refund] wRPC: paying tx null');
      return null;
    }

    final inputs = payingTx['inputs'] as List<dynamic>?;
    debugPrint(
        '[refund] wRPC: inputs=${inputs?.length ?? "null"}  keys=${payingTx.keys.join(",")}');
    if (inputs == null || inputs.isEmpty) return null;

    final input0 = inputs[0] as Map<String, dynamic>?;
    final prevOutpoint =
        input0?['previousOutpoint'] as Map<String, dynamic>?;
    if (prevOutpoint == null) return null;

    final prevTxId = prevOutpoint['transactionId']?.toString() ?? '';
    final prevIndex =
        int.tryParse(prevOutpoint['index']?.toString() ?? '0') ?? 0;
    debugPrint(
        '[refund] wRPC: prevTxId=${prevTxId.isEmpty ? "empty" : "ok"}  prevIndex=$prevIndex');
    if (prevTxId.isEmpty) return null;

    final prevTx =
        await _fetchTransactionWrpc(txId: prevTxId, activeUrl: activeUrl);
    if (prevTx == null) {
      debugPrint('[refund] wRPC: prev tx null');
      return null;
    }

    final outputs = prevTx['outputs'] as List<dynamic>?;
    debugPrint('[refund] wRPC: prev tx outputs=${outputs?.length ?? "null"}');
    if (outputs == null || outputs.length <= prevIndex) return null;

    final output = outputs[prevIndex] as Map<String, dynamic>?;
    if (output == null) return null;

    final verboseAddress =
        (output['verboseData'] as Map<String, dynamic>?)?['scriptPublicKeyAddress']
            ?.toString();
    if (verboseAddress != null && verboseAddress.isNotEmpty) {
      debugPrint('[refund] wRPC: resolved via verboseData');
      return verboseAddress;
    }

    final spkRaw = output['scriptPublicKey'];
    debugPrint('[refund] wRPC: scriptPublicKey type=${spkRaw.runtimeType}');
    final String compactSpkHex;
    if (spkRaw is String) {
      compactSpkHex = spkRaw;
    } else if (spkRaw is Map<String, dynamic>) {
      final ver = (spkRaw['version'] as num?)?.toInt() ?? 0;
      final versionHex = ver.toRadixString(16).padLeft(2, '0');
      final scriptHex = spkRaw['scriptPublicKey']?.toString() ?? '';
      compactSpkHex = '${versionHex}00$scriptHex';
    } else {
      debugPrint('[refund] wRPC: unrecognised scriptPublicKey shape');
      return null;
    }

    final addr = KaspaWalletService.scriptToAddress(compactSpkHex, hrp: hrp);
    debugPrint('[refund] wRPC: scriptToAddress → ${addr ?? "null"}');
    return addr;
  }

  Future<Map<String, dynamic>?> _fetchTransactionWrpc({
    required String txId,
    required String activeUrl,
  }) async {
    WebSocket? ws;
    const reqId = 9001;
    try {
      ws = await WebSocket.connect(activeUrl)
          .timeout(const Duration(seconds: 10));

      final completer = Completer<Map<String, dynamic>?>();

      ws.listen(
        (raw) {
          if (raw is! String || completer.isCompleted) return;
          try {
            final msg = jsonDecode(raw) as Map<String, dynamic>;
            if ((msg['id'] as num?)?.toInt() != reqId) return;
            if (msg.containsKey('error')) {
              debugPrint('[refund] getTransaction error: ${msg['error']}');
              completer.complete(null);
              return;
            }
            final tx =
                (msg['params'] as Map<String, dynamic>?)?['transaction']
                    as Map<String, dynamic>?;
            debugPrint('[refund] getTransaction ok: ${tx != null}');
            completer.complete(tx);
          } catch (e) {
            debugPrint('[refund] parse error: $e');
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        onError: (e) {
          debugPrint('[refund] ws error: $e');
          if (!completer.isCompleted) completer.complete(null);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      ws.add(jsonEncode({
        'id': reqId,
        'method': 'getTransaction',
        'params': {'transactionId': txId, 'includeAcceptingBlockHash': false},
      }));

      return await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[refund] fetchTransaction error: $e');
      return null;
    } finally {
      await ws?.close();
    }
  }

  Future<String?> _resolveSenderViaRest({required String txId}) async {
    const base = 'https://api.kaspa.org';
    try {
      final r1 = await http
          .get(Uri.parse('$base/transactions/$txId?inputs=true&outputs=true'))
          .timeout(const Duration(seconds: 10));
      debugPrint('[refund] REST step1 status=${r1.statusCode}');
      if (r1.statusCode != 200) return null;

      final tx = jsonDecode(r1.body) as Map<String, dynamic>;
      debugPrint('[refund] REST tx keys=${tx.keys.join(",")}');
      final inputs = tx['inputs'] as List<dynamic>?;
      debugPrint('[refund] REST inputs=${inputs?.length ?? "null"}');
      if (inputs == null || inputs.isEmpty) return null;

      final input = inputs[0] as Map<String, dynamic>;
      debugPrint('[refund] REST input[0] keys=${input.keys.join(",")}');

      final directAddress = input['script_public_key_address']?.toString();
      if (directAddress != null && directAddress.isNotEmpty) {
        debugPrint('[refund] REST: address on input directly');
        return directAddress;
      }

      final prevHash = input['previous_outpoint_hash']?.toString() ?? '';
      final prevIndex =
          int.tryParse(input['previous_outpoint_index']?.toString() ?? '0') ??
              0;
      debugPrint(
          '[refund] REST prevHash=${prevHash.isEmpty ? "empty" : "ok"}  prevIndex=$prevIndex');
      if (prevHash.isEmpty) return null;

      final r2 = await http
          .get(Uri.parse('$base/transactions/$prevHash?outputs=true'))
          .timeout(const Duration(seconds: 10));
      debugPrint('[refund] REST step2 status=${r2.statusCode}');
      if (r2.statusCode != 200) return null;

      final prevTx = jsonDecode(r2.body) as Map<String, dynamic>;
      final outputs = prevTx['outputs'] as List<dynamic>?;
      debugPrint('[refund] REST prevTx outputs=${outputs?.length ?? "null"}');
      if (outputs == null || outputs.length <= prevIndex) return null;

      final output = outputs[prevIndex] as Map<String, dynamic>?;
      debugPrint('[refund] REST output keys=${output?.keys.join(",") ?? "null"}');
      final address = output?['script_public_key_address']?.toString();
      debugPrint(
          '[refund] REST resolved sender: ${address != null ? "ok" : "null"}');
      return address;
    } catch (e) {
      debugPrint('[refund] REST error: $e');
      return null;
    }
  }

  Future<void> _doAutoDonate({
    required String mnemonic,
    required double donationKas,
    required String hrp,
    required String activeUrl,
    required String network,
    required DonationRepository repo,
  }) async {
    final result = await KaspaWalletService().sendTransaction(
      mnemonic: mnemonic,
      toAddress: DonationConstants.address,
      amountSompi: (donationKas * 1e8).toInt(),
      payloadNote:
          'kasway:donate:${DateTime.now().toUtc().toIso8601String()}',
      hrp: hrp,
      activeUrl: activeUrl,
    );
    if (result.error.isEmpty) {
      await repo.recordDonation(
        txId: result.txId,
        amountKas: donationKas,
        isAuto: true,
        network: network,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: _buildConfirming(),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirming() {
    final targetProgress = (_confirmations / _required).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: targetProgress),
      // 1200ms > 1s poll interval → feels like continuous linear motion
      duration: const Duration(milliseconds: 1200),
      curve: Curves.linear,
      builder: (context, value, _) {
        final count = (value * _required).round();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/kw-confirm.json',
              width: 180,
              height: 180,
              repeat: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Confirming Payment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we verify your transaction on the Kaspa network.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: value, minHeight: 8),
            const SizedBox(height: 12),
            Text(
              '$count / $_required confirmations',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}
