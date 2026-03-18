// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get authTagline => 'Your crypto POS,\nsecured by you.';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authLoginWithSeedPhrase => 'Log in with seed phrase';

  @override
  String get eulaTitle => 'Terms & Conditions';

  @override
  String get eulaLastUpdated => 'Last updated: March 2026';

  @override
  String get eulaMainTitle => 'End User License Agreement';

  @override
  String get eulaSection1Title => '1. Acceptance of Terms';

  @override
  String get eulaSection1Body =>
      'By using Kasway (\"the App\"), you agree to be bound by these Terms and Conditions. If you do not agree, do not use the App.';

  @override
  String get eulaSection2Title => '2. Seed Phrase & Security';

  @override
  String get eulaSection2Body =>
      'The App generates a BIP39 seed phrase that is stored locally on your device. You are solely responsible for keeping your seed phrase safe. Kasway does not store, transmit, or have access to your seed phrase. Loss of your seed phrase means permanent loss of access to your account — there is no recovery option.';

  @override
  String get eulaSection3Title => '3. No Financial Advice';

  @override
  String get eulaSection3Body =>
      'Nothing in the App constitutes financial, investment, or legal advice. Cryptocurrency values are volatile. You bear all risks associated with cryptocurrency transactions.';

  @override
  String get eulaSection4Title => '4. Data & Privacy';

  @override
  String get eulaSection4Body =>
      'All catalog and transaction data is stored locally on your device. The App fetches live exchange rates from CoinGecko (a third-party service). No personally identifiable information is collected or transmitted by Kasway.';

  @override
  String get eulaSection5Title => '5. Limitation of Liability';

  @override
  String get eulaSection5Body =>
      'To the maximum extent permitted by law, Kasway and its developers shall not be liable for any loss or damage arising from your use of the App, including but not limited to loss of funds, loss of data, or loss of seed phrase.';

  @override
  String get eulaSection6Title => '6. Changes to Terms';

  @override
  String get eulaSection6Body =>
      'We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms.';

  @override
  String get eulaSection7Title => '7. Governing Law';

  @override
  String get eulaSection7Body =>
      'These terms are governed by applicable law. Any disputes shall be resolved in the jurisdiction where Kasway is incorporated.';

  @override
  String get eulaAgreeLabel =>
      'I have read and agree to the Terms & Conditions and Privacy Policy.';

  @override
  String get eulaContinue => 'Continue';

  @override
  String get seedPhraseTitle => 'Seed Phrase';

  @override
  String get seedPhraseCopyTooltip => 'Copy to clipboard';

  @override
  String get seedPhraseWarning =>
      'Write these words down. You cannot recover your account without them.';

  @override
  String seedPhraseError(String error) {
    return 'Error: $error';
  }

  @override
  String get seedPhraseCopied => 'Seed phrase copied to clipboard';

  @override
  String get seedPhraseConfirm => 'I\'ve saved my seed phrase →';

  @override
  String get currencyTitle => 'Choose Currency';

  @override
  String get currencyQuestion => 'What currency do you sell in?';

  @override
  String get currencyHint => 'You can change this at any time in Settings.';

  @override
  String get currencyContinue => 'Continue';

  @override
  String get loginTitle => 'Log In';

  @override
  String get loginEnterPhrase => 'Enter your seed phrase';

  @override
  String get loginPhraseHint =>
      'Type or paste your 12 or 24 word recovery phrase, separated by spaces.';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => 'Clear';

  @override
  String loginWordCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString words',
      one: '$countString word',
    );
    return '$_temp0';
  }

  @override
  String get loginButton => 'Log In';

  @override
  String get loginErrorInvalidWord =>
      'One or more words are not valid BIP39 words.';

  @override
  String get loginErrorInvalidChecksum =>
      'Invalid seed phrase — checksum does not match.';

  @override
  String get loginErrorInvalidWordCount =>
      'Seed phrase must be 12 or 24 words.';

  @override
  String get loginErrorGeneric =>
      'Invalid seed phrase. Please check and try again.';

  @override
  String get onboardingTitle => 'Set up your catalog';

  @override
  String get onboardingSubtitle => 'How would you like to get started?';

  @override
  String get onboardingImportTitle => 'Import from old device';

  @override
  String get onboardingImportSubtitle =>
      'Restore your catalog from a CSV backup';

  @override
  String get onboardingManualTitle => 'Set up items manually';

  @override
  String get onboardingManualSubtitle =>
      'Use the sample catalog or add your own items';

  @override
  String onboardingImportFailed(String error) {
    return 'Import failed: $error';
  }
}
