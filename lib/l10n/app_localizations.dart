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

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFaqTitle;

  /// No description provided for @helpHowToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'How to place an order?'**
  String get helpHowToPlaceOrder;

  /// No description provided for @helpHowToPlaceOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can pick products from the home page and confirm the selection.'**
  String get helpHowToPlaceOrderAnswer;

  /// No description provided for @helpPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods available?'**
  String get helpPaymentMethods;

  /// No description provided for @helpPaymentMethodsAnswer.
  ///
  /// In en, this message translates to:
  /// **'We support Credit Cards, E-Wallets, and Cash.'**
  String get helpPaymentMethodsAnswer;

  /// No description provided for @helpCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel an order?'**
  String get helpCancelOrder;

  /// No description provided for @helpCancelOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'Orders can be cleared before confirmation from the order bar.'**
  String get helpCancelOrderAnswer;

  /// No description provided for @helpContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get helpContactUs;

  /// No description provided for @helpEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get helpEmailSupport;

  /// No description provided for @helpWhatsAppSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get helpWhatsAppSupport;

  /// No description provided for @helpCallCenter.
  ///
  /// In en, this message translates to:
  /// **'Call Center'**
  String get helpCallCenter;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get dataTitle;

  /// No description provided for @dataBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get dataBackupSection;

  /// No description provided for @dataBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Back Up Catalog'**
  String get dataBackupTitle;

  /// No description provided for @dataBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all your items and categories to a CSV file'**
  String get dataBackupSubtitle;

  /// No description provided for @dataRestoreSection.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get dataRestoreSection;

  /// No description provided for @dataRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get dataRestoreTitle;

  /// No description provided for @dataRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load items from a previously saved CSV file'**
  String get dataRestoreSubtitle;

  /// No description provided for @dataRestoreNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Items with the same ID in the backup will overwrite existing ones.'**
  String get dataRestoreNote;

  /// No description provided for @dataBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved successfully'**
  String get dataBackupSuccess;

  /// No description provided for @dataBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String dataBackupFailed(String error);

  /// No description provided for @dataRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String dataRestoreFailed(String error);

  /// No description provided for @dataRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} items restored successfully'**
  String dataRestoreSuccess(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDisplayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display Currency'**
  String get settingsDisplayCurrency;

  /// No description provided for @settingsDynamicPricing.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Pricing'**
  String get settingsDynamicPricing;

  /// No description provided for @settingsDynamicPricingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available for KAS display currency'**
  String get settingsDynamicPricingUnavailable;

  /// No description provided for @settingsDynamicPricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-update prices every 60 seconds'**
  String get settingsDynamicPricingSubtitle;

  /// No description provided for @settingsAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get settingsAppInfo;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeTitle;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themePrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get themePrimaryColor;

  /// No description provided for @themeResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get themeResetToDefault;

  /// No description provided for @themePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get themePreview;

  /// No description provided for @themePreviewSampleCard.
  ///
  /// In en, this message translates to:
  /// **'Sample Card'**
  String get themePreviewSampleCard;

  /// No description provided for @themePreviewSampleCardBody.
  ///
  /// In en, this message translates to:
  /// **'This is how your theme will look with the selected color.'**
  String get themePreviewSampleCardBody;

  /// No description provided for @themePreviewFilledButton.
  ///
  /// In en, this message translates to:
  /// **'Filled Button'**
  String get themePreviewFilledButton;

  /// No description provided for @themePreviewOutlinedButton.
  ///
  /// In en, this message translates to:
  /// **'Outlined Button'**
  String get themePreviewOutlinedButton;

  /// No description provided for @themePreviewTextButton.
  ///
  /// In en, this message translates to:
  /// **'Text Button'**
  String get themePreviewTextButton;

  /// No description provided for @networkTitle.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkTitle;

  /// No description provided for @networkActiveNetwork.
  ///
  /// In en, this message translates to:
  /// **'Active Network'**
  String get networkActiveNetwork;

  /// No description provided for @networkMainnet.
  ///
  /// In en, this message translates to:
  /// **'Mainnet'**
  String get networkMainnet;

  /// No description provided for @networkMainnetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Production Kaspa network'**
  String get networkMainnetSubtitle;

  /// No description provided for @networkTestnet10.
  ///
  /// In en, this message translates to:
  /// **'Testnet-10'**
  String get networkTestnet10;

  /// No description provided for @networkTestnet10Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Test network · uses TKAS'**
  String get networkTestnet10Subtitle;

  /// No description provided for @networkNodeStatus.
  ///
  /// In en, this message translates to:
  /// **'Node Status'**
  String get networkNodeStatus;

  /// No description provided for @networkConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get networkConnected;

  /// No description provided for @networkDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get networkDisconnected;

  /// No description provided for @networkVirtualDaaScore.
  ///
  /// In en, this message translates to:
  /// **'Virtual DAA Score'**
  String get networkVirtualDaaScore;

  /// No description provided for @networkCustomNodeUrls.
  ///
  /// In en, this message translates to:
  /// **'Custom Node URLs'**
  String get networkCustomNodeUrls;

  /// No description provided for @networkMainnetUrl.
  ///
  /// In en, this message translates to:
  /// **'Mainnet WebSocket URL'**
  String get networkMainnetUrl;

  /// No description provided for @networkTestnet10Url.
  ///
  /// In en, this message translates to:
  /// **'Testnet-10 WebSocket URL'**
  String get networkTestnet10Url;

  /// No description provided for @networkSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get networkSave;

  /// No description provided for @networkSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved — reconnecting…'**
  String get networkSaved;

  /// No description provided for @networkRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get networkRequired;

  /// No description provided for @networkAutoMode.
  ///
  /// In en, this message translates to:
  /// **'Auto (Resolver)'**
  String get networkAutoMode;

  /// No description provided for @networkCustomMode.
  ///
  /// In en, this message translates to:
  /// **'Custom Node'**
  String get networkCustomMode;

  /// No description provided for @networkResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving best node…'**
  String get networkResolving;

  /// No description provided for @networkResolvedNode.
  ///
  /// In en, this message translates to:
  /// **'Node: {url}'**
  String networkResolvedNode(String url);

  /// No description provided for @networkResetToAuto.
  ///
  /// In en, this message translates to:
  /// **'Reset to Auto'**
  String get networkResetToAuto;

  /// No description provided for @networkResetToAutoSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Reset to auto — reconnecting…'**
  String get networkResetToAutoSnackbar;

  /// No description provided for @donateTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donateTitle;

  /// No description provided for @donateSupportDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get donateSupportDeveloper;

  /// No description provided for @donateSupportDeveloperBody.
  ///
  /// In en, this message translates to:
  /// **'Kasway is free and open source. If you find it useful, consider sending a one-time KAS donation directly to the developer.'**
  String get donateSupportDeveloperBody;

  /// No description provided for @donateAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get donateAddressCopied;

  /// No description provided for @donateDonateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateDonateNow;

  /// No description provided for @donateKas.
  ///
  /// In en, this message translates to:
  /// **'Donate KAS'**
  String get donateKas;

  /// No description provided for @donateRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient: {address}'**
  String donateRecipient(String address);

  /// No description provided for @donateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount} KAS'**
  String donateAvailable(String amount);

  /// No description provided for @donateAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (KAS)'**
  String get donateAmountLabel;

  /// No description provided for @donateAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get donateAmountRequired;

  /// No description provided for @donateAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get donateAmountInvalid;

  /// No description provided for @donateSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get donateSend;

  /// No description provided for @donateThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you! TX: {txId}'**
  String donateThankYou(String txId);

  /// No description provided for @donateTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get donateTransactionFailed;

  /// No description provided for @donateAutoPerPayment.
  ///
  /// In en, this message translates to:
  /// **'Auto-Donate Per Payment'**
  String get donateAutoPerPayment;

  /// No description provided for @donateAutoPerPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Silently send a small KAS amount to the developer after each confirmed customer payment (mainnet only).'**
  String get donateAutoPerPaymentBody;

  /// No description provided for @donateEnableAuto.
  ///
  /// In en, this message translates to:
  /// **'Enable Auto-Donate'**
  String get donateEnableAuto;

  /// No description provided for @donatePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage of transaction'**
  String get donatePercentage;

  /// No description provided for @donateFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (KAS)'**
  String get donateFixed;

  /// No description provided for @donatePercentageLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get donatePercentageLabel;

  /// No description provided for @donateAmountKasLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (KAS)'**
  String get donateAmountKasLabel;

  /// No description provided for @donateSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get donateSaveSettings;

  /// No description provided for @donateInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid value greater than 0'**
  String get donateInvalidValue;

  /// No description provided for @donateSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Auto-donate settings saved'**
  String get donateSettingsSaved;

  /// No description provided for @donateHistory.
  ///
  /// In en, this message translates to:
  /// **'Donation History'**
  String get donateHistory;

  /// No description provided for @donateNoDonations.
  ///
  /// In en, this message translates to:
  /// **'No donations yet'**
  String get donateNoDonations;

  /// No description provided for @donateTxIdCopied.
  ///
  /// In en, this message translates to:
  /// **'TX ID copied'**
  String get donateTxIdCopied;

  /// No description provided for @donateNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet mnemonic found. Please set up your wallet first.'**
  String get donateNoWallet;

  /// No description provided for @displayTitle.
  ///
  /// In en, this message translates to:
  /// **'External Display'**
  String get displayTitle;

  /// No description provided for @displaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mirror the payment QR screen to a connected display.'**
  String get displaySubtitle;

  /// No description provided for @displayNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Available on Android and iOS only.'**
  String get displayNotSupported;

  /// No description provided for @displayAvailableDisplays.
  ///
  /// In en, this message translates to:
  /// **'Available Displays'**
  String get displayAvailableDisplays;

  /// No description provided for @displayScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get displayScan;

  /// No description provided for @displayNoDisplays.
  ///
  /// In en, this message translates to:
  /// **'No displays found. Tap Scan to search.'**
  String get displayNoDisplays;

  /// No description provided for @displayConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get displayConnect;

  /// No description provided for @displayStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get displayStatus;

  /// No description provided for @displayConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected: {name}'**
  String displayConnected(String name);

  /// No description provided for @displayNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get displayNotConnected;

  /// No description provided for @displayReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get displayReconnect;

  /// No description provided for @displayDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get displayDisconnect;

  /// No description provided for @tableLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Table Layout'**
  String get tableLayoutTitle;

  /// No description provided for @tableLayoutSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tableLayoutSave;

  /// No description provided for @tableLayoutFeatureToggle.
  ///
  /// In en, this message translates to:
  /// **'Table Layout'**
  String get tableLayoutFeatureToggle;

  /// No description provided for @tableLayoutAddTable.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get tableLayoutAddTable;

  /// No description provided for @tableLayoutRotateCcw.
  ///
  /// In en, this message translates to:
  /// **'Rotate counter-clockwise'**
  String get tableLayoutRotateCcw;

  /// No description provided for @tableLayoutRotateCw.
  ///
  /// In en, this message translates to:
  /// **'Rotate clockwise'**
  String get tableLayoutRotateCw;

  /// No description provided for @tableLayoutDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get tableLayoutDeleteGroup;

  /// No description provided for @tableLayoutDeleteTable.
  ///
  /// In en, this message translates to:
  /// **'Delete Table'**
  String get tableLayoutDeleteTable;

  /// No description provided for @tableLayoutDeleteGroupContent.
  ///
  /// In en, this message translates to:
  /// **'Remove the entire group ({count} tables)?'**
  String tableLayoutDeleteGroupContent(int count);

  /// No description provided for @tableLayoutDeleteTableContent.
  ///
  /// In en, this message translates to:
  /// **'Remove table \"{label}\"?'**
  String tableLayoutDeleteTableContent(String label);

  /// No description provided for @tableLayoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tableLayoutCancel;

  /// No description provided for @tableLayoutDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tableLayoutDelete;

  /// No description provided for @tableLayoutUnsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get tableLayoutUnsavedChanges;

  /// No description provided for @tableLayoutUnsavedChangesContent.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them and leave?'**
  String get tableLayoutUnsavedChangesContent;

  /// No description provided for @tableLayoutKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get tableLayoutKeepEditing;

  /// No description provided for @tableLayoutDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get tableLayoutDiscard;

  /// No description provided for @tableLayoutSingleTables.
  ///
  /// In en, this message translates to:
  /// **'SINGLE TABLES'**
  String get tableLayoutSingleTables;

  /// No description provided for @tableLayoutTableGroups.
  ///
  /// In en, this message translates to:
  /// **'TABLE GROUPS'**
  String get tableLayoutTableGroups;

  /// No description provided for @tableLayoutTableGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Places multiple tables at once in a preset arrangement.'**
  String get tableLayoutTableGroupsBody;

  /// No description provided for @tableLayoutAddTableSheet.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get tableLayoutAddTableSheet;

  /// No description provided for @tableLayoutSeatsSuffix.
  ///
  /// In en, this message translates to:
  /// **' · {seats} seats'**
  String tableLayoutSeatsSuffix(int seats);

  /// No description provided for @tableLayoutRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tableLayoutRename;

  /// No description provided for @tableLayoutSaveName.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tableLayoutSaveName;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistoryTitle;

  /// No description provided for @orderHistoryNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderHistoryNoOrders;

  /// No description provided for @orderHistoryTodayOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get orderHistoryTodayOrders;

  /// No description provided for @orderHistoryTodayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get orderHistoryTodayRevenue;

  /// No description provided for @orderHistoryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get orderHistoryToday;

  /// No description provided for @orderHistoryYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get orderHistoryYesterday;

  /// No description provided for @orderHistoryNoItemDetails.
  ///
  /// In en, this message translates to:
  /// **'No item details recorded'**
  String get orderHistoryNoItemDetails;

  /// No description provided for @orderHistoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderHistoryTotal;

  /// No description provided for @orderHistoryViewOnExplorer.
  ///
  /// In en, this message translates to:
  /// **'View on Explorer'**
  String get orderHistoryViewOnExplorer;

  /// No description provided for @orderHistoryTable.
  ///
  /// In en, this message translates to:
  /// **'Table {label}'**
  String orderHistoryTable(String label);

  /// No description provided for @withdrawalHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawalHistoryTitle;

  /// No description provided for @withdrawalHistoryNoWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals yet'**
  String get withdrawalHistoryNoWithdrawals;

  /// No description provided for @withdrawalHistoryCopyTxId.
  ///
  /// In en, this message translates to:
  /// **'Copy TX ID'**
  String get withdrawalHistoryCopyTxId;

  /// No description provided for @withdrawalHistoryViewOnExplorer.
  ///
  /// In en, this message translates to:
  /// **'View on Explorer'**
  String get withdrawalHistoryViewOnExplorer;

  /// No description provided for @withdrawalHistoryTxIdCopied.
  ///
  /// In en, this message translates to:
  /// **'TX ID copied'**
  String get withdrawalHistoryTxIdCopied;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSelectSection.
  ///
  /// In en, this message translates to:
  /// **'Select a section'**
  String get profileSelectSection;

  /// No description provided for @profileOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get profileOrderHistory;

  /// No description provided for @profileManageItem.
  ///
  /// In en, this message translates to:
  /// **'Manage Item'**
  String get profileManageItem;

  /// No description provided for @profileTableLayout.
  ///
  /// In en, this message translates to:
  /// **'Table Layout'**
  String get profileTableLayout;

  /// No description provided for @profileBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get profileBackupRestore;

  /// No description provided for @profileNetworkNode.
  ///
  /// In en, this message translates to:
  /// **'Network & Node'**
  String get profileNetworkNode;

  /// No description provided for @profileDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get profileDisplay;

  /// No description provided for @profileThemeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get profileThemeSettings;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get profileDonate;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutContent;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileKaspaAddress.
  ///
  /// In en, this message translates to:
  /// **'Kaspa Address'**
  String get profileKaspaAddress;

  /// No description provided for @profileNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet configured'**
  String get profileNoWallet;

  /// No description provided for @profileCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get profileCopyAddress;

  /// No description provided for @profileViewInExplorer.
  ///
  /// In en, this message translates to:
  /// **'View in explorer'**
  String get profileViewInExplorer;

  /// No description provided for @profileBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get profileBalance;

  /// No description provided for @profileWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get profileWithdraw;

  /// No description provided for @profileAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get profileAddressCopied;

  /// No description provided for @profileWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {kasSymbol}'**
  String profileWithdrawTitle(String kasSymbol);

  /// No description provided for @profileDestinationAddress.
  ///
  /// In en, this message translates to:
  /// **'Destination Kaspa Address'**
  String get profileDestinationAddress;

  /// No description provided for @profileAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get profileAddressRequired;

  /// No description provided for @profileAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid {hrp}: address'**
  String profileAddressInvalid(String hrp);

  /// No description provided for @profileAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount ({kasSymbol})'**
  String profileAmountLabel(String kasSymbol);

  /// No description provided for @profileAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get profileAmountRequired;

  /// No description provided for @profileAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get profileAmountInvalid;

  /// No description provided for @profileSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get profileSend;

  /// No description provided for @profileTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get profileTransactionFailed;

  /// No description provided for @profileWithdrawNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet mnemonic found. Please set up your wallet first.'**
  String get profileWithdrawNoWallet;

  /// No description provided for @profileWithdrawalSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Successful!'**
  String get profileWithdrawalSuccessTitle;

  /// No description provided for @profileWithdrawalSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your KAS has been sent successfully.'**
  String get profileWithdrawalSuccessSubtitle;

  /// No description provided for @profileMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get profileMax;

  /// No description provided for @homeFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get homeFailedToLoad;

  /// No description provided for @homeNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get homeNoProducts;

  /// No description provided for @homeConfirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm Selection'**
  String get homeConfirmSelection;

  /// No description provided for @homeClearOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Order?'**
  String get homeClearOrderTitle;

  /// No description provided for @homeClearOrderContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from the order list?'**
  String get homeClearOrderContent;

  /// No description provided for @homeClearOrder.
  ///
  /// In en, this message translates to:
  /// **'Clear Order'**
  String get homeClearOrder;

  /// No description provided for @homeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancel;

  /// No description provided for @homeTestnetBanner.
  ///
  /// In en, this message translates to:
  /// **'Using the app in Testnet mode'**
  String get homeTestnetBanner;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet configured. Please set up your wallet first.'**
  String get paymentNoWallet;

  /// No description provided for @paymentFetchingRates.
  ///
  /// In en, this message translates to:
  /// **'Fetching exchange rates…'**
  String get paymentFetchingRates;

  /// No description provided for @paymentPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment.'**
  String get paymentPleaseWait;

  /// No description provided for @paymentRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paymentRetry;

  /// No description provided for @paymentReceivedOf.
  ///
  /// In en, this message translates to:
  /// **'{received} of {total} {kasSymbol} received'**
  String paymentReceivedOf(String received, String total, String kasSymbol);

  /// No description provided for @paymentWarning.
  ///
  /// In en, this message translates to:
  /// **'Send {kasSymbol} only, and exactly the amount shown above. Sending any other asset or incorrect amount might result in funds being lost.'**
  String paymentWarning(String kasSymbol);

  /// No description provided for @paymentAutoDonationNotice.
  ///
  /// In en, this message translates to:
  /// **'Auto-donation active — {amount} {kasSymbol} will be sent to the developer after payment confirmation.'**
  String paymentAutoDonationNotice(String amount, String kasSymbol);

  /// No description provided for @paymentOrderList.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get paymentOrderList;

  /// No description provided for @tableSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Table'**
  String get tableSelectTitle;

  /// No description provided for @tableSelectMarkAsServed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Served'**
  String get tableSelectMarkAsServed;

  /// No description provided for @tableSelectFreeTable.
  ///
  /// In en, this message translates to:
  /// **'Free Table'**
  String get tableSelectFreeTable;

  /// No description provided for @tableSelectFreeTableContent.
  ///
  /// In en, this message translates to:
  /// **'Mark Table {label} as available? This will remove the occupied status.'**
  String tableSelectFreeTableContent(String label);

  /// No description provided for @tableSelectFreeTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Table'**
  String get tableSelectFreeTableTitle;

  /// No description provided for @tableSelectTableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table {label}'**
  String tableSelectTableLabel(String label);

  /// No description provided for @tableSelectNoTables.
  ///
  /// In en, this message translates to:
  /// **'No tables configured'**
  String get tableSelectNoTables;

  /// No description provided for @tableSelectNoTablesBody.
  ///
  /// In en, this message translates to:
  /// **'Set up your floor plan in Profile > Table Layout.'**
  String get tableSelectNoTablesBody;

  /// No description provided for @tableSelectGoToLayout.
  ///
  /// In en, this message translates to:
  /// **'Go to Table Layout'**
  String get tableSelectGoToLayout;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The transaction has been processed successfully.'**
  String get paymentSuccessSubtitle;

  /// No description provided for @paymentSuccessRedirect.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected in {count} second{plural}...'**
  String paymentSuccessRedirect(int count, String plural);

  /// No description provided for @itemManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Items'**
  String get itemManageTitle;

  /// No description provided for @itemNoCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get itemNoCategoriesYet;

  /// No description provided for @itemCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get itemCreateCategory;

  /// No description provided for @itemNoItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get itemNoItemsInCategory;

  /// No description provided for @itemDeleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product?'**
  String get itemDeleteProductTitle;

  /// No description provided for @itemDeleteProductInCart.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is in the active order. Deleting will remove it from the cart too.'**
  String itemDeleteProductInCart(String name);

  /// No description provided for @itemDeleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String itemDeleteProductConfirm(String name);

  /// No description provided for @itemDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get itemDeleteCancel;

  /// No description provided for @itemDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get itemDeleteConfirm;

  /// No description provided for @itemDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get itemDone;

  /// No description provided for @itemAdditionCount.
  ///
  /// In en, this message translates to:
  /// **' · {count} addition{plural}'**
  String itemAdditionCount(int count, String plural);

  /// No description provided for @itemFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get itemFormEditTitle;

  /// No description provided for @itemFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get itemFormAddTitle;

  /// No description provided for @itemFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get itemFormSave;

  /// No description provided for @itemFormProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get itemFormProductName;

  /// No description provided for @itemFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get itemFormRequired;

  /// No description provided for @itemFormInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get itemFormInvalidNumber;

  /// No description provided for @itemFormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get itemFormCategory;

  /// No description provided for @itemFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get itemFormDescription;

  /// No description provided for @itemFormAdditions.
  ///
  /// In en, this message translates to:
  /// **'Additions'**
  String get itemFormAdditions;

  /// No description provided for @itemFormAddAddition.
  ///
  /// In en, this message translates to:
  /// **'Add Addition'**
  String get itemFormAddAddition;

  /// No description provided for @itemFormAdditionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get itemFormAdditionFree;

  /// No description provided for @itemFormEditAdditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Addition'**
  String get itemFormEditAdditionTitle;

  /// No description provided for @itemFormNewAdditionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Addition'**
  String get itemFormNewAdditionTitle;

  /// No description provided for @itemFormAdditionName.
  ///
  /// In en, this message translates to:
  /// **'Addition Name'**
  String get itemFormAdditionName;

  /// No description provided for @itemFormAdditionPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra Price ({code}, 0 = free)'**
  String itemFormAdditionPriceLabel(String code);

  /// No description provided for @itemFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get itemFormCancel;

  /// No description provided for @categoryManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoryManageTitle;

  /// No description provided for @categoryAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryAddCategory;

  /// No description provided for @categoryNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get categoryNewCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get categoryAdd;

  /// No description provided for @categoryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoryCancel;

  /// No description provided for @categoryRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get categoryRenameTitle;

  /// No description provided for @categoryRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get categoryRename;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteWithItems.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has {count} item{plural} that will also be permanently deleted. This cannot be undone.'**
  String categoryDeleteWithItems(String name, int count, String plural);

  /// No description provided for @categoryDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String categoryDeleteEmpty(String name);

  /// No description provided for @categoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryDelete;

  /// No description provided for @categoryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item{plural}'**
  String categoryItemCount(int count, String plural);

  /// No description provided for @itemManageCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get itemManageCreate;
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
