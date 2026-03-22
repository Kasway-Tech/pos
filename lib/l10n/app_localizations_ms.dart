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

  @override
  String get helpTitle => 'Bantuan & Sokongan';

  @override
  String get helpFaqTitle => 'Soalan Lazim';

  @override
  String get helpHowToPlaceOrder => 'Cara membuat pesanan?';

  @override
  String get helpHowToPlaceOrderAnswer =>
      'Anda boleh memilih produk dari halaman utama dan sahkan pilihan.';

  @override
  String get helpPaymentMethods => 'Kaedah pembayaran yang tersedia?';

  @override
  String get helpPaymentMethodsAnswer =>
      'Kami menyokong Kad Kredit, E-Wallet, dan Tunai.';

  @override
  String get helpCancelOrder => 'Bolehkah saya membatalkan pesanan?';

  @override
  String get helpCancelOrderAnswer =>
      'Pesanan boleh dibersihkan sebelum pengesahan dari bar pesanan.';

  @override
  String get helpContactUs => 'Hubungi Kami';

  @override
  String get helpEmailSupport => 'Sokongan E-mel';

  @override
  String get helpWhatsAppSupport => 'Sokongan WhatsApp';

  @override
  String get helpCallCenter => 'Pusat Panggilan';

  @override
  String get dataTitle => 'Sandaran & Pemulihan';

  @override
  String get dataBackupSection => 'Sandaran';

  @override
  String get dataBackupTitle => 'Sandarkan Katalog';

  @override
  String get dataBackupSubtitle => 'Simpan semua item dan kategori ke fail CSV';

  @override
  String get dataRestoreSection => 'Pemulihan';

  @override
  String get dataRestoreTitle => 'Pulih dari Sandaran';

  @override
  String get dataRestoreSubtitle =>
      'Muatkan item dari fail CSV yang disimpan sebelumnya';

  @override
  String get dataRestoreNote =>
      'Nota: Item dengan ID yang sama dalam sandaran akan menggantikan yang sedia ada.';

  @override
  String get dataBackupSuccess => 'Sandaran berjaya disimpan';

  @override
  String dataBackupFailed(String error) {
    return 'Sandaran gagal: $error';
  }

  @override
  String dataRestoreFailed(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '$count item berjaya dipulihkan';
  }

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsDisplayCurrency => 'Mata Wang Paparan';

  @override
  String get settingsDynamicPricing => 'Harga Dinamik';

  @override
  String get settingsDynamicPricingUnavailable =>
      'Tidak tersedia untuk mata wang paparan KAS';

  @override
  String get settingsDynamicPricingSubtitle =>
      'Kemas kini harga secara automatik setiap 60 saat';

  @override
  String get settingsAppInfo => 'Maklumat Aplikasi';

  @override
  String get settingsAppVersion => 'Versi Aplikasi';

  @override
  String get settingsTermsOfService => 'Terma Perkhidmatan';

  @override
  String get themeTitle => 'Tetapan Tema';

  @override
  String get themeMode => 'Mod Tema';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Cerah';

  @override
  String get themeModeDark => 'Gelap';

  @override
  String get themePrimaryColor => 'Warna Utama';

  @override
  String get themeResetToDefault => 'Tetap semula ke lalai';

  @override
  String get themePreview => 'Pratonton';

  @override
  String get themePreviewSampleCard => 'Kad Sampel';

  @override
  String get themePreviewSampleCardBody =>
      'Beginilah tema anda akan kelihatan dengan warna yang dipilih.';

  @override
  String get themePreviewFilledButton => 'Butang Terisi';

  @override
  String get themePreviewOutlinedButton => 'Butang Bergaris';

  @override
  String get themePreviewTextButton => 'Butang Teks';

  @override
  String get networkTitle => 'Rangkaian';

  @override
  String get networkActiveNetwork => 'Rangkaian Aktif';

  @override
  String get networkMainnet => 'Mainnet';

  @override
  String get networkMainnetSubtitle => 'Rangkaian Kaspa pengeluaran';

  @override
  String get networkTestnet10 => 'Testnet-10';

  @override
  String get networkTestnet10Subtitle => 'Rangkaian ujian · menggunakan TKAS';

  @override
  String get networkNodeStatus => 'Status Nod';

  @override
  String get networkConnected => 'Disambungkan';

  @override
  String get networkDisconnected => 'Terputus';

  @override
  String get networkVirtualDaaScore => 'Skor DAA Maya';

  @override
  String get networkCustomNodeUrls => 'URL Nod Tersuai';

  @override
  String get networkMainnetUrl => 'URL WebSocket Mainnet';

  @override
  String get networkTestnet10Url => 'URL WebSocket Testnet-10';

  @override
  String get networkSave => 'Simpan';

  @override
  String get networkSaved => 'Tersimpan — menyambung semula…';

  @override
  String get networkRequired => 'Diperlukan';

  @override
  String get networkAutoMode => 'Auto (Penyelesai)';

  @override
  String get networkCustomMode => 'Nod Tersuai';

  @override
  String get networkResolving => 'Mencari nod terbaik…';

  @override
  String networkResolvedNode(String url) {
    return 'Nod: $url';
  }

  @override
  String get networkResetToAuto => 'Set Semula ke Auto';

  @override
  String get networkResetToAutoSnackbar =>
      'Set semula ke auto — menyambung semula…';

  @override
  String get donateTitle => 'Derma';

  @override
  String get donateSupportDeveloper => 'Sokong Pembangun';

  @override
  String get donateSupportDeveloperBody =>
      'Kasway percuma dan sumber terbuka. Jika berguna, pertimbangkan untuk menghantar derma KAS sekali kepada pembangun.';

  @override
  String get donateAddressCopied => 'Alamat disalin';

  @override
  String get donateDonateNow => 'Derma Sekarang';

  @override
  String get donateKas => 'Derma KAS';

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
  String get donateAmountRequired => 'Jumlah diperlukan';

  @override
  String get donateAmountInvalid => 'Masukkan jumlah yang sah';

  @override
  String get donateSend => 'Hantar';

  @override
  String donateThankYou(String txId) {
    return 'Terima kasih! TX: $txId';
  }

  @override
  String get donateTransactionFailed => 'Transaksi Gagal';

  @override
  String get donateAutoPerPayment => 'Auto-Derma Per Pembayaran';

  @override
  String get donateAutoPerPaymentBody =>
      'Hantar sejumlah kecil KAS secara senyap kepada pembangun selepas setiap pembayaran pelanggan disahkan (mainnet sahaja).';

  @override
  String get donateEnableAuto => 'Aktifkan Auto-Derma';

  @override
  String get donatePercentage => 'Peratusan transaksi';

  @override
  String get donateFixed => 'Jumlah tetap (KAS)';

  @override
  String get donatePercentageLabel => 'Peratusan (%)';

  @override
  String get donateAmountKasLabel => 'Jumlah (KAS)';

  @override
  String get donateSaveSettings => 'Simpan';

  @override
  String get donateInvalidValue => 'Masukkan nilai yang sah lebih daripada 0';

  @override
  String get donateSettingsSaved => 'Tetapan auto-derma disimpan';

  @override
  String get donateHistory => 'Sejarah Derma';

  @override
  String get donateNoDonations => 'Tiada derma lagi';

  @override
  String get donateTxIdCopied => 'ID TX disalin';

  @override
  String get donateNoWallet =>
      'Tiada mnemonic dompet dijumpai. Sila sediakan dompet anda terlebih dahulu.';

  @override
  String get displayTitle => 'Paparan Luaran';

  @override
  String get displaySubtitle =>
      'Cerminkan skrin QR pembayaran ke paparan yang disambungkan.';

  @override
  String get displayNotSupported => 'Tersedia di Android dan iOS sahaja.';

  @override
  String get displayAvailableDisplays => 'Paparan yang Tersedia';

  @override
  String get displayScan => 'Imbas';

  @override
  String get displayNoDisplays =>
      'Tiada paparan dijumpai. Ketik Imbas untuk mencari.';

  @override
  String get displayConnect => 'Sambung';

  @override
  String get displayStatus => 'Status';

  @override
  String displayConnected(String name) {
    return 'Disambungkan: $name';
  }

  @override
  String get displayNotConnected => 'Tidak disambungkan';

  @override
  String get displayReconnect => 'Sambung Semula';

  @override
  String get displayDisconnect => 'Putuskan';

  @override
  String get tableLayoutTitle => 'Susun Atur Meja';

  @override
  String get tableLayoutSave => 'Simpan';

  @override
  String get tableLayoutFeatureToggle => 'Susun Atur Meja';

  @override
  String get tableLayoutAddTable => 'Tambah Meja';

  @override
  String get tableLayoutRotateCcw => 'Putar berlawanan arah jam';

  @override
  String get tableLayoutRotateCw => 'Putar ikut arah jam';

  @override
  String get tableLayoutDeleteGroup => 'Padam Kumpulan';

  @override
  String get tableLayoutDeleteTable => 'Padam Meja';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return 'Padam seluruh kumpulan ($count meja)?';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return 'Padam meja \"$label\"?';
  }

  @override
  String get tableLayoutCancel => 'Batal';

  @override
  String get tableLayoutDelete => 'Padam';

  @override
  String get tableLayoutUnsavedChanges => 'Perubahan Belum Disimpan';

  @override
  String get tableLayoutUnsavedChangesContent =>
      'Terdapat perubahan yang belum disimpan. Buang dan keluar?';

  @override
  String get tableLayoutKeepEditing => 'Teruskan mengedit';

  @override
  String get tableLayoutDiscard => 'Buang';

  @override
  String get tableLayoutSingleTables => 'MEJA TUNGGAL';

  @override
  String get tableLayoutTableGroups => 'KUMPULAN MEJA';

  @override
  String get tableLayoutTableGroupsBody =>
      'Letakkan beberapa meja sekaligus dalam susunan pratetap.';

  @override
  String get tableLayoutAddTableSheet => 'Tambah Meja';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return ' · $seats tempat duduk';
  }

  @override
  String get tableLayoutRename => 'Namakan Semula';

  @override
  String get tableLayoutSaveName => 'Simpan';

  @override
  String get orderHistoryTitle => 'Sejarah Pesanan';

  @override
  String get orderHistoryNoOrders => 'Tiada pesanan lagi';

  @override
  String get orderHistoryTodayOrders => 'Pesanan Hari Ini';

  @override
  String get orderHistoryTodayRevenue => 'Hasil Hari Ini';

  @override
  String get orderHistoryToday => 'Hari Ini';

  @override
  String get orderHistoryYesterday => 'Semalam';

  @override
  String get orderHistoryNoItemDetails => 'Tiada butiran item direkodkan';

  @override
  String get orderHistoryTotal => 'Jumlah';

  @override
  String get orderHistoryViewOnExplorer => 'Lihat di Explorer';

  @override
  String orderHistoryTable(String label) {
    return 'Meja $label';
  }

  @override
  String get withdrawalHistoryTitle => 'Sejarah Pengeluaran';

  @override
  String get withdrawalHistoryNoWithdrawals => 'Tiada pengeluaran lagi';

  @override
  String get withdrawalHistoryCopyTxId => 'Salin ID TX';

  @override
  String get withdrawalHistoryViewOnExplorer => 'Lihat di Explorer';

  @override
  String get withdrawalHistoryTxIdCopied => 'ID TX disalin';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSelectSection => 'Pilih bahagian';

  @override
  String get profileOrderHistory => 'Sejarah Pesanan';

  @override
  String get profileManageItem => 'Urus Item';

  @override
  String get profileTableLayout => 'Susun Atur Meja';

  @override
  String get profileBackupRestore => 'Sandaran & Pemulihan';

  @override
  String get profileNetworkNode => 'Rangkaian & Nod';

  @override
  String get profileDisplay => 'Paparan';

  @override
  String get profileThemeSettings => 'Tetapan Tema';

  @override
  String get profileSettings => 'Tetapan';

  @override
  String get profileDonate => 'Derma';

  @override
  String get profileLogout => 'Log Keluar';

  @override
  String get profileLogoutContent => 'Adakah anda pasti mahu log keluar?';

  @override
  String get profileCancel => 'Batal';

  @override
  String get profileKaspaAddress => 'Alamat Kaspa';

  @override
  String get profileNoWallet => 'Tiada dompet dikonfigurasi';

  @override
  String get profileCopyAddress => 'Salin alamat';

  @override
  String get profileViewInExplorer => 'Lihat di explorer';

  @override
  String get profileBalance => 'Baki';

  @override
  String get profileWithdraw => 'Keluarkan';

  @override
  String get profileAddressCopied => 'Alamat disalin';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return 'Keluarkan $kasSymbol';
  }

  @override
  String get profileDestinationAddress => 'Alamat Kaspa Destinasi';

  @override
  String get profileAddressRequired => 'Alamat diperlukan';

  @override
  String profileAddressInvalid(String hrp) {
    return 'Mesti berupa alamat $hrp: yang sah';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return 'Jumlah ($kasSymbol)';
  }

  @override
  String get profileAmountRequired => 'Jumlah diperlukan';

  @override
  String get profileAmountInvalid => 'Masukkan jumlah yang sah';

  @override
  String get profileSend => 'Hantar';

  @override
  String get profileTransactionFailed => 'Transaksi Gagal';

  @override
  String get profileWithdrawNoWallet =>
      'Tiada mnemonic dompet dijumpai. Sila sediakan dompet anda terlebih dahulu.';

  @override
  String get profileWithdrawalSuccessTitle => 'Pengeluaran Berjaya!';

  @override
  String get profileWithdrawalSuccessSubtitle =>
      'KAS anda telah berjaya dihantar.';

  @override
  String get profileMax => 'Maks';

  @override
  String get homeFailedToLoad => 'Gagal memuatkan produk';

  @override
  String get homeNoProducts => 'Tiada produk dijumpai';

  @override
  String get homeConfirmSelection => 'Sahkan Pilihan';

  @override
  String get homeClearOrderTitle => 'Kosongkan Pesanan?';

  @override
  String get homeClearOrderContent =>
      'Adakah anda pasti mahu mengeluarkan semua item dari senarai pesanan?';

  @override
  String get homeClearOrder => 'Kosongkan Pesanan';

  @override
  String get homeCancel => 'Batal';

  @override
  String get homeTestnetBanner => 'Menggunakan aplikasi dalam mod Testnet';

  @override
  String get paymentTitle => 'Pembayaran';

  @override
  String get paymentNoWallet =>
      'Tiada dompet dikonfigurasi. Sila sediakan dompet anda terlebih dahulu.';

  @override
  String get paymentFetchingRates => 'Mengambil kadar pertukaran…';

  @override
  String get paymentPleaseWait => 'Sila tunggu sebentar.';

  @override
  String get paymentRetry => 'Cuba Lagi';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '$received daripada $total $kasSymbol diterima';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return 'Hantar $kasSymbol sahaja, dan tepat jumlah yang ditunjukkan di atas. Menghantar aset lain atau jumlah yang salah mungkin mengakibatkan dana hilang.';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return 'Auto-derma aktif — $amount $kasSymbol akan dihantar kepada pembangun selepas pengesahan pembayaran.';
  }

  @override
  String get paymentOrderList => 'Senarai Pesanan';

  @override
  String get tableSelectTitle => 'Pilih Meja';

  @override
  String get tableSelectMarkAsServed => 'Tandakan Telah Dilayani';

  @override
  String get tableSelectFreeTable => 'Bebaskan Meja';

  @override
  String tableSelectFreeTableContent(String label) {
    return 'Tandakan Meja $label sebagai tersedia? Ini akan mengeluarkan status diduduki.';
  }

  @override
  String get tableSelectFreeTableTitle => 'Bebaskan Meja';

  @override
  String tableSelectTableLabel(String label) {
    return 'Meja $label';
  }

  @override
  String get tableSelectNoTables => 'Tiada meja dikonfigurasi';

  @override
  String get tableSelectNoTablesBody =>
      'Sediakan pelan lantai anda dalam Profil > Susun Atur Meja.';

  @override
  String get tableSelectGoToLayout => 'Pergi ke Susun Atur Meja';

  @override
  String get paymentSuccessTitle => 'Pembayaran Berjaya!';

  @override
  String get paymentSuccessSubtitle => 'Transaksi telah berjaya diproses.';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return 'Anda akan diarahkan dalam $count saat$plural...';
  }

  @override
  String get itemManageTitle => 'Urus Item';

  @override
  String get itemNoCategoriesYet => 'Tiada kategori lagi';

  @override
  String get itemCreateCategory => 'Buat Kategori';

  @override
  String get itemNoItemsInCategory => 'Tiada item dalam kategori ini';

  @override
  String get itemDeleteProductTitle => 'Padam Produk?';

  @override
  String itemDeleteProductInCart(String name) {
    return '\"$name\" ada dalam pesanan aktif. Memadam juga akan mengeluarkannya dari troli.';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return 'Padam \"$name\"? Tindakan ini tidak boleh dibatalkan.';
  }

  @override
  String get itemDeleteCancel => 'Batal';

  @override
  String get itemDeleteConfirm => 'Padam';

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
  String get itemFormRequired => 'Diperlukan';

  @override
  String get itemFormInvalidNumber => 'Masukkan nombor yang sah';

  @override
  String get itemFormCategory => 'Kategori';

  @override
  String get itemFormDescription => 'Penerangan (pilihan)';

  @override
  String get itemFormAdditions => 'Tambahan';

  @override
  String get itemFormAddAddition => 'Tambah Pilihan';

  @override
  String get itemFormAdditionFree => 'Percuma';

  @override
  String get itemFormEditAdditionTitle => 'Edit Tambahan';

  @override
  String get itemFormNewAdditionTitle => 'Tambahan Baharu';

  @override
  String get itemFormAdditionName => 'Nama Tambahan';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return 'Harga Ekstra ($code, 0 = percuma)';
  }

  @override
  String get itemFormCancel => 'Batal';

  @override
  String get categoryManageTitle => 'Kategori';

  @override
  String get categoryAddCategory => 'Tambah Kategori';

  @override
  String get categoryNewCategory => 'Kategori Baharu';

  @override
  String get categoryNameLabel => 'Nama Kategori';

  @override
  String get categoryAdd => 'Tambah';

  @override
  String get categoryCancel => 'Batal';

  @override
  String get categoryRenameTitle => 'Namakan Semula Kategori';

  @override
  String get categoryRename => 'Namakan Semula';

  @override
  String get categoryDeleteTitle => 'Padam Kategori?';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '\"$name\" mempunyai $count item$plural yang juga akan dipadam secara kekal. Tindakan ini tidak boleh dibatalkan.';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return 'Padam \"$name\"? Tindakan ini tidak boleh dibatalkan.';
  }

  @override
  String get categoryDelete => 'Padam';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count item$plural';
  }

  @override
  String get itemManageCreate => 'Cipta';
}
