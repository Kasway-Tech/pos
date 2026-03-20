import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/donation/donation_cubit.dart';
import 'package:kasway/app/donation/donation_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/table/table_cubit.dart';
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
  });

  final int detectedDaaScore;
  final double totalIdr;
  final List<CartItem> cartItems;
  final String txId;

  @override
  State<KaspaConfirmationPage> createState() => _KaspaConfirmationPageState();
}

class _KaspaConfirmationPageState extends State<KaspaConfirmationPage> {
  static const int _required = 50;

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
    final kasIdr =
        context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
    final kasAmount = kasIdr > 0 ? widget.totalIdr / kasIdr : 0.0;
    final tableCubit = context.read<TableCubit>();
    final selectedTableId = tableCubit.state.selectedTableId;
    final tableLabel = tableCubit.state.selectedTable?.label ?? '';
    context.read<HomeBloc>()
      ..add(HomeOrderCompleted(
        totalIdr: widget.totalIdr,
        cartItems: widget.cartItems,
        kasAmount: kasAmount,
        kasIdrRate: kasIdr,
        txId: widget.txId,
        network: network,
        tableLabel: tableLabel,
      ))
      ..add(HomeCartCleared());
    tableCubit.freeTable(selectedTableId);
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: _buildConfirming(),
            ),
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
