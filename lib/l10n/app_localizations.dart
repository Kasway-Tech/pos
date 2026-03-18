import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Your crypto POS,\nsecured by you.'**
  String get authTagline;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authLoginWithSeedPhrase.
  ///
  /// In en, this message translates to:
  /// **'Log in with seed phrase'**
  String get authLoginWithSeedPhrase;

  /// No description provided for @eulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get eulaTitle;

  /// No description provided for @eulaLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 2026'**
  String get eulaLastUpdated;

  /// No description provided for @eulaMainTitle.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get eulaMainTitle;

  /// No description provided for @eulaSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get eulaSection1Title;

  /// No description provided for @eulaSection1Body.
  ///
  /// In en, this message translates to:
  /// **'By using Kasway (\"the App\"), you agree to be bound by these Terms and Conditions. If you do not agree, do not use the App.'**
  String get eulaSection1Body;

  /// No description provided for @eulaSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Seed Phrase & Security'**
  String get eulaSection2Title;

  /// No description provided for @eulaSection2Body.
  ///
  /// In en, this message translates to:
  /// **'The App generates a BIP39 seed phrase that is stored locally on your device. You are solely responsible for keeping your seed phrase safe. Kasway does not store, transmit, or have access to your seed phrase. Loss of your seed phrase means permanent loss of access to your account — there is no recovery option.'**
  String get eulaSection2Body;

  /// No description provided for @eulaSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. No Financial Advice'**
  String get eulaSection3Title;

  /// No description provided for @eulaSection3Body.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the App constitutes financial, investment, or legal advice. Cryptocurrency values are volatile. You bear all risks associated with cryptocurrency transactions.'**
  String get eulaSection3Body;

  /// No description provided for @eulaSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data & Privacy'**
  String get eulaSection4Title;

  /// No description provided for @eulaSection4Body.
  ///
  /// In en, this message translates to:
  /// **'All catalog and transaction data is stored locally on your device. The App fetches live exchange rates from CoinGecko (a third-party service). No personally identifiable information is collected or transmitted by Kasway.'**
  String get eulaSection4Body;

  /// No description provided for @eulaSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get eulaSection5Title;

  /// No description provided for @eulaSection5Body.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law, Kasway and its developers shall not be liable for any loss or damage arising from your use of the App, including but not limited to loss of funds, loss of data, or loss of seed phrase.'**
  String get eulaSection5Body;

  /// No description provided for @eulaSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Changes to Terms'**
  String get eulaSection6Title;

  /// No description provided for @eulaSection6Body.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms.'**
  String get eulaSection6Body;

  /// No description provided for @eulaSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Governing Law'**
  String get eulaSection7Title;

  /// No description provided for @eulaSection7Body.
  ///
  /// In en, this message translates to:
  /// **'These terms are governed by applicable law. Any disputes shall be resolved in the jurisdiction where Kasway is incorporated.'**
  String get eulaSection7Body;

  /// No description provided for @eulaAgreeLabel.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms & Conditions and Privacy Policy.'**
  String get eulaAgreeLabel;

  /// No description provided for @eulaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get eulaContinue;

  /// No description provided for @seedPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed Phrase'**
  String get seedPhraseTitle;

  /// No description provided for @seedPhraseCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get seedPhraseCopyTooltip;

  /// No description provided for @seedPhraseWarning.
  ///
  /// In en, this message translates to:
  /// **'Write these words down. You cannot recover your account without them.'**
  String get seedPhraseWarning;

  /// No description provided for @seedPhraseError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String seedPhraseError(String error);

  /// No description provided for @seedPhraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Seed phrase copied to clipboard'**
  String get seedPhraseCopied;

  /// No description provided for @seedPhraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved my seed phrase →'**
  String get seedPhraseConfirm;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Currency'**
  String get currencyTitle;

  /// No description provided for @currencyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What currency do you sell in?'**
  String get currencyQuestion;

  /// No description provided for @currencyHint.
  ///
  /// In en, this message translates to:
  /// **'You can change this at any time in Settings.'**
  String get currencyHint;

  /// No description provided for @currencyContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get currencyContinue;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginTitle;

  /// No description provided for @loginEnterPhrase.
  ///
  /// In en, this message translates to:
  /// **'Enter your seed phrase'**
  String get loginEnterPhrase;

  /// No description provided for @loginPhraseHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste your 12 or 24 word recovery phrase, separated by spaces.'**
  String get loginPhraseHint;

  /// No description provided for @loginHintText.
  ///
  /// In en, this message translates to:
  /// **'word1 word2 word3 …'**
  String get loginHintText;

  /// No description provided for @loginClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get loginClear;

  /// No description provided for @loginWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} word} other{{count} words}}'**
  String loginWordCount(num count);

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginErrorInvalidWord.
  ///
  /// In en, this message translates to:
  /// **'One or more words are not valid BIP39 words.'**
  String get loginErrorInvalidWord;

  /// No description provided for @loginErrorInvalidChecksum.
  ///
  /// In en, this message translates to:
  /// **'Invalid seed phrase — checksum does not match.'**
  String get loginErrorInvalidChecksum;

  /// No description provided for @loginErrorInvalidWordCount.
  ///
  /// In en, this message translates to:
  /// **'Seed phrase must be 12 or 24 words.'**
  String get loginErrorInvalidWordCount;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Invalid seed phrase. Please check and try again.'**
  String get loginErrorGeneric;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your catalog'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to get started?'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from old device'**
  String get onboardingImportTitle;

  /// No description provided for @onboardingImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your catalog from a CSV backup'**
  String get onboardingImportSubtitle;

  /// No description provided for @onboardingManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up items manually'**
  String get onboardingManualTitle;

  /// No description provided for @onboardingManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the sample catalog or add your own items'**
  String get onboardingManualSubtitle;

  /// No description provided for @onboardingImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String onboardingImportFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'id',
    'ja',
    'ko',
    'ms',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
