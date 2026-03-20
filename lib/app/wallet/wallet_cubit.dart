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

  // Persistent WebSocket state
  WebSocket? _ws;
  StreamSubscription? _wsSub;
  Timer? _pingTimer;
  bool _disposed = false;
  int _reqId = 1;
  String _connectedUrl = '';

  static const _pingInterval = Duration(seconds: 1);
  static const _reconnectDelay = Duration(seconds: 3);

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

    unawaited(_connect(address));
  }

  Future<void> _onNetworkChange(NetworkState networkState) async {
    final mnemonic = state.mnemonic;
    if (mnemonic.isEmpty) return;

    await _disconnect();

    emit(state.copyWith(addressReady: false, address: ''));
    final address = await Future.microtask(
      () => KaspaWalletService().deriveAddress(
        mnemonic,
        hrp: networkState.addressHrp,
      ),
    );
    if (isClosed) return;

    emit(state.copyWith(address: address, addressReady: true));
    unawaited(_connect(address));
  }

  Future<void> _connect(String address) async {
    if (_disposed || address.isEmpty) return;

    final url = _networkCubit.state.activeUrl;
    _connectedUrl = url;

    try {
      final ws = await WebSocket.connect(url)
          .timeout(const Duration(seconds: 10));
      if (_disposed || isClosed || _connectedUrl != url) {
        await ws.close();
        return;
      }

      _ws = ws;
      _wsSub = ws.listen(
        _onMessage,
        onError: (_) => unawaited(_reconnect(address)),
        onDone: () => unawaited(_reconnect(address)),
      );

      // Poll once immediately, then every second.
      _sendUtxoRequest(address);
      _pingTimer = Timer.periodic(_pingInterval, (_) {
        _sendUtxoRequest(address);
      });
    } catch (_) {
      unawaited(_reconnect(address));
    }
  }

  void _sendUtxoRequest(String address) {
    try {
      _ws?.add(jsonEncode({
        'id': _reqId++,
        'method': 'getUtxosByAddresses',
        'params': {'addresses': [address]},
      }));
    } catch (_) {}
  }

  void _onMessage(dynamic raw) {
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
        final sompi = int.tryParse(utxo?['amount']?.toString() ?? '0') ?? 0;
        total += sompi / 1e8;
      }
      if (!isClosed) emit(state.copyWith(balanceKas: total));
    } catch (_) {}
  }

  Future<void> _reconnect(String address) async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _wsSub?.cancel();
    _wsSub = null;
    try { await _ws?.close(); } catch (_) {}
    _ws = null;

    if (_disposed || isClosed) return;
    await Future<void>.delayed(_reconnectDelay);
    if (_disposed || isClosed) return;
    unawaited(_connect(address));
  }

  Future<void> _disconnect() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _wsSub?.cancel();
    _wsSub = null;
    try { await _ws?.close(); } catch (_) {}
    _ws = null;
  }

  /// Called after a new mnemonic is saved (onboarding / wallet import).
  /// Derives the address and connects; resolves when address is ready.
  Future<void> loadWallet(String mnemonic) async {
    if (mnemonic.isEmpty) return;
    await _disconnect();
    emit(state.copyWith(mnemonic: mnemonic, address: '', addressReady: false));
    final hrp = _networkCubit.state.addressHrp;
    final address = await Future.microtask(
      () => KaspaWalletService().deriveAddress(mnemonic, hrp: hrp),
    );
    if (isClosed) return;
    emit(state.copyWith(address: address, addressReady: true));
    unawaited(_connect(address));
  }

  /// Immediately re-fetch balance. The persistent connection will also pick
  /// up the change within 1 second automatically.
  void refreshBalance() => _sendUtxoRequest(state.address);

  @override
  Future<void> close() {
    _disposed = true;
    _disconnect();
    _networkSub.cancel();
    return super.close();
  }
}
