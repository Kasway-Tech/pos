import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/wallet/wallet_state.dart';

void main() {
  group('WalletState', () {
    group('default values', () {
      test('mnemonic defaults to empty string', () {
        expect(const WalletState().mnemonic, isEmpty);
      });

      test('address defaults to empty string', () {
        expect(const WalletState().address, isEmpty);
      });

      test('balanceKas defaults to 0.0', () {
        expect(const WalletState().balanceKas, 0.0);
      });

      test('addressReady defaults to false', () {
        expect(const WalletState().addressReady, isFalse);
      });
    });

    group('copyWith', () {
      const base = WalletState(
        mnemonic: 'word1 word2',
        address: 'kaspa:qtest',
        balanceKas: 42.5,
        addressReady: true,
      );

      test('returns identical state when no args provided', () {
        final copy = base.copyWith();
        expect(copy.mnemonic, base.mnemonic);
        expect(copy.address, base.address);
        expect(copy.balanceKas, base.balanceKas);
        expect(copy.addressReady, base.addressReady);
      });

      test('overrides mnemonic', () {
        final copy = base.copyWith(mnemonic: 'new words here');
        expect(copy.mnemonic, 'new words here');
        expect(copy.address, base.address);
        expect(copy.balanceKas, base.balanceKas);
        expect(copy.addressReady, base.addressReady);
      });

      test('overrides address', () {
        final copy = base.copyWith(address: 'kaspa:qnewaddress');
        expect(copy.address, 'kaspa:qnewaddress');
        expect(copy.mnemonic, base.mnemonic);
      });

      test('overrides balanceKas', () {
        final copy = base.copyWith(balanceKas: 100.0);
        expect(copy.balanceKas, 100.0);
        expect(copy.address, base.address);
      });

      test('overrides addressReady to false', () {
        final copy = base.copyWith(addressReady: false);
        expect(copy.addressReady, isFalse);
        expect(copy.mnemonic, base.mnemonic);
      });

      test('overrides all fields simultaneously', () {
        final copy = base.copyWith(
          mnemonic: 'new mnemonic',
          address: 'kaspa:qnew',
          balanceKas: 0.0,
          addressReady: false,
        );
        expect(copy.mnemonic, 'new mnemonic');
        expect(copy.address, 'kaspa:qnew');
        expect(copy.balanceKas, 0.0);
        expect(copy.addressReady, isFalse);
      });
    });

    group('edge cases', () {
      test('balanceKas can be very large', () {
        const s = WalletState(balanceKas: 1e9);
        expect(s.balanceKas, 1e9);
      });

      test('balanceKas can be fractional', () {
        const s = WalletState(balanceKas: 0.00000001);
        expect(s.balanceKas, closeTo(0.00000001, 1e-15));
      });

      test('empty address is preserved by copyWith', () {
        const s = WalletState(address: 'kaspa:qfull');
        final copy = s.copyWith(address: '');
        expect(copy.address, isEmpty);
      });
    });
  });
}
