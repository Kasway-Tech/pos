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
  String get authCreateAccount => 'Get Started';

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
  String get currencyHint =>
      'Your product prices are stored in this currency. KAS amounts are calculated from it at checkout.';

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

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpFaqTitle => 'Frequently Asked Questions';

  @override
  String get helpHowToPlaceOrder => 'How to place an order?';

  @override
  String get helpHowToPlaceOrderAnswer =>
      'You can pick products from the home page and confirm the selection.';

  @override
  String get helpPaymentMethods => 'Payment methods available?';

  @override
  String get helpPaymentMethodsAnswer =>
      'We support Credit Cards, E-Wallets, and Cash.';

  @override
  String get helpCancelOrder => 'Can I cancel an order?';

  @override
  String get helpCancelOrderAnswer =>
      'Orders can be cleared before confirmation from the order bar.';

  @override
  String get helpContactUs => 'Contact Us';

  @override
  String get helpEmailSupport => 'Email Support';

  @override
  String get helpWhatsAppSupport => 'WhatsApp Support';

  @override
  String get helpCallCenter => 'Call Center';

  @override
  String get dataTitle => 'Backup & Restore';

  @override
  String get dataBackupSection => 'Backup';

  @override
  String get dataBackupTitle => 'Back Up Catalog';

  @override
  String get dataBackupSubtitle =>
      'Save all your items and categories to a CSV file';

  @override
  String get dataRestoreSection => 'Restore';

  @override
  String get dataRestoreTitle => 'Restore from Backup';

  @override
  String get dataRestoreSubtitle =>
      'Load items from a previously saved CSV file';

  @override
  String get dataRestoreNote =>
      'Note: Items with the same ID in the backup will overwrite existing ones.';

  @override
  String get dataBackupSuccess => 'Backup saved successfully';

  @override
  String dataBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String dataRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '$count items restored successfully';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDisplayCurrency => 'Display Currency';

  @override
  String get settingsDynamicPricing => 'Dynamic Pricing';

  @override
  String get settingsDynamicPricingUnavailable =>
      'Not available for KAS display currency';

  @override
  String get settingsDynamicPricingSubtitle =>
      'Auto-update prices every 60 seconds';

  @override
  String get settingsAppInfo => 'App Info';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get themeTitle => 'Theme Settings';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themePrimaryColor => 'Primary Color';

  @override
  String get themeResetToDefault => 'Reset to default';

  @override
  String get themePreview => 'Preview';

  @override
  String get themePreviewSampleCard => 'Sample Card';

  @override
  String get themePreviewSampleCardBody =>
      'This is how your theme will look with the selected color.';

  @override
  String get themePreviewFilledButton => 'Filled Button';

  @override
  String get themePreviewOutlinedButton => 'Outlined Button';

  @override
  String get themePreviewTextButton => 'Text Button';

  @override
  String get networkTitle => 'Network';

  @override
  String get networkActiveNetwork => 'Active Network';

  @override
  String get networkMainnet => 'Mainnet';

  @override
  String get networkMainnetSubtitle => 'Production Kaspa network';

  @override
  String get networkTestnet10 => 'Testnet-10';

  @override
  String get networkTestnet10Subtitle => 'Test network · uses TKAS';

  @override
  String get networkNodeStatus => 'Node Status';

  @override
  String get networkConnected => 'Connected';

  @override
  String get networkDisconnected => 'Disconnected';

  @override
  String get networkVirtualDaaScore => 'Virtual DAA Score';

  @override
  String get networkCustomNodeUrls => 'Custom Node URLs';

  @override
  String get networkMainnetUrl => 'Mainnet WebSocket URL';

  @override
  String get networkTestnet10Url => 'Testnet-10 WebSocket URL';

  @override
  String get networkSave => 'Save';

  @override
  String get networkSaved => 'Saved — reconnecting…';

  @override
  String get networkRequired => 'Required';

  @override
  String get networkAutoMode => 'Auto (Resolver)';

  @override
  String get networkCustomMode => 'Custom Node';

  @override
  String get networkResolving => 'Resolving best node…';

  @override
  String networkResolvedNode(String url) {
    return 'Node: $url';
  }

  @override
  String get networkResetToAuto => 'Reset to Auto';

  @override
  String get networkResetToAutoSnackbar => 'Reset to auto — reconnecting…';

  @override
  String get donateTitle => 'Donate';

  @override
  String get donateSupportDeveloper => 'Support the Developer';

  @override
  String get donateSupportDeveloperBody =>
      'Kasway is free and open source. If you find it useful, consider sending a one-time KAS donation directly to the developer.';

  @override
  String get donateAddressCopied => 'Address copied';

  @override
  String get donateDonateNow => 'Donate Now';

  @override
  String get donateKas => 'Donate KAS';

  @override
  String donateRecipient(String address) {
    return 'Recipient: $address';
  }

  @override
  String donateAvailable(String amount) {
    return 'Available: $amount KAS';
  }

  @override
  String get donateAmountLabel => 'Amount (KAS)';

  @override
  String get donateAmountRequired => 'Amount is required';

  @override
  String get donateAmountInvalid => 'Enter a valid amount';

  @override
  String get donateSend => 'Send';

  @override
  String donateThankYou(String txId) {
    return 'Thank you! TX: $txId';
  }

  @override
  String get donateTransactionFailed => 'Transaction Failed';

  @override
  String get donateAutoPerPayment => 'Auto-Donate Per Payment';

  @override
  String get donateAutoPerPaymentBody =>
      'Silently send a small KAS amount to the developer after each confirmed customer payment (mainnet only).';

  @override
  String get donateEnableAuto => 'Enable Auto-Donate';

  @override
  String get donatePercentage => 'Percentage of transaction';

  @override
  String get donateFixed => 'Fixed amount (KAS)';

  @override
  String get donatePercentageLabel => 'Percentage (%)';

  @override
  String get donateAmountKasLabel => 'Amount (KAS)';

  @override
  String get donateSaveSettings => 'Save';

  @override
  String get donateInvalidValue => 'Enter a valid value greater than 0';

  @override
  String get donateSettingsSaved => 'Auto-donate settings saved';

  @override
  String get donateHistory => 'Donation History';

  @override
  String get donateNoDonations => 'No donations yet';

  @override
  String get donateTxIdCopied => 'TX ID copied';

  @override
  String get donateNoWallet =>
      'No wallet mnemonic found. Please set up your wallet first.';

  @override
  String get displayTitle => 'External Display';

  @override
  String get displaySubtitle =>
      'Mirror the payment QR screen to a connected display.';

  @override
  String get displayNotSupported => 'Available on Android and iOS only.';

  @override
  String get displayAvailableDisplays => 'Available Displays';

  @override
  String get displayScan => 'Scan';

  @override
  String get displayNoDisplays => 'No displays found. Tap Scan to search.';

  @override
  String get displayConnect => 'Connect';

  @override
  String get displayStatus => 'Status';

  @override
  String displayConnected(String name) {
    return 'Connected: $name';
  }

  @override
  String get displayNotConnected => 'Not connected';

  @override
  String get displayReconnect => 'Reconnect';

  @override
  String get displayDisconnect => 'Disconnect';

  @override
  String get tableLayoutTitle => 'Table Layout';

  @override
  String get tableLayoutSave => 'Save';

  @override
  String get tableLayoutFeatureToggle => 'Table Layout';

  @override
  String get tableLayoutAddTable => 'Add Table';

  @override
  String get tableLayoutRotateCcw => 'Rotate counter-clockwise';

  @override
  String get tableLayoutRotateCw => 'Rotate clockwise';

  @override
  String get tableLayoutDeleteGroup => 'Delete Group';

  @override
  String get tableLayoutDeleteTable => 'Delete Table';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return 'Remove the entire group ($count tables)?';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return 'Remove table \"$label\"?';
  }

  @override
  String get tableLayoutCancel => 'Cancel';

  @override
  String get tableLayoutDelete => 'Delete';

  @override
  String get tableLayoutUnsavedChanges => 'Unsaved Changes';

  @override
  String get tableLayoutUnsavedChangesContent =>
      'You have unsaved changes. Discard them and leave?';

  @override
  String get tableLayoutKeepEditing => 'Keep editing';

  @override
  String get tableLayoutDiscard => 'Discard';

  @override
  String get tableLayoutSingleTables => 'SINGLE TABLES';

  @override
  String get tableLayoutTableGroups => 'TABLE GROUPS';

  @override
  String get tableLayoutTableGroupsBody =>
      'Places multiple tables at once in a preset arrangement.';

  @override
  String get tableLayoutAddTableSheet => 'Add Table';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return ' · $seats seats';
  }

  @override
  String get tableLayoutRename => 'Rename';

  @override
  String get tableLayoutSaveName => 'Save';

  @override
  String get orderHistoryTitle => 'Order History';

  @override
  String get orderHistoryNoOrders => 'No orders yet';

  @override
  String get orderHistoryTodayOrders => 'Today\'s Orders';

  @override
  String get orderHistoryTodayRevenue => 'Today\'s Revenue';

  @override
  String get orderHistoryToday => 'Today';

  @override
  String get orderHistoryYesterday => 'Yesterday';

  @override
  String get orderHistoryNoItemDetails => 'No item details recorded';

  @override
  String get orderHistoryTotal => 'Total';

  @override
  String get orderHistoryViewOnExplorer => 'View on Explorer';

  @override
  String orderHistoryTable(String label) {
    return 'Table $label';
  }

  @override
  String get withdrawalHistoryTitle => 'Withdraw History';

  @override
  String get withdrawalHistoryNoWithdrawals => 'No withdrawals yet';

  @override
  String get withdrawalHistoryCopyTxId => 'Copy TX ID';

  @override
  String get withdrawalHistoryViewOnExplorer => 'View on Explorer';

  @override
  String get withdrawalHistoryTxIdCopied => 'TX ID copied';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSelectSection => 'Select a section';

  @override
  String get profileOrderHistory => 'Order History';

  @override
  String get profileManageItem => 'Manage Item';

  @override
  String get profileTableLayout => 'Table Layout';

  @override
  String get profileBackupRestore => 'Backup & Restore';

  @override
  String get profileNetworkNode => 'Network & Node';

  @override
  String get profileDisplay => 'Display';

  @override
  String get profileThemeSettings => 'Theme Settings';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileDonate => 'Donate';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutContent => 'Are you sure you want to log out?';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileKaspaAddress => 'Kaspa Address';

  @override
  String get profileNoWallet => 'No wallet configured';

  @override
  String get profileCopyAddress => 'Copy address';

  @override
  String get profileViewInExplorer => 'View in explorer';

  @override
  String get profileBalance => 'Balance';

  @override
  String get profileWithdraw => 'Withdraw';

  @override
  String get profileAddressCopied => 'Address copied';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return 'Withdraw $kasSymbol';
  }

  @override
  String get profileDestinationAddress => 'Destination Kaspa Address';

  @override
  String get profileAddressRequired => 'Address is required';

  @override
  String profileAddressInvalid(String hrp) {
    return 'Must be a valid $hrp: address';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return 'Amount ($kasSymbol)';
  }

  @override
  String get profileAmountRequired => 'Amount is required';

  @override
  String get profileAmountInvalid => 'Enter a valid amount';

  @override
  String get profileSend => 'Send';

  @override
  String get profileTransactionFailed => 'Transaction Failed';

  @override
  String get profileWithdrawNoWallet =>
      'No wallet mnemonic found. Please set up your wallet first.';

  @override
  String get profileWithdrawalSuccessTitle => 'Withdrawal Successful!';

  @override
  String get profileWithdrawalSuccessSubtitle =>
      'Your KAS has been sent successfully.';

  @override
  String get profileMax => 'Max';

  @override
  String get homeFailedToLoad => 'Failed to load products';

  @override
  String get homeNoProducts => 'No products found';

  @override
  String get homeConfirmSelection => 'Confirm Selection';

  @override
  String get homeClearOrderTitle => 'Clear Order?';

  @override
  String get homeClearOrderContent =>
      'Are you sure you want to remove all items from the order list?';

  @override
  String get homeClearOrder => 'Clear Order';

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeTestnetBanner => 'Using the app in Testnet mode';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentNoWallet =>
      'No wallet configured. Please set up your wallet first.';

  @override
  String get paymentFetchingRates => 'Fetching exchange rates…';

  @override
  String get paymentPleaseWait => 'Please wait a moment.';

  @override
  String get paymentRetry => 'Retry';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '$received of $total $kasSymbol received';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return 'Send $kasSymbol only, and exactly the amount shown above. Sending any other asset or incorrect amount might result in funds being lost.';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return 'Auto-donation active — $amount $kasSymbol will be sent to the developer after payment confirmation.';
  }

  @override
  String get paymentOrderList => 'Order List';

  @override
  String get tableSelectTitle => 'Select Table';

  @override
  String get tableSelectMarkAsServed => 'Mark as Served';

  @override
  String get tableSelectFreeTable => 'Free Table';

  @override
  String tableSelectFreeTableContent(String label) {
    return 'Mark Table $label as available? This will remove the occupied status.';
  }

  @override
  String get tableSelectFreeTableTitle => 'Free Table';

  @override
  String tableSelectTableLabel(String label) {
    return 'Table $label';
  }

  @override
  String get tableSelectNoTables => 'No tables configured';

  @override
  String get tableSelectNoTablesBody =>
      'Set up your floor plan in Profile > Table Layout.';

  @override
  String get tableSelectGoToLayout => 'Go to Table Layout';

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String get paymentSuccessSubtitle =>
      'The transaction has been processed successfully.';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return 'You will be redirected in $count second$plural...';
  }

  @override
  String get itemManageTitle => 'Manage Items';

  @override
  String get itemNoCategoriesYet => 'No categories yet';

  @override
  String get itemCreateCategory => 'Create Category';

  @override
  String get itemNoItemsInCategory => 'No items in this category';

  @override
  String get itemDeleteProductTitle => 'Delete Product?';

  @override
  String itemDeleteProductInCart(String name) {
    return '\"$name\" is in the active order. Deleting will remove it from the cart too.';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get itemDeleteCancel => 'Cancel';

  @override
  String get itemDeleteConfirm => 'Delete';

  @override
  String get itemDone => 'Done';

  @override
  String itemAdditionCount(int count, String plural) {
    return ' · $count addition$plural';
  }

  @override
  String get itemFormEditTitle => 'Edit Product';

  @override
  String get itemFormAddTitle => 'Add Product';

  @override
  String get itemFormSave => 'Save';

  @override
  String get itemFormProductName => 'Product Name';

  @override
  String get itemFormRequired => 'Required';

  @override
  String get itemFormInvalidNumber => 'Enter a valid number';

  @override
  String get itemFormCategory => 'Category';

  @override
  String get itemFormDescription => 'Description (optional)';

  @override
  String get itemFormAdditions => 'Additions';

  @override
  String get itemFormAddAddition => 'Add Addition';

  @override
  String get itemFormAdditionFree => 'Free';

  @override
  String get itemFormEditAdditionTitle => 'Edit Addition';

  @override
  String get itemFormNewAdditionTitle => 'New Addition';

  @override
  String get itemFormAdditionName => 'Addition Name';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return 'Extra Price ($code, 0 = free)';
  }

  @override
  String get itemFormCancel => 'Cancel';

  @override
  String get categoryManageTitle => 'Categories';

  @override
  String get categoryAddCategory => 'Add Category';

  @override
  String get categoryNewCategory => 'New Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get categoryAdd => 'Add';

  @override
  String get categoryCancel => 'Cancel';

  @override
  String get categoryRenameTitle => 'Rename Category';

  @override
  String get categoryRename => 'Rename';

  @override
  String get categoryDeleteTitle => 'Delete Category?';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '\"$name\" has $count item$plural that will also be permanently deleted. This cannot be undone.';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get categoryDelete => 'Delete';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count item$plural';
  }

  @override
  String get itemManageCreate => 'Create';
}
