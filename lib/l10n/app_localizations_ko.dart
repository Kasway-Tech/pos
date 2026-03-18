// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get language => '언어';

  @override
  String get authTagline => '당신의 크립토 POS,\n당신이 지킵니다.';

  @override
  String get authCreateAccount => '계정 만들기';

  @override
  String get authLoginWithSeedPhrase => '시드 구문으로 로그인';

  @override
  String get eulaTitle => '이용약관';

  @override
  String get eulaLastUpdated => '최종 업데이트: 2026년 3월';

  @override
  String get eulaMainTitle => '최종 사용자 라이선스 계약';

  @override
  String get eulaSection1Title => '1. 약관 동의';

  @override
  String get eulaSection1Body =>
      'Kasway(\"앱\")를 사용함으로써 귀하는 이 이용약관에 구속되는 데 동의합니다. 동의하지 않는 경우 앱을 사용하지 마십시오.';

  @override
  String get eulaSection2Title => '2. 시드 구문 및 보안';

  @override
  String get eulaSection2Body =>
      '앱은 귀하의 기기에 로컬로 저장되는 BIP39 시드 구문을 생성합니다. 시드 구문의 안전한 보관은 전적으로 귀하의 책임입니다. Kasway는 시드 구문을 저장, 전송하거나 접근하지 않습니다. 시드 구문을 분실하면 계정 접근이 영구적으로 불가능해집니다 — 복구 방법이 없습니다.';

  @override
  String get eulaSection3Title => '3. 금융 조언 면책';

  @override
  String get eulaSection3Body =>
      '앱의 어떠한 내용도 금융, 투자 또는 법적 조언을 구성하지 않습니다. 암호화폐 가치는 변동성이 큽니다. 암호화폐 거래와 관련된 모든 위험은 귀하가 부담합니다.';

  @override
  String get eulaSection4Title => '4. 데이터 및 개인정보 보호';

  @override
  String get eulaSection4Body =>
      '모든 카탈로그 및 거래 데이터는 귀하의 기기에 로컬로 저장됩니다. 앱은 CoinGecko(제3자 서비스)에서 실시간 환율을 가져옵니다. Kasway는 개인 식별 정보를 수집하거나 전송하지 않습니다.';

  @override
  String get eulaSection5Title => '5. 책임 제한';

  @override
  String get eulaSection5Body =>
      '법률이 허용하는 최대 범위 내에서 Kasway 및 개발자는 자금 손실, 데이터 손실, 시드 구문 손실을 포함하되 이에 국한되지 않는 앱 사용으로 인한 손실이나 피해에 대해 책임을 지지 않습니다.';

  @override
  String get eulaSection6Title => '6. 약관 변경';

  @override
  String get eulaSection6Body =>
      '당사는 언제든지 이 약관을 수정할 권리를 보유합니다. 변경 후 앱을 계속 사용하면 새로운 약관에 동의한 것으로 간주됩니다.';

  @override
  String get eulaSection7Title => '7. 준거법';

  @override
  String get eulaSection7Body =>
      '이 약관은 해당 법률에 의해 규율됩니다. 모든 분쟁은 Kasway가 설립된 관할권에서 해결됩니다.';

  @override
  String get eulaAgreeLabel => '이용약관 및 개인정보 처리방침을 읽고 동의합니다.';

  @override
  String get eulaContinue => '계속';

  @override
  String get seedPhraseTitle => '시드 구문';

  @override
  String get seedPhraseCopyTooltip => '클립보드에 복사';

  @override
  String get seedPhraseWarning => '이 단어들을 적어 두세요. 없으면 계정을 복구할 수 없습니다.';

  @override
  String seedPhraseError(String error) {
    return '오류: $error';
  }

  @override
  String get seedPhraseCopied => '시드 구문이 클립보드에 복사되었습니다';

  @override
  String get seedPhraseConfirm => '시드 구문을 저장했습니다 →';

  @override
  String get currencyTitle => '통화 선택';

  @override
  String get currencyQuestion => '어떤 통화로 판매하시나요?';

  @override
  String get currencyHint => '설정에서 언제든지 변경할 수 있습니다.';

  @override
  String get currencyContinue => '계속';

  @override
  String get loginTitle => '로그인';

  @override
  String get loginEnterPhrase => '시드 구문 입력';

  @override
  String get loginPhraseHint => '12개 또는 24개 단어의 복구 구문을 공백으로 구분하여 입력하거나 붙여넣으세요.';

  @override
  String get loginHintText => 'word1 word2 word3 …';

  @override
  String get loginClear => '지우기';

  @override
  String loginWordCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 단어',
    );
    return '$_temp0';
  }

  @override
  String get loginButton => '로그인';

  @override
  String get loginErrorInvalidWord => '하나 이상의 단어가 유효한 BIP39 단어가 아닙니다.';

  @override
  String get loginErrorInvalidChecksum => '시드 구문이 유효하지 않습니다 — 체크섬이 일치하지 않습니다.';

  @override
  String get loginErrorInvalidWordCount => '시드 구문은 12개 또는 24개 단어여야 합니다.';

  @override
  String get loginErrorGeneric => '시드 구문이 유효하지 않습니다. 확인 후 다시 시도하세요.';

  @override
  String get onboardingTitle => '카탈로그 설정';

  @override
  String get onboardingSubtitle => '어떻게 시작하시겠습니까?';

  @override
  String get onboardingImportTitle => '이전 기기에서 가져오기';

  @override
  String get onboardingImportSubtitle => 'CSV 백업에서 카탈로그 복원';

  @override
  String get onboardingManualTitle => '수동으로 항목 설정';

  @override
  String get onboardingManualSubtitle => '샘플 카탈로그를 사용하거나 직접 항목 추가';

  @override
  String onboardingImportFailed(String error) {
    return '가져오기 실패: $error';
  }
}
