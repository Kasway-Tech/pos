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

  @override
  String get helpTitle => '도움말 및 지원';

  @override
  String get helpFaqTitle => '자주 묻는 질문';

  @override
  String get helpHowToPlaceOrder => '주문 방법은?';

  @override
  String get helpHowToPlaceOrderAnswer => '홈 화면에서 제품을 선택하고 확정하면 됩니다.';

  @override
  String get helpPaymentMethods => '사용 가능한 결제 방법은?';

  @override
  String get helpPaymentMethodsAnswer => '신용카드, 전자지갑, 현금을 지원합니다.';

  @override
  String get helpCancelOrder => '주문을 취소할 수 있나요?';

  @override
  String get helpCancelOrderAnswer => '확정 전 주문 바에서 항목을 삭제할 수 있습니다.';

  @override
  String get helpContactUs => '문의하기';

  @override
  String get helpEmailSupport => '이메일 지원';

  @override
  String get helpWhatsAppSupport => 'WhatsApp 지원';

  @override
  String get helpCallCenter => '콜센터';

  @override
  String get dataTitle => '백업 및 복원';

  @override
  String get dataBackupSection => '백업';

  @override
  String get dataBackupTitle => '카탈로그 백업';

  @override
  String get dataBackupSubtitle => '모든 항목 및 카테고리를 CSV 파일로 저장';

  @override
  String get dataRestoreSection => '복원';

  @override
  String get dataRestoreTitle => '백업에서 복원';

  @override
  String get dataRestoreSubtitle => '저장된 CSV 파일에서 항목 불러오기';

  @override
  String get dataRestoreNote => '참고: 백업에서 동일한 ID를 가진 항목은 기존 항목을 덮어씁니다.';

  @override
  String get dataBackupSuccess => '백업이 성공적으로 저장되었습니다';

  @override
  String dataBackupFailed(String error) {
    return '백업 실패: $error';
  }

  @override
  String dataRestoreFailed(String error) {
    return '복원 실패: $error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '$count개 항목이 성공적으로 복원되었습니다';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsDisplayCurrency => '표시 통화';

  @override
  String get settingsDynamicPricing => '동적 가격';

  @override
  String get settingsDynamicPricingUnavailable => 'KAS 표시 통화에는 사용할 수 없습니다';

  @override
  String get settingsDynamicPricingSubtitle => '60초마다 가격 자동 업데이트';

  @override
  String get settingsAppInfo => '앱 정보';

  @override
  String get settingsAppVersion => '앱 버전';

  @override
  String get settingsTermsOfService => '서비스 약관';

  @override
  String get themeTitle => '테마 설정';

  @override
  String get themeMode => '테마 모드';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get themePrimaryColor => '기본 색상';

  @override
  String get themeResetToDefault => '기본값으로 재설정';

  @override
  String get themePreview => '미리보기';

  @override
  String get themePreviewSampleCard => '샘플 카드';

  @override
  String get themePreviewSampleCardBody => '선택한 색상으로 테마가 어떻게 보이는지입니다.';

  @override
  String get themePreviewFilledButton => '채운 버튼';

  @override
  String get themePreviewOutlinedButton => '외곽선 버튼';

  @override
  String get themePreviewTextButton => '텍스트 버튼';

  @override
  String get networkTitle => '네트워크';

  @override
  String get networkActiveNetwork => '활성 네트워크';

  @override
  String get networkMainnet => '메인넷';

  @override
  String get networkMainnetSubtitle => '운영 Kaspa 네트워크';

  @override
  String get networkTestnet10 => '테스트넷-10';

  @override
  String get networkTestnet10Subtitle => '테스트 네트워크 · TKAS 사용';

  @override
  String get networkNodeStatus => '노드 상태';

  @override
  String get networkConnected => '연결됨';

  @override
  String get networkDisconnected => '연결 끊김';

  @override
  String get networkVirtualDaaScore => '가상 DAA 점수';

  @override
  String get networkCustomNodeUrls => '사용자 정의 노드 URL';

  @override
  String get networkMainnetUrl => '메인넷 WebSocket URL';

  @override
  String get networkTestnet10Url => '테스트넷-10 WebSocket URL';

  @override
  String get networkSave => '저장';

  @override
  String get networkSaved => '저장됨 — 재연결 중…';

  @override
  String get networkRequired => '필수';

  @override
  String get networkAutoMode => '자동 (리졸버)';

  @override
  String get networkCustomMode => '사용자 정의 노드';

  @override
  String get networkResolving => '최적 노드 검색 중…';

  @override
  String networkResolvedNode(String url) {
    return '노드: $url';
  }

  @override
  String get networkResetToAuto => '자동으로 초기화';

  @override
  String get networkResetToAutoSnackbar => '자동으로 초기화 — 재연결 중…';

  @override
  String get donateTitle => '기부';

  @override
  String get donateSupportDeveloper => '개발자 지원';

  @override
  String get donateSupportDeveloperBody =>
      'Kasway는 무료 오픈소스입니다. 유용하다면 개발자에게 일회성 KAS 기부를 고려해 주세요.';

  @override
  String get donateAddressCopied => '주소가 복사되었습니다';

  @override
  String get donateDonateNow => '지금 기부';

  @override
  String get donateKas => 'KAS 기부';

  @override
  String donateRecipient(String address) {
    return '수신자: $address';
  }

  @override
  String donateAvailable(String amount) {
    return '사용 가능: $amount KAS';
  }

  @override
  String get donateAmountLabel => '금액 (KAS)';

  @override
  String get donateAmountRequired => '금액은 필수입니다';

  @override
  String get donateAmountInvalid => '유효한 금액을 입력하세요';

  @override
  String get donateSend => '전송';

  @override
  String donateThankYou(String txId) {
    return '감사합니다! TX: $txId';
  }

  @override
  String get donateTransactionFailed => '트랜잭션 실패';

  @override
  String get donateAutoPerPayment => '결제당 자동 기부';

  @override
  String get donateAutoPerPaymentBody =>
      '각 고객 결제 확인 후 개발자에게 소액의 KAS를 자동으로 전송합니다 (메인넷만 해당).';

  @override
  String get donateEnableAuto => '자동 기부 활성화';

  @override
  String get donatePercentage => '트랜잭션 비율';

  @override
  String get donateFixed => '고정 금액 (KAS)';

  @override
  String get donatePercentageLabel => '비율 (%)';

  @override
  String get donateAmountKasLabel => '금액 (KAS)';

  @override
  String get donateSaveSettings => '저장';

  @override
  String get donateInvalidValue => '0보다 큰 유효한 값을 입력하세요';

  @override
  String get donateSettingsSaved => '자동 기부 설정이 저장되었습니다';

  @override
  String get donateHistory => '기부 내역';

  @override
  String get donateNoDonations => '아직 기부가 없습니다';

  @override
  String get donateTxIdCopied => 'TX ID가 복사되었습니다';

  @override
  String get donateNoWallet => '지갑 니모닉을 찾을 수 없습니다. 먼저 지갑을 설정하세요.';

  @override
  String get displayTitle => '외부 디스플레이';

  @override
  String get displaySubtitle => '결제 QR 화면을 연결된 디스플레이에 미러링합니다.';

  @override
  String get displayNotSupported => 'Android 및 iOS에서만 사용 가능합니다.';

  @override
  String get displayAvailableDisplays => '사용 가능한 디스플레이';

  @override
  String get displayScan => '스캔';

  @override
  String get displayNoDisplays => '디스플레이를 찾을 수 없습니다. 스캔을 탭하여 검색하세요.';

  @override
  String get displayConnect => '연결';

  @override
  String get displayStatus => '상태';

  @override
  String displayConnected(String name) {
    return '연결됨: $name';
  }

  @override
  String get displayNotConnected => '연결되지 않음';

  @override
  String get displayReconnect => '재연결';

  @override
  String get displayDisconnect => '연결 해제';

  @override
  String get tableLayoutTitle => '테이블 레이아웃';

  @override
  String get tableLayoutSave => '저장';

  @override
  String get tableLayoutFeatureToggle => '테이블 레이아웃';

  @override
  String get tableLayoutAddTable => '테이블 추가';

  @override
  String get tableLayoutRotateCcw => '반시계 방향으로 회전';

  @override
  String get tableLayoutRotateCw => '시계 방향으로 회전';

  @override
  String get tableLayoutDeleteGroup => '그룹 삭제';

  @override
  String get tableLayoutDeleteTable => '테이블 삭제';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return '그룹 전체($count개 테이블)를 삭제하시겠습니까?';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return '\"$label\" 테이블을 삭제하시겠습니까?';
  }

  @override
  String get tableLayoutCancel => '취소';

  @override
  String get tableLayoutDelete => '삭제';

  @override
  String get tableLayoutUnsavedChanges => '저장되지 않은 변경사항';

  @override
  String get tableLayoutUnsavedChangesContent =>
      '저장되지 않은 변경사항이 있습니다. 버리고 나가시겠습니까?';

  @override
  String get tableLayoutKeepEditing => '계속 편집';

  @override
  String get tableLayoutDiscard => '버리기';

  @override
  String get tableLayoutSingleTables => '단일 테이블';

  @override
  String get tableLayoutTableGroups => '테이블 그룹';

  @override
  String get tableLayoutTableGroupsBody => '프리셋 배열로 여러 테이블을 한번에 배치합니다.';

  @override
  String get tableLayoutAddTableSheet => '테이블 추가';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return ' · $seats석';
  }

  @override
  String get tableLayoutRename => '이름 변경';

  @override
  String get tableLayoutSaveName => '저장';

  @override
  String get orderHistoryTitle => '주문 내역';

  @override
  String get orderHistoryNoOrders => '아직 주문이 없습니다';

  @override
  String get orderHistoryTodayOrders => '오늘의 주문';

  @override
  String get orderHistoryTodayRevenue => '오늘의 매출';

  @override
  String get orderHistoryToday => '오늘';

  @override
  String get orderHistoryYesterday => '어제';

  @override
  String get orderHistoryNoItemDetails => '항목 세부 정보가 기록되지 않았습니다';

  @override
  String get orderHistoryTotal => '합계';

  @override
  String get orderHistoryViewOnExplorer => '익스플로러에서 보기';

  @override
  String orderHistoryTable(String label) {
    return '테이블 $label';
  }

  @override
  String get withdrawalHistoryTitle => '출금 내역';

  @override
  String get withdrawalHistoryNoWithdrawals => '아직 출금이 없습니다';

  @override
  String get withdrawalHistoryCopyTxId => 'TX ID 복사';

  @override
  String get withdrawalHistoryViewOnExplorer => '익스플로러에서 보기';

  @override
  String get withdrawalHistoryTxIdCopied => 'TX ID가 복사되었습니다';

  @override
  String get profileTitle => '프로필';

  @override
  String get profileSelectSection => '섹션 선택';

  @override
  String get profileOrderHistory => '주문 내역';

  @override
  String get profileManageItem => '항목 관리';

  @override
  String get profileTableLayout => '테이블 레이아웃';

  @override
  String get profileBackupRestore => '백업 및 복원';

  @override
  String get profileNetworkNode => '네트워크 및 노드';

  @override
  String get profileDisplay => '디스플레이';

  @override
  String get profileThemeSettings => '테마 설정';

  @override
  String get profileSettings => '설정';

  @override
  String get profileDonate => '기부';

  @override
  String get profileLogout => '로그아웃';

  @override
  String get profileLogoutContent => '로그아웃하시겠습니까?';

  @override
  String get profileCancel => '취소';

  @override
  String get profileKaspaAddress => 'Kaspa 주소';

  @override
  String get profileNoWallet => '지갑이 설정되지 않았습니다';

  @override
  String get profileCopyAddress => '주소 복사';

  @override
  String get profileViewInExplorer => '익스플로러에서 보기';

  @override
  String get profileBalance => '잔액';

  @override
  String get profileWithdraw => '출금';

  @override
  String get profileAddressCopied => '주소가 복사되었습니다';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return '$kasSymbol 출금';
  }

  @override
  String get profileDestinationAddress => '목적지 Kaspa 주소';

  @override
  String get profileAddressRequired => '주소는 필수입니다';

  @override
  String profileAddressInvalid(String hrp) {
    return '유효한 $hrp: 주소여야 합니다';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return '금액 ($kasSymbol)';
  }

  @override
  String get profileAmountRequired => '금액은 필수입니다';

  @override
  String get profileAmountInvalid => '유효한 금액을 입력하세요';

  @override
  String get profileSend => '전송';

  @override
  String get profileTransactionFailed => '트랜잭션 실패';

  @override
  String get profileWithdrawNoWallet => '지갑 니모닉을 찾을 수 없습니다. 먼저 지갑을 설정하세요.';

  @override
  String get profileWithdrawalSuccessTitle => '출금 성공!';

  @override
  String get profileWithdrawalSuccessSubtitle => 'KAS가 성공적으로 전송되었습니다.';

  @override
  String get profileMax => '최대';

  @override
  String get homeFailedToLoad => '제품 로드에 실패했습니다';

  @override
  String get homeNoProducts => '제품을 찾을 수 없습니다';

  @override
  String get homeConfirmSelection => '선택 확인';

  @override
  String get homeClearOrderTitle => '주문 지우기?';

  @override
  String get homeClearOrderContent => '주문 목록에서 모든 항목을 제거하시겠습니까?';

  @override
  String get homeClearOrder => '주문 지우기';

  @override
  String get homeCancel => '취소';

  @override
  String get homeTestnetBanner => '테스트넷 모드로 앱 사용 중';

  @override
  String get paymentTitle => '결제';

  @override
  String get paymentNoWallet => '지갑이 설정되지 않았습니다. 먼저 지갑을 설정하세요.';

  @override
  String get paymentFetchingRates => '환율 가져오는 중…';

  @override
  String get paymentPleaseWait => '잠시 기다려 주세요.';

  @override
  String get paymentRetry => '다시 시도';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '$received/$total $kasSymbol 수신됨';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return '$kasSymbol만 전송하고 위에 표시된 정확한 금액을 보내세요. 다른 자산이나 금액이 다를 경우 자금이 손실될 수 있습니다.';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return '자동 기부 활성화 — 결제 확인 후 $amount $kasSymbol이 개발자에게 전송됩니다.';
  }

  @override
  String get paymentOrderList => '주문 목록';

  @override
  String get tableSelectTitle => '테이블 선택';

  @override
  String get tableSelectMarkAsServed => '서빙 완료 표시';

  @override
  String get tableSelectFreeTable => '테이블 비우기';

  @override
  String tableSelectFreeTableContent(String label) {
    return '테이블 $label을 사용 가능으로 표시하시겠습니까? 점유 상태가 해제됩니다.';
  }

  @override
  String get tableSelectFreeTableTitle => '테이블 비우기';

  @override
  String tableSelectTableLabel(String label) {
    return '테이블 $label';
  }

  @override
  String get tableSelectNoTables => '구성된 테이블이 없습니다';

  @override
  String get tableSelectNoTablesBody => '프로필 > 테이블 레이아웃에서 평면도를 설정하세요.';

  @override
  String get tableSelectGoToLayout => '테이블 레이아웃으로 이동';

  @override
  String get paymentSuccessTitle => '결제 성공!';

  @override
  String get paymentSuccessSubtitle => '트랜잭션이 성공적으로 처리되었습니다.';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return '$count초 후 리디렉션됩니다$plural...';
  }

  @override
  String get itemManageTitle => '항목 관리';

  @override
  String get itemNoCategoriesYet => '카테고리가 아직 없습니다';

  @override
  String get itemCreateCategory => '카테고리 만들기';

  @override
  String get itemNoItemsInCategory => '이 카테고리에 항목이 없습니다';

  @override
  String get itemDeleteProductTitle => '제품을 삭제하시겠습니까?';

  @override
  String itemDeleteProductInCart(String name) {
    return '\"$name\"이 활성 주문에 있습니다. 삭제하면 카트에서도 제거됩니다.';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return '\"$name\"을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get itemDeleteCancel => '취소';

  @override
  String get itemDeleteConfirm => '삭제';

  @override
  String get itemDone => '완료';

  @override
  String itemAdditionCount(int count, String plural) {
    return ' · $count개 추가$plural';
  }

  @override
  String get itemFormEditTitle => '제품 편집';

  @override
  String get itemFormAddTitle => '제품 추가';

  @override
  String get itemFormSave => '저장';

  @override
  String get itemFormProductName => '제품명';

  @override
  String get itemFormRequired => '필수';

  @override
  String get itemFormInvalidNumber => '유효한 숫자를 입력하세요';

  @override
  String get itemFormCategory => '카테고리';

  @override
  String get itemFormDescription => '설명 (선택사항)';

  @override
  String get itemFormAdditions => '추가 옵션';

  @override
  String get itemFormAddAddition => '추가 옵션 추가';

  @override
  String get itemFormAdditionFree => '무료';

  @override
  String get itemFormEditAdditionTitle => '추가 옵션 편집';

  @override
  String get itemFormNewAdditionTitle => '새 추가 옵션';

  @override
  String get itemFormAdditionName => '추가 옵션명';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return '추가 가격 ($code, 0 = 무료)';
  }

  @override
  String get itemFormCancel => '취소';

  @override
  String get categoryManageTitle => '카테고리';

  @override
  String get categoryAddCategory => '카테고리 추가';

  @override
  String get categoryNewCategory => '새 카테고리';

  @override
  String get categoryNameLabel => '카테고리명';

  @override
  String get categoryAdd => '추가';

  @override
  String get categoryCancel => '취소';

  @override
  String get categoryRenameTitle => '카테고리 이름 변경';

  @override
  String get categoryRename => '이름 변경';

  @override
  String get categoryDeleteTitle => '카테고리를 삭제하시겠습니까?';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '\"$name\"에는 $count개의 항목$plural이 있으며 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return '\"$name\"을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get categoryDelete => '삭제';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count개 항목$plural';
  }

  @override
  String get itemManageCreate => '만들기';
}
