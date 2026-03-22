// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get language => '言語';

  @override
  String get authTagline => 'あなたのクリプトPOS、\nあなたが守る。';

  @override
  String get authCreateAccount => 'アカウントを作成';

  @override
  String get authLoginWithSeedPhrase => 'シードフレーズでログイン';

  @override
  String get eulaTitle => '利用規約';

  @override
  String get eulaLastUpdated => '最終更新：2026年3月';

  @override
  String get eulaMainTitle => 'エンドユーザーライセンス契約';

  @override
  String get eulaSection1Title => '1. 規約への同意';

  @override
  String get eulaSection1Body =>
      'Kasway（「本アプリ」）を使用することにより、本利用規約に拘束されることに同意したものとみなされます。同意しない場合は、本アプリを使用しないでください。';

  @override
  String get eulaSection2Title => '2. シードフレーズとセキュリティ';

  @override
  String get eulaSection2Body =>
      '本アプリはBIP39シードフレーズを生成し、デバイスにローカルで保存します。シードフレーズの安全管理はお客様の責任となります。Kaswayはシードフレーズを保存・送信・アクセスすることはありません。シードフレーズを紛失した場合、アカウントへのアクセスは永久に失われます — 回復手段はありません。';

  @override
  String get eulaSection3Title => '3. 金融アドバイスの免責';

  @override
  String get eulaSection3Body =>
      '本アプリのいかなる内容も、金融・投資・法律上のアドバイスを構成するものではありません。暗号資産の価値は変動します。暗号資産取引に関連するすべてのリスクはお客様が負担します。';

  @override
  String get eulaSection4Title => '4. データとプライバシー';

  @override
  String get eulaSection4Body =>
      'すべてのカタログおよびトランザクションデータはデバイスにローカルで保存されます。本アプリはCoinGecko（第三者サービス）からリアルタイムの為替レートを取得します。Kaswayが個人を特定できる情報を収集・送信することはありません。';

  @override
  String get eulaSection5Title => '5. 責任の制限';

  @override
  String get eulaSection5Body =>
      '法律で許可される最大限の範囲において、Kaswayおよびその開発者は、資金の損失・データの損失・シードフレーズの損失を含むがこれに限らない、本アプリの使用から生じるいかなる損失や損害についても責任を負いません。';

  @override
  String get eulaSection6Title => '6. 規約の変更';

  @override
  String get eulaSection6Body =>
      '当社はいつでも本規約を変更する権利を留保します。変更後に本アプリを継続して使用した場合、新しい規約への同意とみなされます。';

  @override
  String get eulaSection7Title => '7. 準拠法';

  @override
  String get eulaSection7Body =>
      '本規約は適用法律に準拠します。いかなる紛争も、Kaswayが設立された管轄区域において解決されるものとします。';

  @override
  String get eulaAgreeLabel => '利用規約およびプライバシーポリシーを読み、同意します。';

  @override
  String get eulaContinue => '続ける';

  @override
  String get seedPhraseTitle => 'シードフレーズ';

  @override
  String get seedPhraseCopyTooltip => 'クリップボードにコピー';

  @override
  String get seedPhraseWarning => 'これらの単語を書き留めてください。なければアカウントを回復できません。';

  @override
  String seedPhraseError(String error) {
    return 'エラー：$error';
  }

  @override
  String get seedPhraseCopied => 'シードフレーズをクリップボードにコピーしました';

  @override
  String get seedPhraseConfirm => 'シードフレーズを保存しました →';

  @override
  String get currencyTitle => '通貨を選択';

  @override
  String get currencyQuestion => 'どの通貨で販売していますか？';

  @override
  String get currencyHint => '設定からいつでも変更できます。';

  @override
  String get currencyContinue => '続ける';

  @override
  String get loginTitle => 'ログイン';

  @override
  String get loginEnterPhrase => 'シードフレーズを入力';

  @override
  String get loginPhraseHint => 'スペースで区切った12語または24語のリカバリーフレーズを入力または貼り付けてください。';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => 'クリア';

  @override
  String loginWordCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 語',
    );
    return '$_temp0';
  }

  @override
  String get loginButton => 'ログイン';

  @override
  String get loginErrorInvalidWord => '1つ以上の単語が有効なBIP39ワードではありません。';

  @override
  String get loginErrorInvalidChecksum => 'シードフレーズが無効です — チェックサムが一致しません。';

  @override
  String get loginErrorInvalidWordCount => 'シードフレーズは12語または24語でなければなりません。';

  @override
  String get loginErrorGeneric => 'シードフレーズが無効です。確認して再試行してください。';

  @override
  String get onboardingTitle => 'カタログを設定する';

  @override
  String get onboardingSubtitle => 'どのように始めますか？';

  @override
  String get onboardingImportTitle => '旧デバイスからインポート';

  @override
  String get onboardingImportSubtitle => 'CSVバックアップからカタログを復元';

  @override
  String get onboardingManualTitle => '手動でアイテムを設定';

  @override
  String get onboardingManualSubtitle => 'サンプルカタログを使用するか、独自のアイテムを追加';

  @override
  String onboardingImportFailed(String error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get helpTitle => 'ヘルプ＆サポート';

  @override
  String get helpFaqTitle => 'よくある質問';

  @override
  String get helpHowToPlaceOrder => '注文の方法は？';

  @override
  String get helpHowToPlaceOrderAnswer => 'ホーム画面から商品を選択して確定できます。';

  @override
  String get helpPaymentMethods => '利用可能な支払い方法は？';

  @override
  String get helpPaymentMethodsAnswer => 'クレジットカード、電子ウォレット、現金をサポートしています。';

  @override
  String get helpCancelOrder => '注文をキャンセルできますか？';

  @override
  String get helpCancelOrderAnswer => '注文確定前であれば、注文バーから削除できます。';

  @override
  String get helpContactUs => 'お問い合わせ';

  @override
  String get helpEmailSupport => 'メールサポート';

  @override
  String get helpWhatsAppSupport => 'WhatsAppサポート';

  @override
  String get helpCallCenter => 'コールセンター';

  @override
  String get dataTitle => 'バックアップと復元';

  @override
  String get dataBackupSection => 'バックアップ';

  @override
  String get dataBackupTitle => 'カタログをバックアップ';

  @override
  String get dataBackupSubtitle => 'すべてのアイテムとカテゴリをCSVファイルに保存';

  @override
  String get dataRestoreSection => '復元';

  @override
  String get dataRestoreTitle => 'バックアップから復元';

  @override
  String get dataRestoreSubtitle => '保存済みのCSVファイルからアイテムを読み込む';

  @override
  String get dataRestoreNote => '注意：バックアップ内の同じIDのアイテムは既存のものを上書きします。';

  @override
  String get dataBackupSuccess => 'バックアップが正常に保存されました';

  @override
  String dataBackupFailed(String error) {
    return 'バックアップに失敗しました：$error';
  }

  @override
  String dataRestoreFailed(String error) {
    return '復元に失敗しました：$error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '$count件のアイテムが正常に復元されました';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsDisplayCurrency => '表示通貨';

  @override
  String get settingsDynamicPricing => 'ダイナミックプライシング';

  @override
  String get settingsDynamicPricingUnavailable => 'KAS表示通貨では利用できません';

  @override
  String get settingsDynamicPricingSubtitle => '60秒ごとに価格を自動更新';

  @override
  String get settingsAppInfo => 'アプリ情報';

  @override
  String get settingsAppVersion => 'アプリバージョン';

  @override
  String get settingsTermsOfService => '利用規約';

  @override
  String get themeTitle => 'テーマ設定';

  @override
  String get themeMode => 'テーマモード';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get themePrimaryColor => 'プライマリカラー';

  @override
  String get themeResetToDefault => 'デフォルトにリセット';

  @override
  String get themePreview => 'プレビュー';

  @override
  String get themePreviewSampleCard => 'サンプルカード';

  @override
  String get themePreviewSampleCardBody => '選択した色でテーマがどのように見えるかです。';

  @override
  String get themePreviewFilledButton => '塗りつぶしボタン';

  @override
  String get themePreviewOutlinedButton => 'アウトラインボタン';

  @override
  String get themePreviewTextButton => 'テキストボタン';

  @override
  String get networkTitle => 'ネットワーク';

  @override
  String get networkActiveNetwork => 'アクティブネットワーク';

  @override
  String get networkMainnet => 'メインネット';

  @override
  String get networkMainnetSubtitle => '本番Kaspaネットワーク';

  @override
  String get networkTestnet10 => 'テストネット-10';

  @override
  String get networkTestnet10Subtitle => 'テストネットワーク・TKASを使用';

  @override
  String get networkNodeStatus => 'ノードステータス';

  @override
  String get networkConnected => '接続済み';

  @override
  String get networkDisconnected => '切断';

  @override
  String get networkVirtualDaaScore => '仮想DAAスコア';

  @override
  String get networkCustomNodeUrls => 'カスタムノードURL';

  @override
  String get networkMainnetUrl => 'メインネットWebSocket URL';

  @override
  String get networkTestnet10Url => 'テストネット-10 WebSocket URL';

  @override
  String get networkSave => '保存';

  @override
  String get networkSaved => '保存しました — 再接続中…';

  @override
  String get networkRequired => '必須';

  @override
  String get networkAutoMode => '自動（リゾルバー）';

  @override
  String get networkCustomMode => 'カスタムノード';

  @override
  String get networkResolving => '最適なノードを検索中…';

  @override
  String networkResolvedNode(String url) {
    return 'ノード: $url';
  }

  @override
  String get networkResetToAuto => '自動にリセット';

  @override
  String get networkResetToAutoSnackbar => '自動にリセット — 再接続中…';

  @override
  String get donateTitle => '寄付';

  @override
  String get donateSupportDeveloper => '開発者をサポート';

  @override
  String get donateSupportDeveloperBody =>
      'Kaswayは無料でオープンソースです。役立つと感じたら、開発者への一時的なKAS寄付をご検討ください。';

  @override
  String get donateAddressCopied => 'アドレスをコピーしました';

  @override
  String get donateDonateNow => '今すぐ寄付';

  @override
  String get donateKas => 'KASを寄付';

  @override
  String donateRecipient(String address) {
    return '受取人：$address';
  }

  @override
  String donateAvailable(String amount) {
    return '利用可能：$amount KAS';
  }

  @override
  String get donateAmountLabel => '金額（KAS）';

  @override
  String get donateAmountRequired => '金額は必須です';

  @override
  String get donateAmountInvalid => '有効な金額を入力してください';

  @override
  String get donateSend => '送信';

  @override
  String donateThankYou(String txId) {
    return 'ありがとうございます！TX：$txId';
  }

  @override
  String get donateTransactionFailed => 'トランザクション失敗';

  @override
  String get donateAutoPerPayment => '支払いごとの自動寄付';

  @override
  String get donateAutoPerPaymentBody =>
      '各顧客支払いの確認後、開発者に少額のKASを自動送信します（メインネットのみ）。';

  @override
  String get donateEnableAuto => '自動寄付を有効化';

  @override
  String get donatePercentage => '取引の割合';

  @override
  String get donateFixed => '固定金額（KAS）';

  @override
  String get donatePercentageLabel => '割合（%）';

  @override
  String get donateAmountKasLabel => '金額（KAS）';

  @override
  String get donateSaveSettings => '保存';

  @override
  String get donateInvalidValue => '0より大きい有効な値を入力してください';

  @override
  String get donateSettingsSaved => '自動寄付設定を保存しました';

  @override
  String get donateHistory => '寄付履歴';

  @override
  String get donateNoDonations => 'まだ寄付はありません';

  @override
  String get donateTxIdCopied => 'TX IDをコピーしました';

  @override
  String get donateNoWallet => 'ウォレットのニーモニックが見つかりません。まずウォレットを設定してください。';

  @override
  String get displayTitle => '外部ディスプレイ';

  @override
  String get displaySubtitle => '支払いQR画面を接続されたディスプレイにミラーリングします。';

  @override
  String get displayNotSupported => 'AndroidとiOSのみ対応しています。';

  @override
  String get displayAvailableDisplays => '利用可能なディスプレイ';

  @override
  String get displayScan => 'スキャン';

  @override
  String get displayNoDisplays => 'ディスプレイが見つかりません。スキャンをタップして検索してください。';

  @override
  String get displayConnect => '接続';

  @override
  String get displayStatus => 'ステータス';

  @override
  String displayConnected(String name) {
    return '接続済み：$name';
  }

  @override
  String get displayNotConnected => '未接続';

  @override
  String get displayReconnect => '再接続';

  @override
  String get displayDisconnect => '切断';

  @override
  String get tableLayoutTitle => 'テーブルレイアウト';

  @override
  String get tableLayoutSave => '保存';

  @override
  String get tableLayoutFeatureToggle => 'テーブルレイアウト';

  @override
  String get tableLayoutAddTable => 'テーブルを追加';

  @override
  String get tableLayoutRotateCcw => '反時計回りに回転';

  @override
  String get tableLayoutRotateCw => '時計回りに回転';

  @override
  String get tableLayoutDeleteGroup => 'グループを削除';

  @override
  String get tableLayoutDeleteTable => 'テーブルを削除';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return 'グループ全体（$countテーブル）を削除しますか？';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return 'テーブル「$label」を削除しますか？';
  }

  @override
  String get tableLayoutCancel => 'キャンセル';

  @override
  String get tableLayoutDelete => '削除';

  @override
  String get tableLayoutUnsavedChanges => '未保存の変更';

  @override
  String get tableLayoutUnsavedChangesContent => '未保存の変更があります。破棄して終了しますか？';

  @override
  String get tableLayoutKeepEditing => '編集を続ける';

  @override
  String get tableLayoutDiscard => '破棄';

  @override
  String get tableLayoutSingleTables => 'シングルテーブル';

  @override
  String get tableLayoutTableGroups => 'テーブルグループ';

  @override
  String get tableLayoutTableGroupsBody => 'プリセット配置で複数のテーブルを一度に配置します。';

  @override
  String get tableLayoutAddTableSheet => 'テーブルを追加';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return '・$seats席';
  }

  @override
  String get tableLayoutRename => '名前を変更';

  @override
  String get tableLayoutSaveName => '保存';

  @override
  String get orderHistoryTitle => '注文履歴';

  @override
  String get orderHistoryNoOrders => 'まだ注文はありません';

  @override
  String get orderHistoryTodayOrders => '本日の注文';

  @override
  String get orderHistoryTodayRevenue => '本日の売上';

  @override
  String get orderHistoryToday => '今日';

  @override
  String get orderHistoryYesterday => '昨日';

  @override
  String get orderHistoryNoItemDetails => 'アイテム詳細が記録されていません';

  @override
  String get orderHistoryTotal => '合計';

  @override
  String get orderHistoryViewOnExplorer => 'エクスプローラーで表示';

  @override
  String orderHistoryTable(String label) {
    return 'テーブル $label';
  }

  @override
  String get withdrawalHistoryTitle => '出金履歴';

  @override
  String get withdrawalHistoryNoWithdrawals => 'まだ出金はありません';

  @override
  String get withdrawalHistoryCopyTxId => 'TX IDをコピー';

  @override
  String get withdrawalHistoryViewOnExplorer => 'エクスプローラーで表示';

  @override
  String get withdrawalHistoryTxIdCopied => 'TX IDをコピーしました';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileSelectSection => 'セクションを選択';

  @override
  String get profileOrderHistory => '注文履歴';

  @override
  String get profileManageItem => 'アイテム管理';

  @override
  String get profileTableLayout => 'テーブルレイアウト';

  @override
  String get profileBackupRestore => 'バックアップと復元';

  @override
  String get profileNetworkNode => 'ネットワークとノード';

  @override
  String get profileDisplay => 'ディスプレイ';

  @override
  String get profileThemeSettings => 'テーマ設定';

  @override
  String get profileSettings => '設定';

  @override
  String get profileDonate => '寄付';

  @override
  String get profileLogout => 'ログアウト';

  @override
  String get profileLogoutContent => 'ログアウトしてもよろしいですか？';

  @override
  String get profileCancel => 'キャンセル';

  @override
  String get profileKaspaAddress => 'Kaspaアドレス';

  @override
  String get profileNoWallet => 'ウォレットが設定されていません';

  @override
  String get profileCopyAddress => 'アドレスをコピー';

  @override
  String get profileViewInExplorer => 'エクスプローラーで表示';

  @override
  String get profileBalance => '残高';

  @override
  String get profileWithdraw => '出金';

  @override
  String get profileAddressCopied => 'アドレスをコピーしました';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return '$kasSymbolを出金';
  }

  @override
  String get profileDestinationAddress => '送金先Kaspaアドレス';

  @override
  String get profileAddressRequired => 'アドレスは必須です';

  @override
  String profileAddressInvalid(String hrp) {
    return '有効な$hrp:アドレスを入力してください';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return '金額（$kasSymbol）';
  }

  @override
  String get profileAmountRequired => '金額は必須です';

  @override
  String get profileAmountInvalid => '有効な金額を入力してください';

  @override
  String get profileSend => '送信';

  @override
  String get profileTransactionFailed => 'トランザクション失敗';

  @override
  String get profileWithdrawNoWallet =>
      'ウォレットのニーモニックが見つかりません。まずウォレットを設定してください。';

  @override
  String get profileWithdrawalSuccessTitle => '出金完了！';

  @override
  String get profileWithdrawalSuccessSubtitle => 'KASが正常に送信されました。';

  @override
  String get profileMax => '最大';

  @override
  String get homeFailedToLoad => '商品の読み込みに失敗しました';

  @override
  String get homeNoProducts => '商品が見つかりません';

  @override
  String get homeConfirmSelection => '選択を確定';

  @override
  String get homeClearOrderTitle => '注文をクリアしますか？';

  @override
  String get homeClearOrderContent => '注文リストからすべてのアイテムを削除してもよろしいですか？';

  @override
  String get homeClearOrder => '注文をクリア';

  @override
  String get homeCancel => 'キャンセル';

  @override
  String get homeTestnetBanner => 'テストネットモードで使用中';

  @override
  String get paymentTitle => '支払い';

  @override
  String get paymentNoWallet => 'ウォレットが設定されていません。まずウォレットを設定してください。';

  @override
  String get paymentFetchingRates => '為替レートを取得中…';

  @override
  String get paymentPleaseWait => 'しばらくお待ちください。';

  @override
  String get paymentRetry => '再試行';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '$received/$total $kasSymbol 受信済み';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return '$kasSymbolのみを送信し、上記の金額を正確に送ってください。他の資産や金額が異なる場合、資金が失われる可能性があります。';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return '自動寄付有効 — 支払い確認後、$amount $kasSymbolが開発者に送信されます。';
  }

  @override
  String get paymentOrderList => '注文リスト';

  @override
  String get tableSelectTitle => 'テーブルを選択';

  @override
  String get tableSelectMarkAsServed => '提供済みにする';

  @override
  String get tableSelectFreeTable => 'テーブルを空きにする';

  @override
  String tableSelectFreeTableContent(String label) {
    return 'テーブル$labelを空きにしますか？占有状態が解除されます。';
  }

  @override
  String get tableSelectFreeTableTitle => 'テーブルを空きにする';

  @override
  String tableSelectTableLabel(String label) {
    return 'テーブル $label';
  }

  @override
  String get tableSelectNoTables => 'テーブルが設定されていません';

  @override
  String get tableSelectNoTablesBody => 'プロフィール > テーブルレイアウトでフロアプランを設定してください。';

  @override
  String get tableSelectGoToLayout => 'テーブルレイアウトへ';

  @override
  String get paymentSuccessTitle => '支払い完了！';

  @override
  String get paymentSuccessSubtitle => 'トランザクションが正常に処理されました。';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return '$count秒後にリダイレクトされます$plural...';
  }

  @override
  String get itemManageTitle => 'アイテム管理';

  @override
  String get itemNoCategoriesYet => 'カテゴリがまだありません';

  @override
  String get itemCreateCategory => 'カテゴリを作成';

  @override
  String get itemNoItemsInCategory => 'このカテゴリにアイテムはありません';

  @override
  String get itemDeleteProductTitle => '商品を削除しますか？';

  @override
  String itemDeleteProductInCart(String name) {
    return '「$name」はアクティブな注文にあります。削除するとカートからも削除されます。';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return '「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get itemDeleteCancel => 'キャンセル';

  @override
  String get itemDeleteConfirm => '削除';

  @override
  String get itemDone => '完了';

  @override
  String itemAdditionCount(int count, String plural) {
    return '・$count種類の追加$plural';
  }

  @override
  String get itemFormEditTitle => '商品を編集';

  @override
  String get itemFormAddTitle => '商品を追加';

  @override
  String get itemFormSave => '保存';

  @override
  String get itemFormProductName => '商品名';

  @override
  String get itemFormRequired => '必須';

  @override
  String get itemFormInvalidNumber => '有効な数字を入力してください';

  @override
  String get itemFormCategory => 'カテゴリ';

  @override
  String get itemFormDescription => '説明（任意）';

  @override
  String get itemFormAdditions => '追加オプション';

  @override
  String get itemFormAddAddition => '追加オプションを追加';

  @override
  String get itemFormAdditionFree => '無料';

  @override
  String get itemFormEditAdditionTitle => '追加オプションを編集';

  @override
  String get itemFormNewAdditionTitle => '新しい追加オプション';

  @override
  String get itemFormAdditionName => '追加オプション名';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return '追加料金（$code、0=無料）';
  }

  @override
  String get itemFormCancel => 'キャンセル';

  @override
  String get categoryManageTitle => 'カテゴリ';

  @override
  String get categoryAddCategory => 'カテゴリを追加';

  @override
  String get categoryNewCategory => '新しいカテゴリ';

  @override
  String get categoryNameLabel => 'カテゴリ名';

  @override
  String get categoryAdd => '追加';

  @override
  String get categoryCancel => 'キャンセル';

  @override
  String get categoryRenameTitle => 'カテゴリ名を変更';

  @override
  String get categoryRename => '名前を変更';

  @override
  String get categoryDeleteTitle => 'カテゴリを削除しますか？';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '「$name」には$count件のアイテム$pluralがあり、完全に削除されます。この操作は元に戻せません。';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return '「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get categoryDelete => '削除';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count件$plural';
  }

  @override
  String get itemManageCreate => '作成';
}
