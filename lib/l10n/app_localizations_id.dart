// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get language => 'Bahasa';

  @override
  String get authTagline => 'POS kripto Anda,\ndikelola oleh Anda.';

  @override
  String get authCreateAccount => 'Buat Akun';

  @override
  String get authLoginWithSeedPhrase => 'Masuk dengan seed phrase';

  @override
  String get eulaTitle => 'Syarat & Ketentuan';

  @override
  String get eulaLastUpdated => 'Terakhir diperbarui: Maret 2026';

  @override
  String get eulaMainTitle => 'Perjanjian Lisensi Pengguna Akhir';

  @override
  String get eulaSection1Title => '1. Penerimaan Syarat';

  @override
  String get eulaSection1Body =>
      'Dengan menggunakan Kasway (\"Aplikasi\"), Anda setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak setuju, jangan gunakan Aplikasi.';

  @override
  String get eulaSection2Title => '2. Seed Phrase & Keamanan';

  @override
  String get eulaSection2Body =>
      'Aplikasi menghasilkan seed phrase BIP39 yang disimpan secara lokal di perangkat Anda. Anda sepenuhnya bertanggung jawab untuk menjaga keamanan seed phrase Anda. Kasway tidak menyimpan, mengirimkan, atau memiliki akses ke seed phrase Anda. Kehilangan seed phrase berarti kehilangan akses ke akun Anda secara permanen — tidak ada opsi pemulihan.';

  @override
  String get eulaSection3Title => '3. Bukan Saran Keuangan';

  @override
  String get eulaSection3Body =>
      'Tidak ada konten dalam Aplikasi yang merupakan saran keuangan, investasi, atau hukum. Nilai mata uang kripto sangat fluktuatif. Anda menanggung semua risiko yang terkait dengan transaksi mata uang kripto.';

  @override
  String get eulaSection4Title => '4. Data & Privasi';

  @override
  String get eulaSection4Body =>
      'Semua data katalog dan transaksi disimpan secara lokal di perangkat Anda. Aplikasi mengambil nilai tukar secara langsung dari CoinGecko (layanan pihak ketiga). Tidak ada informasi pribadi yang dikumpulkan atau dikirimkan oleh Kasway.';

  @override
  String get eulaSection5Title => '5. Batasan Tanggung Jawab';

  @override
  String get eulaSection5Body =>
      'Sejauh diizinkan oleh hukum yang berlaku, Kasway dan pengembangnya tidak bertanggung jawab atas kerugian atau kerusakan yang timbul dari penggunaan Aplikasi, termasuk namun tidak terbatas pada kehilangan dana, kehilangan data, atau kehilangan seed phrase.';

  @override
  String get eulaSection6Title => '6. Perubahan Syarat';

  @override
  String get eulaSection6Body =>
      'Kami berhak untuk mengubah syarat ini kapan saja. Penggunaan Aplikasi yang berkelanjutan setelah perubahan merupakan penerimaan terhadap syarat baru.';

  @override
  String get eulaSection7Title => '7. Hukum yang Berlaku';

  @override
  String get eulaSection7Body =>
      'Syarat ini diatur oleh hukum yang berlaku. Setiap perselisihan akan diselesaikan di yurisdiksi tempat Kasway didirikan.';

  @override
  String get eulaAgreeLabel =>
      'Saya telah membaca dan menyetujui Syarat & Ketentuan dan Kebijakan Privasi.';

  @override
  String get eulaContinue => 'Lanjutkan';

  @override
  String get seedPhraseTitle => 'Seed Phrase';

  @override
  String get seedPhraseCopyTooltip => 'Salin ke clipboard';

  @override
  String get seedPhraseWarning =>
      'Tuliskan kata-kata ini. Anda tidak dapat memulihkan akun tanpa kata-kata tersebut.';

  @override
  String seedPhraseError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get seedPhraseCopied => 'Seed phrase disalin ke clipboard';

  @override
  String get seedPhraseConfirm => 'Saya sudah menyimpan seed phrase →';

  @override
  String get currencyTitle => 'Pilih Mata Uang';

  @override
  String get currencyQuestion => 'Mata uang apa yang Anda gunakan?';

  @override
  String get currencyHint =>
      'Anda dapat mengubah ini kapan saja di Pengaturan.';

  @override
  String get currencyContinue => 'Lanjutkan';

  @override
  String get loginTitle => 'Masuk';

  @override
  String get loginEnterPhrase => 'Masukkan seed phrase Anda';

  @override
  String get loginPhraseHint =>
      'Ketik atau tempel frasa 12 atau 24 kata Anda, dipisahkan spasi.';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => 'Hapus';

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
  String get loginButton => 'Masuk';

  @override
  String get loginErrorInvalidWord =>
      'Satu atau lebih kata bukan kata BIP39 yang valid.';

  @override
  String get loginErrorInvalidChecksum =>
      'Seed phrase tidak valid — checksum tidak cocok.';

  @override
  String get loginErrorInvalidWordCount =>
      'Seed phrase harus terdiri dari 12 atau 24 kata.';

  @override
  String get loginErrorGeneric =>
      'Seed phrase tidak valid. Periksa dan coba lagi.';

  @override
  String get onboardingTitle => 'Siapkan katalog Anda';

  @override
  String get onboardingSubtitle => 'Bagaimana Anda ingin memulai?';

  @override
  String get onboardingImportTitle => 'Impor dari perangkat lama';

  @override
  String get onboardingImportSubtitle => 'Pulihkan katalog dari cadangan CSV';

  @override
  String get onboardingManualTitle => 'Siapkan item secara manual';

  @override
  String get onboardingManualSubtitle =>
      'Gunakan katalog sampel atau tambahkan item Anda sendiri';

  @override
  String onboardingImportFailed(String error) {
    return 'Impor gagal: $error';
  }
}
