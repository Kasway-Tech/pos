import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/network_cubit.dart';
import '../network/network_state.dart';
import '../../data/services/kaspa_wallet_service.dart';
import 'wallet_state.dart';

/// App-level cubit that owns mnemonic, derived address, and on-chain balance.
/// Created once in app.dart; pages read from it instead of loading their own.
class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    required SharedPreferences prefs,
    required NetworkCubit networkCubit,
  })  : _prefs = prefs,
        _networkCubit = networkCubit,
        super(const WalletState()) {
    _init();
    _networkSub = networkCubit.stream.listen(_onNetworkChange);
  }

  final SharedPreferences _prefs;
  final NetworkCubit _networkCubit;
  late final StreamSubscription<NetworkState> _networkSub;

  Future<void> _init() async {
    final mnemonic = _prefs.getString('wallet_mnemonic') ?? '';
    if (mnemonic.isEmpty) {
      emit(state.copyWith(mnemonic: '', address: '', addressReady: true));
      return;
    }

    final hrp = _networkCubit.state.addressHrp;
    final address = await Future.microtask(
      () => KaspaWalletService().deriveAddress(mnemonic, hrp: hrp),
    );
    if (isClosed) return;

    emit(state.copyWith(
      mnemonic: mnemonic,
      address: address,
      addressReady: true,
    ));

    unawaited(_fetchBalance(address));
  }

  Future<void> _onNetworkChange(NetworkState networkState) async {
    final mnemonic = state.mnemonic;
    if (mnemonic.isEmpty) return;

    emit(state.copyWith(addressReady: false, address: ''));
    final address = await Future.microtask(
      () => KaspaWalletService().deriveAddress(
        mnemonic,
        hrp: networkState.addressHrp,
      ),
    );
    if (isClosed) return;

    emit(state.copyWith(address: address, addressReady: true));
    unawaited(_fetchBalance(address));
  }

  Future<void> _fetchBalance(String address) async {
    if (address.isEmpty) return;
    final url = _networkCubit.state.activeUrl;
    try {
      final ws =
          await WebSocket.connect(url).timeout(const Duration(seconds: 10));
      final completer = Completer<double>();
      StreamSubscription? sub;
      sub = ws.listen(
        (raw) {
          if (raw is! String) return;
          try {
            final msg = jsonDecode(raw) as Map<String, dynamic>;
            final params = msg['params'] as Map<String, dynamic>?;
            final entries = params?['entries'] as List<dynamic>?;
            if (entries == null) return;
            double total = 0;
            for (final entry in entries) {
              final utxo = (entry as Map<String, dynamic>?)?['utxoEntry']
                  as Map<String, dynamic>?;
              final sompi =
                  int.tryParse(utxo?['amount']?.toString() ?? '0') ?? 0;
              total += sompi / 1e8;
            }
            if (!completer.isCompleted) completer.complete(total);
          } catch (_) {}
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(0.0);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(0.0);
        },
      );
      ws.add(jsonEncode({
        'id': 1,
        'method': 'getUtxosByAddresses',
        'params': {
          'addresses': [address],
        },
      }));
      try {
        final balance =
            await completer.future.timeout(const Duration(seconds: 10));
        if (!isClosed) emit(state.copyWith(balanceKas: balance));
      } finally {
        await sub.cancel();
        await ws.close();
      }
    } catch (_) {}
  }

  /// Re-fetch the on-chain balance. Call after a withdrawal or payment.
  Future<void> refreshBalance() => _fetchBalance(state.address);

  @override
  Future<void> close() {
    _networkSub.cancel();
    return super.close();
  }
}
