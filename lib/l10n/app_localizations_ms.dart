// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get language => 'Bahasa';

  @override
  String get authTagline => 'POS kripto anda,\ndilindungi oleh anda.';

  @override
  String get authCreateAccount => 'Buat Akaun';

  @override
  String get authLoginWithSeedPhrase => 'Log masuk dengan seed phrase';

  @override
  String get eulaTitle => 'Terma & Syarat';

  @override
  String get eulaLastUpdated => 'Dikemas kini terakhir: Mac 2026';

  @override
  String get eulaMainTitle => 'Perjanjian Lesen Pengguna Akhir';

  @override
  String get eulaSection1Title => '1. Penerimaan Terma';

  @override
  String get eulaSection1Body =>
      'Dengan menggunakan Kasway (\"Aplikasi\"), anda bersetuju untuk terikat dengan Terma dan Syarat ini. Jika anda tidak bersetuju, jangan gunakan Aplikasi.';

  @override
  String get eulaSection2Title => '2. Seed Phrase & Keselamatan';

  @override
  String get eulaSection2Body =>
      'Aplikasi menjana seed phrase BIP39 yang disimpan secara setempat pada peranti anda. Anda bertanggungjawab sepenuhnya untuk menjaga keselamatan seed phrase anda. Kasway tidak menyimpan, menghantar, atau mempunyai akses kepada seed phrase anda. Kehilangan seed phrase bermakna kehilangan akses ke akaun anda secara kekal — tiada pilihan pemulihan.';

  @override
  String get eulaSection3Title => '3. Bukan Nasihat Kewangan';

  @override
  String get eulaSection3Body =>
      'Tiada kandungan dalam Aplikasi yang merupakan nasihat kewangan, pelaburan, atau undang-undang. Nilai mata wang kripto adalah tidak menentu. Anda menanggung semua risiko yang berkaitan dengan transaksi mata wang kripto.';

  @override
  String get eulaSection4Title => '4. Data & Privasi';

  @override
  String get eulaSection4Body =>
      'Semua data katalog dan transaksi disimpan secara setempat pada peranti anda. Aplikasi mengambil kadar pertukaran langsung dari CoinGecko (perkhidmatan pihak ketiga). Tiada maklumat peribadi yang boleh dikenal pasti dikumpul atau dihantar oleh Kasway.';

  @override
  String get eulaSection5Title => '5. Batasan Liabiliti';

  @override
  String get eulaSection5Body =>
      'Setakat yang dibenarkan oleh undang-undang, Kasway dan pembangunnya tidak bertanggungjawab atas sebarang kerugian atau kerosakan yang timbul daripada penggunaan Aplikasi, termasuk tetapi tidak terhad kepada kehilangan dana, kehilangan data, atau kehilangan seed phrase.';

  @override
  String get eulaSection6Title => '6. Perubahan Terma';

  @override
  String get eulaSection6Body =>
      'Kami berhak untuk mengubah terma ini pada bila-bila masa. Penggunaan Aplikasi yang berterusan selepas perubahan merupakan penerimaan terhadap terma baharu.';

  @override
  String get eulaSection7Title => '7. Undang-undang yang Mengawal';

  @override
  String get eulaSection7Body =>
      'Terma ini dikawal oleh undang-undang yang terpakai. Sebarang pertikaian akan diselesaikan di bidang kuasa tempat Kasway diperbadankan.';

  @override
  String get eulaAgreeLabel =>
      'Saya telah membaca dan bersetuju dengan Terma & Syarat dan Dasar Privasi.';

  @override
  String get eulaContinue => 'Teruskan';

  @override
  String get seedPhraseTitle => 'Seed Phrase';

  @override
  String get seedPhraseCopyTooltip => 'Salin ke papan klip';

  @override
  String get seedPhraseWarning =>
      'Tuliskan perkataan ini. Anda tidak dapat memulihkan akaun anda tanpanya.';

  @override
  String seedPhraseError(String error) {
    return 'Ralat: $error';
  }

  @override
  String get seedPhraseCopied => 'Seed phrase disalin ke papan klip';

  @override
  String get seedPhraseConfirm => 'Saya telah menyimpan seed phrase →';

  @override
  String get currencyTitle => 'Pilih Mata Wang';

  @override
  String get currencyQuestion => 'Mata wang apa yang anda gunakan?';

  @override
  String get currencyHint =>
      'Anda boleh menukarnya pada bila-bila masa dalam Tetapan.';

  @override
  String get currencyContinue => 'Teruskan';

  @override
  String get loginTitle => 'Log Masuk';

  @override
  String get loginEnterPhrase => 'Masukkan seed phrase anda';

  @override
  String get loginPhraseHint =>
      'Taip atau tampal frasa 12 atau 24 kata anda, dipisahkan dengan ruang.';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => 'Padam';

  @override
  String loginWordCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString kata',
    );
    return '$_temp0';
  }

  @override
  String get loginButton => 'Log Masuk';

  @override
  String get loginErrorInvalidWord =>
      'Satu atau lebih perkataan bukan perkataan BIP39 yang sah.';

  @override
  String get loginErrorInvalidChecksum =>
      'Seed phrase tidak sah — checksum tidak sepadan.';

  @override
  String get loginErrorInvalidWordCount =>
      'Seed phrase mestilah 12 atau 24 perkataan.';

  @override
  String get loginErrorGeneric =>
      'Seed phrase tidak sah. Sila semak dan cuba lagi.';

  @override
  String get onboardingTitle => 'Sediakan katalog anda';

  @override
  String get onboardingSubtitle => 'Bagaimana anda ingin bermula?';

  @override
  String get onboardingImportTitle => 'Import dari peranti lama';

  @override
  String get onboardingImportSubtitle =>
      'Pulihkan katalog anda dari sandaran CSV';

  @override
  String get onboardingManualTitle => 'Sediakan item secara manual';

  @override
  String get onboardingManualSubtitle =>
      'Gunakan katalog contoh atau tambah item anda sendiri';

  @override
  String onboardingImportFailed(String error) {
    return 'Import gagal: $error';
  }
}
