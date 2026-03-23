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
  String get currencyHint => '您的商品价格以此货币存储。结账时将据此计算KAS金额。';

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

  @override
  String get helpTitle => '帮助与支持';

  @override
  String get helpFaqTitle => '常见问题';

  @override
  String get helpHowToPlaceOrder => '如何下订单？';

  @override
  String get helpHowToPlaceOrderAnswer => '您可以从主页选择产品并确认选择。';

  @override
  String get helpPaymentMethods => '可用的支付方式？';

  @override
  String get helpPaymentMethodsAnswer => '我们支持信用卡、电子钱包和现金。';

  @override
  String get helpCancelOrder => '我可以取消订单吗？';

  @override
  String get helpCancelOrderAnswer => '在确认前可以从订单栏清除订单。';

  @override
  String get helpContactUs => '联系我们';

  @override
  String get helpEmailSupport => '邮件支持';

  @override
  String get helpWhatsAppSupport => 'WhatsApp支持';

  @override
  String get helpCallCenter => '客服中心';

  @override
  String get dataTitle => '备份与恢复';

  @override
  String get dataBackupSection => '备份';

  @override
  String get dataBackupTitle => '备份目录';

  @override
  String get dataBackupSubtitle => '将所有商品和分类保存到CSV文件';

  @override
  String get dataRestoreSection => '恢复';

  @override
  String get dataRestoreTitle => '从备份恢复';

  @override
  String get dataRestoreSubtitle => '从之前保存的CSV文件加载商品';

  @override
  String get dataRestoreNote => '注意：备份中具有相同ID的商品将覆盖现有商品。';

  @override
  String get dataBackupSuccess => '备份保存成功';

  @override
  String dataBackupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String dataRestoreFailed(String error) {
    return '恢复失败：$error';
  }

  @override
  String dataRestoreSuccess(int count) {
    return '成功恢复$count个商品';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsDisplayCurrency => '显示货币';

  @override
  String get settingsDynamicPricing => '动态定价';

  @override
  String get settingsDynamicPricingUnavailable => 'KAS显示货币不可用';

  @override
  String get settingsDynamicPricingSubtitle => '每60秒自动更新价格';

  @override
  String get settingsAppInfo => '应用信息';

  @override
  String get settingsAppVersion => '应用版本';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String get themeTitle => '主题设置';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeModeSystem => '系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get themePrimaryColor => '主色';

  @override
  String get themeResetToDefault => '重置为默认';

  @override
  String get themePreview => '预览';

  @override
  String get themePreviewSampleCard => '示例卡片';

  @override
  String get themePreviewSampleCardBody => '这是所选颜色下您的主题外观。';

  @override
  String get themePreviewFilledButton => '填充按钮';

  @override
  String get themePreviewOutlinedButton => '轮廓按钮';

  @override
  String get themePreviewTextButton => '文本按钮';

  @override
  String get networkTitle => '网络';

  @override
  String get networkActiveNetwork => '活动网络';

  @override
  String get networkMainnet => '主网';

  @override
  String get networkMainnetSubtitle => '生产Kaspa网络';

  @override
  String get networkTestnet10 => '测试网-10';

  @override
  String get networkTestnet10Subtitle => '测试网络·使用TKAS';

  @override
  String get networkNodeStatus => '节点状态';

  @override
  String get networkConnected => '已连接';

  @override
  String get networkDisconnected => '已断开';

  @override
  String get networkVirtualDaaScore => '虚拟DAA分数';

  @override
  String get networkCustomNodeUrls => '自定义节点URL';

  @override
  String get networkMainnetUrl => '主网WebSocket URL';

  @override
  String get networkTestnet10Url => '测试网-10 WebSocket URL';

  @override
  String get networkSave => '保存';

  @override
  String get networkSaved => '已保存 — 重新连接中…';

  @override
  String get networkRequired => '必填';

  @override
  String get networkAutoMode => '自动（解析器）';

  @override
  String get networkCustomMode => '自定义节点';

  @override
  String get networkResolving => '正在查找最佳节点…';

  @override
  String networkResolvedNode(String url) {
    return '节点: $url';
  }

  @override
  String get networkResetToAuto => '重置为自动';

  @override
  String get networkResetToAutoSnackbar => '已重置为自动 — 重新连接中…';

  @override
  String get donateTitle => '捐赠';

  @override
  String get donateSupportDeveloper => '支持开发者';

  @override
  String get donateSupportDeveloperBody =>
      'Kasway是免费开源软件。如果您觉得有用，请考虑向开发者进行一次性KAS捐赠。';

  @override
  String get donateAddressCopied => '地址已复制';

  @override
  String get donateDonateNow => '立即捐赠';

  @override
  String get donateKas => '捐赠KAS';

  @override
  String donateRecipient(String address) {
    return '收款人：$address';
  }

  @override
  String donateAvailable(String amount) {
    return '可用：$amount KAS';
  }

  @override
  String get donateAmountLabel => '金额（KAS）';

  @override
  String get donateAmountRequired => '金额为必填项';

  @override
  String get donateAmountInvalid => '请输入有效金额';

  @override
  String get donateSend => '发送';

  @override
  String donateThankYou(String txId) {
    return '谢谢！TX：$txId';
  }

  @override
  String get donateTransactionFailed => '交易失败';

  @override
  String get donateAutoPerPayment => '每笔付款自动捐赠';

  @override
  String get donateAutoPerPaymentBody => '每次客户付款确认后，自动向开发者发送少量KAS（仅限主网）。';

  @override
  String get donateEnableAuto => '启用自动捐赠';

  @override
  String get donatePercentage => '交易百分比';

  @override
  String get donateFixed => '固定金额（KAS）';

  @override
  String get donatePercentageLabel => '百分比（%）';

  @override
  String get donateAmountKasLabel => '金额（KAS）';

  @override
  String get donateSaveSettings => '保存';

  @override
  String get donateInvalidValue => '请输入大于0的有效值';

  @override
  String get donateSettingsSaved => '自动捐赠设置已保存';

  @override
  String get donateHistory => '捐赠历史';

  @override
  String get donateNoDonations => '暂无捐赠记录';

  @override
  String get donateTxIdCopied => 'TX ID已复制';

  @override
  String get donateNoWallet => '未找到钱包助记词，请先设置您的钱包。';

  @override
  String get displayTitle => '外部显示器';

  @override
  String get displaySubtitle => '将支付QR码屏幕镜像到连接的显示器。';

  @override
  String get displayNotSupported => '仅适用于Android和iOS。';

  @override
  String get displayAvailableDisplays => '可用显示器';

  @override
  String get displayScan => '扫描';

  @override
  String get displayNoDisplays => '未找到显示器，点击扫描进行搜索。';

  @override
  String get displayConnect => '连接';

  @override
  String get displayStatus => '状态';

  @override
  String displayConnected(String name) {
    return '已连接：$name';
  }

  @override
  String get displayNotConnected => '未连接';

  @override
  String get displayReconnect => '重新连接';

  @override
  String get displayDisconnect => '断开连接';

  @override
  String get tableLayoutTitle => '桌位布局';

  @override
  String get tableLayoutSave => '保存';

  @override
  String get tableLayoutFeatureToggle => '桌位布局';

  @override
  String get tableLayoutAddTable => '添加桌位';

  @override
  String get tableLayoutRotateCcw => '逆时针旋转';

  @override
  String get tableLayoutRotateCw => '顺时针旋转';

  @override
  String get tableLayoutDeleteGroup => '删除组';

  @override
  String get tableLayoutDeleteTable => '删除桌位';

  @override
  String tableLayoutDeleteGroupContent(int count) {
    return '删除整个组（$count张桌子）？';
  }

  @override
  String tableLayoutDeleteTableContent(String label) {
    return '删除桌位\"$label\"？';
  }

  @override
  String get tableLayoutCancel => '取消';

  @override
  String get tableLayoutDelete => '删除';

  @override
  String get tableLayoutUnsavedChanges => '未保存的更改';

  @override
  String get tableLayoutUnsavedChangesContent => '有未保存的更改，是否丢弃并离开？';

  @override
  String get tableLayoutKeepEditing => '继续编辑';

  @override
  String get tableLayoutDiscard => '丢弃';

  @override
  String get tableLayoutSingleTables => '单桌';

  @override
  String get tableLayoutTableGroups => '桌位组';

  @override
  String get tableLayoutTableGroupsBody => '以预设排列一次放置多张桌子。';

  @override
  String get tableLayoutAddTableSheet => '添加桌位';

  @override
  String tableLayoutSeatsSuffix(int seats) {
    return ' · $seats人座';
  }

  @override
  String get tableLayoutRename => '重命名';

  @override
  String get tableLayoutSaveName => '保存';

  @override
  String get orderHistoryTitle => '订单历史';

  @override
  String get orderHistoryNoOrders => '暂无订单';

  @override
  String get orderHistoryTodayOrders => '今日订单';

  @override
  String get orderHistoryTodayRevenue => '今日收入';

  @override
  String get orderHistoryToday => '今天';

  @override
  String get orderHistoryYesterday => '昨天';

  @override
  String get orderHistoryNoItemDetails => '未记录商品详情';

  @override
  String get orderHistoryTotal => '合计';

  @override
  String get orderHistoryViewOnExplorer => '在浏览器中查看';

  @override
  String orderHistoryTable(String label) {
    return '桌位 $label';
  }

  @override
  String get withdrawalHistoryTitle => '提款历史';

  @override
  String get withdrawalHistoryNoWithdrawals => '暂无提款记录';

  @override
  String get withdrawalHistoryCopyTxId => '复制TX ID';

  @override
  String get withdrawalHistoryViewOnExplorer => '在浏览器中查看';

  @override
  String get withdrawalHistoryTxIdCopied => 'TX ID已复制';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileSelectSection => '选择分区';

  @override
  String get profileOrderHistory => '订单历史';

  @override
  String get profileManageItem => '管理商品';

  @override
  String get profileTableLayout => '桌位布局';

  @override
  String get profileBackupRestore => '备份与恢复';

  @override
  String get profileNetworkNode => '网络与节点';

  @override
  String get profileDisplay => '显示器';

  @override
  String get profileThemeSettings => '主题设置';

  @override
  String get profileSettings => '设置';

  @override
  String get profileDonate => '捐赠';

  @override
  String get profileLogout => '退出登录';

  @override
  String get profileLogoutContent => '确定要退出登录吗？';

  @override
  String get profileCancel => '取消';

  @override
  String get profileKaspaAddress => 'Kaspa地址';

  @override
  String get profileNoWallet => '未配置钱包';

  @override
  String get profileCopyAddress => '复制地址';

  @override
  String get profileViewInExplorer => '在浏览器中查看';

  @override
  String get profileBalance => '余额';

  @override
  String get profileWithdraw => '提款';

  @override
  String get profileAddressCopied => '地址已复制';

  @override
  String profileWithdrawTitle(String kasSymbol) {
    return '提取$kasSymbol';
  }

  @override
  String get profileDestinationAddress => '目标Kaspa地址';

  @override
  String get profileAddressRequired => '地址为必填项';

  @override
  String profileAddressInvalid(String hrp) {
    return '必须是有效的$hrp:地址';
  }

  @override
  String profileAmountLabel(String kasSymbol) {
    return '金额（$kasSymbol）';
  }

  @override
  String get profileAmountRequired => '金额为必填项';

  @override
  String get profileAmountInvalid => '请输入有效金额';

  @override
  String get profileSend => '发送';

  @override
  String get profileTransactionFailed => '交易失败';

  @override
  String get profileWithdrawNoWallet => '未找到钱包助记词，请先设置您的钱包。';

  @override
  String get profileWithdrawalSuccessTitle => '提款成功！';

  @override
  String get profileWithdrawalSuccessSubtitle => '您的KAS已成功发送。';

  @override
  String get profileMax => '最大';

  @override
  String get homeFailedToLoad => '加载产品失败';

  @override
  String get homeNoProducts => '未找到产品';

  @override
  String get homeConfirmSelection => '确认选择';

  @override
  String get homeClearOrderTitle => '清除订单？';

  @override
  String get homeClearOrderContent => '确定要从订单列表中删除所有商品吗？';

  @override
  String get homeClearOrder => '清除订单';

  @override
  String get homeCancel => '取消';

  @override
  String get homeTestnetBanner => '正在使用测试网模式';

  @override
  String get paymentTitle => '支付';

  @override
  String get paymentNoWallet => '未配置钱包，请先设置您的钱包。';

  @override
  String get paymentFetchingRates => '正在获取汇率…';

  @override
  String get paymentPleaseWait => '请稍候。';

  @override
  String get paymentRetry => '重试';

  @override
  String paymentReceivedOf(String received, String total, String kasSymbol) {
    return '已收到 $received/$total $kasSymbol';
  }

  @override
  String paymentWarning(String kasSymbol) {
    return '仅发送$kasSymbol，且金额必须与上方显示的完全一致。发送其他资产或金额不符可能导致资金损失。';
  }

  @override
  String paymentAutoDonationNotice(String amount, String kasSymbol) {
    return '自动捐赠已启用 — 付款确认后将向开发者发送$amount $kasSymbol。';
  }

  @override
  String get paymentOrderList => '订单列表';

  @override
  String get tableSelectTitle => '选择桌位';

  @override
  String get tableSelectMarkAsServed => '标记为已服务';

  @override
  String get tableSelectFreeTable => '释放桌位';

  @override
  String tableSelectFreeTableContent(String label) {
    return '将桌位$label标记为可用？这将解除占用状态。';
  }

  @override
  String get tableSelectFreeTableTitle => '释放桌位';

  @override
  String tableSelectTableLabel(String label) {
    return '桌位 $label';
  }

  @override
  String get tableSelectNoTables => '未配置桌位';

  @override
  String get tableSelectNoTablesBody => '请在个人资料 > 桌位布局中设置您的平面图。';

  @override
  String get tableSelectGoToLayout => '前往桌位布局';

  @override
  String get paymentSuccessTitle => '支付成功！';

  @override
  String get paymentSuccessSubtitle => '交易已成功处理。';

  @override
  String paymentSuccessRedirect(int count, String plural) {
    return '将在$count秒后重定向$plural...';
  }

  @override
  String get itemManageTitle => '管理商品';

  @override
  String get itemNoCategoriesYet => '暂无分类';

  @override
  String get itemCreateCategory => '创建分类';

  @override
  String get itemNoItemsInCategory => '此分类中没有商品';

  @override
  String get itemDeleteProductTitle => '删除产品？';

  @override
  String itemDeleteProductInCart(String name) {
    return '「$name」在活跃订单中，删除后也会从购物车中移除。';
  }

  @override
  String itemDeleteProductConfirm(String name) {
    return '删除「$name」？此操作无法撤销。';
  }

  @override
  String get itemDeleteCancel => '取消';

  @override
  String get itemDeleteConfirm => '删除';

  @override
  String get itemDone => '完成';

  @override
  String itemAdditionCount(int count, String plural) {
    return ' · $count个附加$plural';
  }

  @override
  String get itemFormEditTitle => '编辑产品';

  @override
  String get itemFormAddTitle => '添加产品';

  @override
  String get itemFormSave => '保存';

  @override
  String get itemFormProductName => '产品名称';

  @override
  String get itemFormRequired => '必填';

  @override
  String get itemFormInvalidNumber => '请输入有效数字';

  @override
  String get itemFormCategory => '分类';

  @override
  String get itemFormDescription => '描述（可选）';

  @override
  String get itemFormAdditions => '附加选项';

  @override
  String get itemFormAddAddition => '添加附加项';

  @override
  String get itemFormAdditionFree => '免费';

  @override
  String get itemFormEditAdditionTitle => '编辑附加项';

  @override
  String get itemFormNewAdditionTitle => '新附加项';

  @override
  String get itemFormAdditionName => '附加项名称';

  @override
  String itemFormAdditionPriceLabel(String code) {
    return '额外价格（$code，0=免费）';
  }

  @override
  String get itemFormCancel => '取消';

  @override
  String get categoryManageTitle => '分类';

  @override
  String get categoryAddCategory => '添加分类';

  @override
  String get categoryNewCategory => '新分类';

  @override
  String get categoryNameLabel => '分类名称';

  @override
  String get categoryAdd => '添加';

  @override
  String get categoryCancel => '取消';

  @override
  String get categoryRenameTitle => '重命名分类';

  @override
  String get categoryRename => '重命名';

  @override
  String get categoryDeleteTitle => '删除分类？';

  @override
  String categoryDeleteWithItems(String name, int count, String plural) {
    return '「$name」包含$count个商品$plural，也将被永久删除。此操作无法撤销。';
  }

  @override
  String categoryDeleteEmpty(String name) {
    return '删除「$name」？此操作无法撤销。';
  }

  @override
  String get categoryDelete => '删除';

  @override
  String categoryItemCount(int count, String plural) {
    return '$count个商品$plural';
  }

  @override
  String get itemManageCreate => '创建';
}
