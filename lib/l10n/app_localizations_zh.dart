// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language => '语言';

  @override
  String get authTagline => '您的加密POS，\n由您守护。';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authLoginWithSeedPhrase => '使用助记词登录';

  @override
  String get eulaTitle => '条款与条件';

  @override
  String get eulaLastUpdated => '最后更新：2026年3月';

  @override
  String get eulaMainTitle => '最终用户许可协议';

  @override
  String get eulaSection1Title => '1. 接受条款';

  @override
  String get eulaSection1Body => '使用Kasway（本应用），即表示您同意受本条款与条件的约束。如不同意，请勿使用本应用。';

  @override
  String get eulaSection2Title => '2. 助记词与安全';

  @override
  String get eulaSection2Body =>
      '本应用会生成一个BIP39助记词，存储在您的设备本地。您须独自负责保管好您的助记词。Kasway不会存储、传输或访问您的助记词。丢失助记词意味着永久失去账户访问权——没有任何恢复方式。';

  @override
  String get eulaSection3Title => '3. 非财务建议';

  @override
  String get eulaSection3Body =>
      '本应用中的任何内容均不构成财务、投资或法律建议。加密货币价值具有高度波动性。您须承担与加密货币交易相关的所有风险。';

  @override
  String get eulaSection4Title => '4. 数据与隐私';

  @override
  String get eulaSection4Body =>
      '所有目录和交易数据均存储在您的设备本地。本应用从CoinGecko（第三方服务）获取实时汇率。Kasway不收集或传输任何个人身份信息。';

  @override
  String get eulaSection5Title => '5. 责任限制';

  @override
  String get eulaSection5Body =>
      '在法律允许的最大范围内，Kasway及其开发者不对因使用本应用而产生的任何损失或损害承担责任，包括但不限于资金损失、数据丢失或助记词丢失。';

  @override
  String get eulaSection6Title => '6. 条款变更';

  @override
  String get eulaSection6Body => '我们保留随时修改本条款的权利。在条款变更后继续使用本应用即表示接受新条款。';

  @override
  String get eulaSection7Title => '7. 适用法律';

  @override
  String get eulaSection7Body => '本条款受适用法律管辖。任何争议应在Kasway注册所在地的司法管辖区解决。';

  @override
  String get eulaAgreeLabel => '我已阅读并同意条款与条件及隐私政策。';

  @override
  String get eulaContinue => '继续';

  @override
  String get seedPhraseTitle => '助记词';

  @override
  String get seedPhraseCopyTooltip => '复制到剪贴板';

  @override
  String get seedPhraseWarning => '请抄写这些单词。没有它们，您将无法恢复账户。';

  @override
  String seedPhraseError(String error) {
    return '错误：$error';
  }

  @override
  String get seedPhraseCopied => '助记词已复制到剪贴板';

  @override
  String get seedPhraseConfirm => '我已保存助记词 →';

  @override
  String get currencyTitle => '选择货币';

  @override
  String get currencyQuestion => '您用什么货币进行销售？';

  @override
  String get currencyHint => '您可以随时在设置中更改。';

  @override
  String get currencyContinue => '继续';

  @override
  String get loginTitle => '登录';

  @override
  String get loginEnterPhrase => '输入您的助记词';

  @override
  String get loginPhraseHint => '请输入或粘贴您的12或24个助记词，用空格分隔。';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => '清除';

  @override
  String loginWordCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 个字',
    );
    return '$_temp0';
  }

  @override
  String get loginButton => '登录';

  @override
  String get loginErrorInvalidWord => '一个或多个单词不是有效的BIP39词。';

  @override
  String get loginErrorInvalidChecksum => '助记词无效——校验和不匹配。';

  @override
  String get loginErrorInvalidWordCount => '助记词必须为12或24个单词。';

  @override
  String get loginErrorGeneric => '助记词无效，请检查后重试。';

  @override
  String get onboardingTitle => '设置您的产品目录';

  @override
  String get onboardingSubtitle => '您希望如何开始？';

  @override
  String get onboardingImportTitle => '从旧设备导入';

  @override
  String get onboardingImportSubtitle => '从CSV备份恢复您的目录';

  @override
  String get onboardingManualTitle => '手动设置商品';

  @override
  String get onboardingManualSubtitle => '使用示例目录或添加您自己的商品';

  @override
  String onboardingImportFailed(String error) {
    return '导入失败：$error';
  }
}
