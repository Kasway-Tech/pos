import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'donation_state.dart';

class DonationCubit extends Cubit<DonationState> {
  DonationCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const DonationState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final autoEnabled = _prefs.getBool(PreferenceKeys.donationAutoEnabled) ?? false;
    final modeStr = _prefs.getString(PreferenceKeys.donationMode) ?? 'percentage';
    final mode = modeStr == 'fixedAmount'
        ? DonationMode.fixedAmount
        : DonationMode.percentage;
    final percentageValue = _prefs.getDouble(PreferenceKeys.donationPercentage) ?? 1.0;
    final fixedKasAmount = _prefs.getDouble(PreferenceKeys.donationFixedKas) ?? 1.0;

    emit(DonationState(
      autoEnabled: autoEnabled,
      mode: mode,
      percentageValue: percentageValue,
      fixedKasAmount: fixedKasAmount,
    ));
  }

  Future<void> setAutoEnabled(bool value) async {
    await _prefs.setBool(PreferenceKeys.donationAutoEnabled, value);
    emit(state.copyWith(autoEnabled: value));
  }

  Future<void> setMode(DonationMode mode) async {
    await _prefs.setString(
        PreferenceKeys.donationMode, mode == DonationMode.fixedAmount ? 'fixedAmount' : 'percentage');
    emit(state.copyWith(mode: mode));
  }

  Future<void> setPercentage(double value) async {
    await _prefs.setDouble(PreferenceKeys.donationPercentage, value);
    emit(state.copyWith(percentageValue: value));
  }

  Future<void> setFixedAmount(double value) async {
    await _prefs.setDouble(PreferenceKeys.donationFixedKas, value);
    emit(state.copyWith(fixedKasAmount: value));
  }
}
