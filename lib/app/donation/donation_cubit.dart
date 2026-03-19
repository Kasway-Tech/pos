import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'donation_state.dart';

class DonationCubit extends Cubit<DonationState> {
  DonationCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const DonationState()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _keyAutoEnabled = 'donation_auto_enabled';
  static const _keyMode = 'donation_mode';
  static const _keyPercentage = 'donation_percentage';
  static const _keyFixedKas = 'donation_fixed_kas';

  void _load() {
    final autoEnabled = _prefs.getBool(_keyAutoEnabled) ?? false;
    final modeStr = _prefs.getString(_keyMode) ?? 'percentage';
    final mode = modeStr == 'fixedAmount'
        ? DonationMode.fixedAmount
        : DonationMode.percentage;
    final percentageValue = _prefs.getDouble(_keyPercentage) ?? 1.0;
    final fixedKasAmount = _prefs.getDouble(_keyFixedKas) ?? 1.0;

    emit(DonationState(
      autoEnabled: autoEnabled,
      mode: mode,
      percentageValue: percentageValue,
      fixedKasAmount: fixedKasAmount,
    ));
  }

  Future<void> setAutoEnabled(bool value) async {
    await _prefs.setBool(_keyAutoEnabled, value);
    emit(state.copyWith(autoEnabled: value));
  }

  Future<void> setMode(DonationMode mode) async {
    await _prefs.setString(
        _keyMode, mode == DonationMode.fixedAmount ? 'fixedAmount' : 'percentage');
    emit(state.copyWith(mode: mode));
  }

  Future<void> setPercentage(double value) async {
    await _prefs.setDouble(_keyPercentage, value);
    emit(state.copyWith(percentageValue: value));
  }

  Future<void> setFixedAmount(double value) async {
    await _prefs.setDouble(_keyFixedKas, value);
    emit(state.copyWith(fixedKasAmount: value));
  }
}
