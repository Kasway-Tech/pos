/// Central registry of all SharedPreferences keys used across the app.
///
/// Keeping keys in one place prevents typo-driven bugs and makes it easy to
/// audit which keys are persisted.
abstract final class PreferenceKeys {
  // ── Theme ──────────────────────────────────────────────────────────────────
  static const String themeSeedColor = 'theme_seed_color';
  static const String themeMode = 'theme_mode';

  // ── Currency ───────────────────────────────────────────────────────────────
  static const String currencyCode = 'default_currency_code';
  static const String dynamicPricing = 'dynamic_pricing';

  // ── Donation ───────────────────────────────────────────────────────────────
  static const String donationAutoEnabled = 'donation_auto_enabled';
  static const String donationMode = 'donation_mode';
  static const String donationPercentage = 'donation_percentage';
  static const String donationFixedKas = 'donation_fixed_kas';

  // ── Network ────────────────────────────────────────────────────────────────
  static const String kaspaNetwork = 'kaspa_network';
  static const String kaspaMainnetUrl = 'kaspa_mainnet_url';
  static const String kaspaTestnet10Url = 'kaspa_testnet10_url';

  // ── Wallet ─────────────────────────────────────────────────────────────────
  static const String walletMnemonic = 'wallet_mnemonic';

  // ── Locale ─────────────────────────────────────────────────────────────────
  static const String appLanguageCode = 'app_language_code';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onboardingComplete = 'onboarding_complete';

  // ── Display ────────────────────────────────────────────────────────────────
  static const String displayEnabled = 'display_enabled';
  static const String displayLastConnectedId = 'display_last_connected_id';

  // ── Table Layout ───────────────────────────────────────────────────────────
  static const String tableLayoutEnabled = 'table_layout_enabled';
}
