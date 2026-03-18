import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    this.isCrypto = false,
    this.iconPath,
  });
  final String code;
  final String name;
  final String flag;
  final bool isCrypto;
  final String? iconPath;
  String get displayName => '$name ($code)';
}

class CurrencyState extends Equatable {
  const CurrencyState({
    this.selectedCurrency = _kDefault,
    this.exchangeRates = const {},
    this.dynamicPricing = true,
    this.isLoading = false,
  });

  static const Currency _kDefault = Currency(
    code: 'KAS',
    name: 'Kaspa',
    flag: '',
    isCrypto: true,
    iconPath: 'assets/svg/payment_methods/kaspa.svg',
  );

  static const List<Currency> allCurrencies = [
    _kDefault,
    Currency(code: 'IDR', name: 'Indonesian Rupiah', flag: '🇮🇩'),
    Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
    Currency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵'),
    Currency(code: 'SGD', name: 'Singapore Dollar', flag: '🇸🇬'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', flag: '🇲🇾'),
    Currency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺'),
    Currency(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', flag: '🇭🇰'),
    Currency(code: 'KRW', name: 'South Korean Won', flag: '🇰🇷'),
  ];

  final Currency selectedCurrency;
  final Map<String, double> exchangeRates;
  final bool dynamicPricing;
  final bool isLoading;

  /// Convert an IDR base price to the selected display currency.
  String formatPrice(double idrPrice) {
    final code = selectedCurrency.code.toLowerCase();
    final kasIdr = exchangeRates['idr'] ?? 0;

    if (selectedCurrency.code == 'IDR' || kasIdr <= 0) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'IDR ',
        decimalDigits: 0,
      ).format(idrPrice);
    }
    if (selectedCurrency.isCrypto) {
      final kas = idrPrice / kasIdr;
      return 'KAS ${kas.toStringAsFixed(4)}';
    }
    final kasTarget = exchangeRates[code] ?? 0;
    if (kasTarget <= 0) return '-- ${selectedCurrency.code}';
    final converted = (idrPrice / kasIdr) * kasTarget;
    final decimals = {'jpy', 'krw', 'idr'}.contains(code) ? 0 : 2;
    return NumberFormat.currency(
      symbol: '${selectedCurrency.code} ',
      decimalDigits: decimals,
    ).format(converted);
  }

  /// Convert an IDR price to the selected display currency as a raw number.
  double idrToDisplay(double idrPrice) {
    final code = selectedCurrency.code.toLowerCase();
    final kasIdr = exchangeRates['idr'] ?? 0;
    if (selectedCurrency.code == 'IDR' || kasIdr <= 0) return idrPrice;
    if (selectedCurrency.isCrypto) return idrPrice / kasIdr;
    final kasTarget = exchangeRates[code] ?? 0;
    if (kasTarget <= 0) return idrPrice;
    return (idrPrice / kasIdr) * kasTarget;
  }

  /// Convert a display-currency amount back to IDR.
  double displayToIdr(double displayAmount) {
    final code = selectedCurrency.code.toLowerCase();
    final kasIdr = exchangeRates['idr'] ?? 0;
    if (selectedCurrency.code == 'IDR' || kasIdr <= 0) return displayAmount;
    if (selectedCurrency.isCrypto) return displayAmount * kasIdr;
    final kasTarget = exchangeRates[code] ?? 0;
    if (kasTarget <= 0) return displayAmount;
    return displayAmount * (kasIdr / kasTarget);
  }

  CurrencyState copyWith({
    Currency? selectedCurrency,
    Map<String, double>? exchangeRates,
    bool? dynamicPricing,
    bool? isLoading,
  }) => CurrencyState(
    selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    exchangeRates: exchangeRates ?? this.exchangeRates,
    dynamicPricing: dynamicPricing ?? this.dynamicPricing,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [
    selectedCurrency.code,
    exchangeRates,
    dynamicPricing,
    isLoading,
  ];
}
