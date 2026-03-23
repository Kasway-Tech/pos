import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'confirmation_state.dart';

class ConfirmationCubit extends Cubit<ConfirmationState> {
  ConfirmationCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const ConfirmationState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final enabled =
        _prefs.getBool(PreferenceKeys.confirmationEnabled) ?? true;
    final required = (_prefs.getInt(PreferenceKeys.confirmationRequired) ?? 50)
        .clamp(50, 9999);
    emit(ConfirmationState(enabled: enabled, requiredConfirmations: required));
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(PreferenceKeys.confirmationEnabled, value);
    emit(state.copyWith(enabled: value));
  }

  Future<void> setRequiredConfirmations(int value) async {
    final clamped = value.clamp(50, 9999);
    await _prefs.setInt(PreferenceKeys.confirmationRequired, clamped);
    emit(state.copyWith(requiredConfirmations: clamped));
  }
}
