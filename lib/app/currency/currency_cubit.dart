import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(const CurrencyState()) {
    _init();
  }

  static const _currencyKey = 'default_currency_code';
  static const _dynamicKey = 'dynamic_pricing';
  static const _coingeckoUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=kaspa&vs_currencies=idr,usd,eur,gbp,jpy,sgd,myr,aud,cny,hkd,krw';

  Timer? _timer;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_currencyKey);
    final dynamic = prefs.getBool(_dynamicKey) ?? true;

    Currency selected = CurrencyState.allCurrencies.first;
    if (code != null) {
      selected =
          CurrencyState.allCurrencies.where((c) => c.code == code).firstOrNull ??
          selected;
    }
    emit(state.copyWith(selectedCurrency: selected, dynamicPricing: dynamic));

    if (dynamic) {
      await _fetchRates();
      _startTimer();
    }
  }

  Future<void> _fetchRates() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await http
          .get(Uri.parse(_coingeckoUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = (data['kaspa'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble()));
        emit(state.copyWith(exchangeRates: rates, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchRates(),
    );
  }

  Future<void> setCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
    emit(state.copyWith(selectedCurrency: currency));
  }

  Future<void> setDynamicPricing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicKey, value);
    if (value) {
      emit(state.copyWith(dynamicPricing: true));
      await _fetchRates();
      _startTimer();
    } else {
      _timer?.cancel();
      emit(state.copyWith(dynamicPricing: false));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
