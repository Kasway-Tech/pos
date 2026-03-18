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
}
