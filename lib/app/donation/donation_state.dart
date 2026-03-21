enum DonationMode { percentage, fixedAmount }

class DonationConstants {
  static const String address =
      'kaspa:qypr7ayn2g55fccyv9n6gf9zgrcnpepkfgjf9d8mtfp68ezv3mgqnggxqs902q4';
  static const String testnetAddress =
      'kaspatest:qqpszxcffsw766keg4lj0raq30ac2y0ul9u89luu00xwzrsymcr0xe9m06qlp';

  static String addressForHrp(String hrp) =>
      hrp == 'kaspa' ? address : testnetAddress;
}

class DonationState {
  const DonationState({
    this.autoEnabled = false,
    this.mode = DonationMode.percentage,
    this.percentageValue = 1.0,
    this.fixedKasAmount = 1.0,
  });

  final bool autoEnabled;
  final DonationMode mode;
  final double percentageValue;
  final double fixedKasAmount;

  DonationState copyWith({
    bool? autoEnabled,
    DonationMode? mode,
    double? percentageValue,
    double? fixedKasAmount,
  }) => DonationState(
    autoEnabled: autoEnabled ?? this.autoEnabled,
    mode: mode ?? this.mode,
    percentageValue: percentageValue ?? this.percentageValue,
    fixedKasAmount: fixedKasAmount ?? this.fixedKasAmount,
  );
}
