class WalletState {
  const WalletState({
    this.mnemonic = '',
    this.address = '',
    this.balanceKas = 0.0,
    this.addressReady = false,
  });

  /// Raw BIP39 mnemonic (empty string if no wallet configured).
  final String mnemonic;

  /// Derived Kaspa address (empty until derivation completes).
  final String address;

  /// Real on-chain KAS balance (UTXOs, in KAS not sompi). 0.0 until fetched.
  final double balanceKas;

  /// True once address derivation has completed (or confirmed no wallet).
  final bool addressReady;

  WalletState copyWith({
    String? mnemonic,
    String? address,
    double? balanceKas,
    bool? addressReady,
  }) => WalletState(
    mnemonic: mnemonic ?? this.mnemonic,
    address: address ?? this.address,
    balanceKas: balanceKas ?? this.balanceKas,
    addressReady: addressReady ?? this.addressReady,
  );
}
