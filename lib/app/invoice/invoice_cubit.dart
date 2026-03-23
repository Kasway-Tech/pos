import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const InvoiceState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    emit(InvoiceState(
      enabled: _prefs.getBool(PreferenceKeys.invoiceEnabled) ?? false,
      businessName:
          _prefs.getString(PreferenceKeys.invoiceBusinessName) ?? '',
      businessAddress:
          _prefs.getString(PreferenceKeys.invoiceBusinessAddress) ?? '',
      businessPhone:
          _prefs.getString(PreferenceKeys.invoiceBusinessPhone) ?? '',
      footerText: _prefs.getString(PreferenceKeys.invoiceFooterText) ?? '',
    ));
  }

  /// Enables or disables invoice printing.
  /// Enabling is silently ignored when [isConfigured] is false.
  Future<void> setEnabled(bool value) async {
    if (value && !state.isConfigured) return;
    await _prefs.setBool(PreferenceKeys.invoiceEnabled, value);
    emit(state.copyWith(enabled: value));
  }

  /// Batch-saves all business info fields at once.
  Future<void> setBusinessInfo({
    required String name,
    required String address,
    required String phone,
    required String footer,
  }) async {
    await Future.wait([
      _prefs.setString(PreferenceKeys.invoiceBusinessName, name),
      _prefs.setString(PreferenceKeys.invoiceBusinessAddress, address),
      _prefs.setString(PreferenceKeys.invoiceBusinessPhone, phone),
      _prefs.setString(PreferenceKeys.invoiceFooterText, footer),
    ]);
    emit(state.copyWith(
      businessName: name,
      businessAddress: address,
      businessPhone: phone,
      footerText: footer,
    ));
  }
}
