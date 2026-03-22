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

  @override
  String get helpTitle => 'Bantuan & Dukungan';

  @override
  String get helpFaqTitle => 'Pertanyaan yang Sering Diajukan';

  @override
  String get helpHowToPlaceOrder => 'Cara membuat pesanan?';

  @override
  String get helpHowToPlaceOrderAnswer =>
      'Anda dapat memilih produk dari halaman utama dan konfirmasi pilihan.';

  @override
  String get helpPaymentMethods => 'Metode pembayaran yang tersedia?';

  @override
  String get helpPaymentMethodsAnswer =>
      'Kami mendukung Kartu Kredit, Dompet Digital, dan Tunai.';

  @override
  String get helpCancelOrder => 'Bisakah saya membatalkan pesanan?';

  @override
  String get helpCancelOrderAnswer =>
      'Pesanan dapat dihapus sebelum konfirmasi dari bilah pesanan.';

  @override
  String get helpContactUs => 'Hubungi Kami';

  @override
  String get helpEmailSupport => 'Dukungan Email';

  @override
  String get helpWhatsAppSupport => 'Dukungan WhatsApp';

  @override
  String get helpCallCenter => 'Pusat Panggilan';

  @override
  String get dataTitle => 'Cadangan & Pemulihan';

  @override
  String get dataBackupSection => 'Cadangan';

  @override
  String get dataBackupTitle => 'Cadangkan Katalog';

  @override
  String get dataBackupSubtitle => 'Simpan semua item dan kategori ke file CSV';

  @override
  String get dataRestoreSection => 'Pemulihan';

  @override
  String get dataRestoreTitle => 'Pulihkan dari Cadangan';

  @override
  String get dataRestoreSubtitle =>
      'Muat item dari file CSV yang disimpan sebelumnya';

  @override
  String get dataRestoreNote =>
      'Catatan: Item dengan ID yang sama dalam cadangan akan menimpa yang sudah ada.';

  @override
  String get dataBackupSuccess => 'Cadangan berhasil disimpan';

  @override
  String dataBackupFailed(String error) {
    return 'Cadangan gagal: $error';
  }

  @override
  String dataRestoreFailed(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '$count item berhasil dipulihkan';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsDisplayCurrency => 'Mata Uang Tampilan';

  @override
  String get settingsDynamicPricing => 'Harga Dinamis';

  @override
  String get settingsDynamicPricingUnavailable =>
      'Tidak tersedia untuk mata uang tampilan KAS';

  @override
  String get settingsDynamicPricingSubtitle =>
      'Perbarui harga otomatis setiap 60 detik';

  @override
  String get settingsAppInfo => 'Info Aplikasi';

  @override
  String get settingsAppVersion => 'Versi Aplikasi';

  @override
  String get settingsTermsOfService => 'Ketentuan Layanan';

  @override
  String get themeTitle => 'Pengaturan Tema';

  @override
  String get themeMode => 'Mode Tema';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Terang';

  @override
  String get themeModeDark => 'Gelap';

  @override
  String get themePrimaryColor => 'Warna Utama';

  @override
  String get themeResetToDefault => 'Atur ulang ke default';

  @override
  String get themePreview => 'Pratinjau';

  @override
  String get themePreviewSampleCard => 'Kartu Contoh';

  @override
  String get themePreviewSampleCardBody =>
      'Begini tampilan tema Anda dengan warna yang dipilih.';

  @override
  String get themePreviewFilledButton => 'Tombol Terisi';

  @override
  String get themePreviewOutlinedButton => 'Tombol Bergaris';

  @override
  String get themePreviewTextButton => 'Tombol Teks';

  @override
  String get networkTitle => 'Jaringan';

  @override
  String get networkActiveNetwork => 'Jaringan Aktif';

  @override
  String get networkMainnet => 'Mainnet';

  @override
  String get networkMainnetSubtitle => 'Jaringan Kaspa produksi';

  @override
  String get networkTestnet10 => 'Testnet-10';

  @override
  String get networkTestnet10Subtitle => 'Jaringan uji · menggunakan TKAS';

  @override
  String get networkNodeStatus => 'Status Node';

  @override
  String get networkConnected => 'Terhubung';

  @override
  String get networkDisconnected => 'Terputus';

  @override
  String get networkVirtualDaaScore => 'Skor DAA Virtual';

  @override
  String get networkCustomNodeUrls => 'URL Node Kustom';

  @override
  String get networkMainnetUrl => 'URL WebSocket Mainnet';

  @override
  String get networkTestnet10Url => 'URL WebSocket Testnet-10';

  @override
  String get networkSave => 'Simpan';

  @override
  String get networkSaved => 'Tersimpan — menghubungkan kembali…';

  @override
  String get networkRequired => 'Wajib diisi';

  @override
  String get networkAutoMode => 'Otomatis (Resolver)';

  @override
  String get networkCustomMode => 'Node Kustom';

  @override
  String get networkResolving => 'Mencari node terbaik…';

  @override
  String networkResolvedNode(String url) {
    return 'Node: $url';
  }

  @override
  String get networkResetToAuto => 'Reset ke Otomatis';

  @override
  String get networkResetToAutoSnackbar =>
      'Reset ke otomatis — menghubungkan kembali…';

  @override
  String get donateTitle => 'Donasi';

  @override
  String get donateSupportDeveloper => 'Dukung Pengembang';

  @override
  String get donateSupportDeveloperBody =>
      'Kasway gratis dan open source. Jika bermanfaat, pertimbangkan untuk mengirim donasi KAS satu kali langsung ke pengembang.';

  @override
  String get donateAddressCopied => 'Alamat disalin';

  @override
  String get donateDonateNow => 'Donasi Sekarang';

  @override
  String get donateKas => 'Donasi KAS';

  @override
  String donateRecipient(String address) {
    return 'Penerima: $address';
  }

  @override
  String donateAvailable(String amount) {
    return 'Tersedia: $amount KAS';
  }

  @override
  String get donateAmountLabel => 'Jumlah (KAS)';

  @override
  String get donateAmountRequired => 'Jumlah wajib diisi';

  @override
  String get donateAmountInvalid => 'Masukkan jumlah yang valid';

  @override
  String get donateSend => 'Kirim';

  @override
  String donateThankYou(String txId) {
    return 'Terima kasih! TX: $txId';
  }

  @override
  String get donateTransactionFailed => 'Transaksi Gagal';

  @override
  String get donateAutoPerPayment => 'Auto-Donasi Per Pembayaran';

  @override
  String get donateAutoPerPaymentBody =>
      'Kirim sejumlah kecil KAS secara diam-diam ke pengembang setelah setiap pembayaran pelanggan terkonfirmasi (hanya mainnet).';

  @override
  String get donateEnableAuto => 'Aktifkan Auto-Donasi';

  @override
  String get donatePercentage => 'Persentase transaksi';

  @override
  String get donateFixed => 'Jumlah tetap (KAS)';

  @override
  String get donatePercentageLabel => 'Persentase (%)';

  @override
  String get donateAmountKasLabel => 'Jumlah (KAS)';

  @override
  String get donateSaveSettings => 'Simpan';

  @override
  String get donateInvalidValue => 'Masukkan nilai yang valid lebih dari 0';

  @override
  String get donateSettingsSaved => 'Pengaturan auto-donasi tersimpan';

  @override
  String get donateHistory => 'Riwayat Donasi';

  @override
  String get donateNoDonations => 'Belum ada donasi';

  @override
  String get donateTxIdCopied => 'ID TX disalin';

  @override
  String get donateNoWallet =>
      'Tidak ada mnemonic dompet. Siapkan dompet Anda terlebih dahulu.';

  @override
  String get displayTitle => 'Layar Eksternal';

  @override
  String get displaySubtitle =>
      'Cerminkan layar QR pembayaran ke layar yang terhubung.';

  @override
  String get displayNotSupported => 'Tersedia di Android dan iOS saja.';

  @override
  String get displayAvailableDisplays => 'Layar yang Tersedia';

  @override
  String get displayScan => 'Pindai';

  @override
  String get displayNoDisplays =>
      'Tidak ada layar ditemukan. Ketuk Pindai untuk mencari.';

  @override
  String get displayConnect => 'Hubungkan';

  @override
  String get displayStatus => 'Status';

  @override
  String displayConnected(String name) {
    return 'Terhubung: $name';
  }

  @override
  String get displayNotConnected => 'Tidak terhubung';

  @override
  String get displayReconnect => 'Hubungkan Ulang';

  @override
  String get displayDisconnect => 'Putuskan';

  @override
  String get tableLayoutTitle => 'Tata Letak Meja';

  @override
  String get tableLayoutSave => 'Simpan';

  @override
  String get tableLayoutFeatureToggle => 'Tata Letak Meja';

  @override
  String get tableLayoutAddTable => 'Tambah Meja';

  @override
  String get tableLayoutRotateCcw => 'Putar berlawanan jarum jam';

  @override
  String get tableLayoutRotateCw => 'Putar searah jarum jam';

  @override
  String get tableLayoutDeleteGroup => 'Hapus Grup';

  @override
  String get tableLayoutDeleteTable => 'Hapus Meja';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return 'Hapus seluruh grup ($count meja)?';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return 'Hapus meja \"$label\"?';
  }

  @override
  String get tableLayoutCancel => 'Batal';

  @override
  String get tableLayoutDelete => 'Hapus';

  @override
  String get tableLayoutUnsavedChanges => 'Perubahan Belum Disimpan';

  @override
  String get tableLayoutUnsavedChangesContent =>
      'Ada perubahan yang belum disimpan. Buang dan keluar?';

  @override
  String get tableLayoutKeepEditing => 'Lanjutkan mengedit';

  @override
  String get tableLayoutDiscard => 'Buang';

  @override
  String get tableLayoutSingleTables => 'MEJA TUNGGAL';

  @override
  String get tableLayoutTableGroups => 'GRUP MEJA';

  @override
  String get tableLayoutTableGroupsBody =>
      'Tempatkan beberapa meja sekaligus dalam susunan preset.';

  @override
  String get tableLayoutAddTableSheet => 'Tambah Meja';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return ' · $seats kursi';
  }

  @override
  String get tableLayoutRename => 'Ubah Nama';

  @override
  String get tableLayoutSaveName => 'Simpan';

  @override
  String get orderHistoryTitle => 'Riwayat Pesanan';

  @override
  String get orderHistoryNoOrders => 'Belum ada pesanan';

  @override
  String get orderHistoryTodayOrders => 'Pesanan Hari Ini';

  @override
  String get orderHistoryTodayRevenue => 'Pendapatan Hari Ini';

  @override
  String get orderHistoryToday => 'Hari Ini';

  @override
  String get orderHistoryYesterday => 'Kemarin';

  @override
  String get orderHistoryNoItemDetails => 'Detail item tidak tercatat';

  @override
  String get orderHistoryTotal => 'Total';

  @override
  String get orderHistoryViewOnExplorer => 'Lihat di Explorer';

  @override
  String orderHistoryTable(String label) {
    return 'Meja $label';
  }

  @override
  String get withdrawalHistoryTitle => 'Riwayat Penarikan';

  @override
  String get withdrawalHistoryNoWithdrawals => 'Belum ada penarikan';

  @override
  String get withdrawalHistoryCopyTxId => 'Salin ID TX';

  @override
  String get withdrawalHistoryViewOnExplorer => 'Lihat di Explorer';

  @override
  String get withdrawalHistoryTxIdCopied => 'ID TX disalin';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSelectSection => 'Pilih bagian';

  @override
  String get profileOrderHistory => 'Riwayat Pesanan';

  @override
  String get profileManageItem => 'Kelola Item';

  @override
  String get profileTableLayout => 'Tata Letak Meja';

  @override
  String get profileBackupRestore => 'Cadangan & Pemulihan';

  @override
  String get profileNetworkNode => 'Jaringan & Node';

  @override
  String get profileDisplay => 'Layar';

  @override
  String get profileThemeSettings => 'Pengaturan Tema';

  @override
  String get profileSettings => 'Pengaturan';

  @override
  String get profileDonate => 'Donasi';

  @override
  String get profileLogout => 'Keluar';

  @override
  String get profileLogoutContent => 'Apakah Anda yakin ingin keluar?';

  @override
  String get profileCancel => 'Batal';

  @override
  String get profileKaspaAddress => 'Alamat Kaspa';

  @override
  String get profileNoWallet => 'Tidak ada dompet yang dikonfigurasi';

  @override
  String get profileCopyAddress => 'Salin alamat';

  @override
  String get profileViewInExplorer => 'Lihat di explorer';

  @override
  String get profileBalance => 'Saldo';

  @override
  String get profileWithdraw => 'Tarik';

  @override
  String get profileAddressCopied => 'Alamat disalin';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return 'Tarik $kasSymbol';
  }

  @override
  String get profileDestinationAddress => 'Alamat Kaspa Tujuan';

  @override
  String get profileAddressRequired => 'Alamat wajib diisi';

  @override
  String profileAddressInvalid(String hrp) {
    return 'Harus berupa alamat $hrp: yang valid';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return 'Jumlah ($kasSymbol)';
  }

  @override
  String get profileAmountRequired => 'Jumlah wajib diisi';

  @override
  String get profileAmountInvalid => 'Masukkan jumlah yang valid';

  @override
  String get profileSend => 'Kirim';

  @override
  String get profileTransactionFailed => 'Transaksi Gagal';

  @override
  String get profileWithdrawNoWallet =>
      'Tidak ada mnemonic dompet. Siapkan dompet Anda terlebih dahulu.';

  @override
  String get profileWithdrawalSuccessTitle => 'Penarikan Berhasil!';

  @override
  String get profileWithdrawalSuccessSubtitle =>
      'KAS Anda telah berhasil dikirim.';

  @override
  String get profileMax => 'Maks';

  @override
  String get homeFailedToLoad => 'Gagal memuat produk';

  @override
  String get homeNoProducts => 'Tidak ada produk';

  @override
  String get homeConfirmSelection => 'Konfirmasi Pilihan';

  @override
  String get homeClearOrderTitle => 'Hapus Pesanan?';

  @override
  String get homeClearOrderContent =>
      'Apakah Anda yakin ingin menghapus semua item dari daftar pesanan?';

  @override
  String get homeClearOrder => 'Hapus Pesanan';

  @override
  String get homeCancel => 'Batal';

  @override
  String get homeTestnetBanner => 'Menggunakan aplikasi dalam mode Testnet';

  @override
  String get paymentTitle => 'Pembayaran';

  @override
  String get paymentNoWallet =>
      'Tidak ada dompet. Siapkan dompet Anda terlebih dahulu.';

  @override
  String get paymentFetchingRates => 'Mengambil nilai tukar…';

  @override
  String get paymentPleaseWait => 'Harap tunggu sebentar.';

  @override
  String get paymentRetry => 'Coba Lagi';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '$received dari $total $kasSymbol diterima';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return 'Kirim hanya $kasSymbol, dan tepat jumlah yang ditampilkan di atas. Mengirim aset lain atau jumlah yang salah dapat mengakibatkan dana hilang.';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return 'Auto-donasi aktif — $amount $kasSymbol akan dikirim ke pengembang setelah konfirmasi pembayaran.';
  }

  @override
  String get paymentOrderList => 'Daftar Pesanan';

  @override
  String get tableSelectTitle => 'Pilih Meja';

  @override
  String get tableSelectMarkAsServed => 'Tandai Sudah Dilayani';

  @override
  String get tableSelectFreeTable => 'Bebaskan Meja';

  @override
  String tableSelectFreeTableContent(String label) {
    return 'Tandai Meja $label sebagai tersedia? Ini akan menghapus status terisi.';
  }

  @override
  String get tableSelectFreeTableTitle => 'Bebaskan Meja';

  @override
  String tableSelectTableLabel(String label) {
    return 'Meja $label';
  }

  @override
  String get tableSelectNoTables => 'Tidak ada meja yang dikonfigurasi';

  @override
  String get tableSelectNoTablesBody =>
      'Atur denah lantai di Profil > Tata Letak Meja.';

  @override
  String get tableSelectGoToLayout => 'Ke Tata Letak Meja';

  @override
  String get paymentSuccessTitle => 'Pembayaran Berhasil!';

  @override
  String get paymentSuccessSubtitle => 'Transaksi telah berhasil diproses.';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return 'Anda akan diarahkan dalam $count detik$plural...';
  }

  @override
  String get itemManageTitle => 'Kelola Item';

  @override
  String get itemNoCategoriesYet => 'Belum ada kategori';

  @override
  String get itemCreateCategory => 'Buat Kategori';

  @override
  String get itemNoItemsInCategory => 'Tidak ada item di kategori ini';

  @override
  String get itemDeleteProductTitle => 'Hapus Produk?';

  @override
  String itemDeleteProductInCart(String name) {
    return '\"$name\" ada di pesanan aktif. Menghapus juga akan menghapusnya dari keranjang.';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return 'Hapus \"$name\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get itemDeleteCancel => 'Batal';

  @override
  String get itemDeleteConfirm => 'Hapus';

  @override
  String get itemDone => 'Selesai';

  @override
  String itemAdditionCount(int count, String plural) {
    return ' · $count tambahan$plural';
  }

  @override
  String get itemFormEditTitle => 'Edit Produk';

  @override
  String get itemFormAddTitle => 'Tambah Produk';

  @override
  String get itemFormSave => 'Simpan';

  @override
  String get itemFormProductName => 'Nama Produk';

  @override
  String get itemFormRequired => 'Wajib diisi';

  @override
  String get itemFormInvalidNumber => 'Masukkan angka yang valid';

  @override
  String get itemFormCategory => 'Kategori';

  @override
  String get itemFormDescription => 'Deskripsi (opsional)';

  @override
  String get itemFormAdditions => 'Tambahan';

  @override
  String get itemFormAddAddition => 'Tambah Pilihan';

  @override
  String get itemFormAdditionFree => 'Gratis';

  @override
  String get itemFormEditAdditionTitle => 'Edit Tambahan';

  @override
  String get itemFormNewAdditionTitle => 'Tambahan Baru';

  @override
  String get itemFormAdditionName => 'Nama Tambahan';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return 'Harga Ekstra ($code, 0 = gratis)';
  }

  @override
  String get itemFormCancel => 'Batal';

  @override
  String get categoryManageTitle => 'Kategori';

  @override
  String get categoryAddCategory => 'Tambah Kategori';

  @override
  String get categoryNewCategory => 'Kategori Baru';

  @override
  String get categoryNameLabel => 'Nama Kategori';

  @override
  String get categoryAdd => 'Tambah';

  @override
  String get categoryCancel => 'Batal';

  @override
  String get categoryRenameTitle => 'Ubah Nama Kategori';

  @override
  String get categoryRename => 'Ubah Nama';

  @override
  String get categoryDeleteTitle => 'Hapus Kategori?';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '\"$name\" memiliki $count item$plural yang juga akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return 'Hapus \"$name\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get categoryDelete => 'Hapus';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count item$plural';
  }

  @override
  String get itemManageCreate => 'Buat';
}
