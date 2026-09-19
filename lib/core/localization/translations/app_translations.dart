abstract class AppTranslations {
  const AppTranslations();

  // Common & Navigation
  String get appName;
  String get cancel;
  String get confirm;
  String get retry;
  String get back;
  String get loading;
  String get success;
  String get error;
  String get networkError;
  String get audioAssistance;
  String get audioAssistanceSubtitle;
  String get selectLanguage;
  String get listenSample;
  String get sampleSpeech;
  String get audioTooltip;

  // Auth & Onboarding
  String get loginTitle;
  String get loginSubtitle;
  String get enterMobile;
  String get mobileHint;
  String get enterPassword;
  String get passwordHint;
  String get createNewAccount;
  String get loginAction;
  String get alreadyHaveAccount;
  String get registerTitle;
  String get registerSubtitle;
  String get fullNameLabel;
  String get fullNameHint;
  String get mobileLabel;
  String get passwordLabel;
  String get passwordMinHint;
  String get pincodeLabel;
  String get pincodeHint;
  String get registerAction;
  String get collectorAccountBadge;
  String get recyclerAccountBadge;
  String get spokenLoginGuide;

  // Validation
  String get nameRequired;
  String get phoneRequired;
  String get passwordRequired;
  String get pincodeInvalid;
  String get accountExistsError;
  String get regSuccessLoginFallback;

  // Collector Dashboard
  String get collectorGreeting;
  String get collectorSubGreeting;
  String get myLotsAction;
  String get myEarningsAction;
  String get recentLotsTitle;
  String get viewAllAction;
  String get noRecentLots;
  String get addFirstLotAction;
  String get liveScrapRatesTitle;
  String get newScrapLotAction;

  // Scrap Categories
  String get categoryPlastic;
  String get categoryEwaste;
  String get categoryMetal;
  String get categoryPaper;
  String get categoryBattery;
  String get categoryCable;
  String get categoryGlass;
  String get categoryOther;

  // New Lot & AI Matchmaking
  String get newLotTitle;
  String get selectMaterial;
  String get enterWeight;
  String get estimatedPrice;
  String get addPhoto;
  String get createLotButton;
  String get nearbyRecyclersTitle;
  String get confirmOfferDialogTitle;
  String get confirmOfferDialogBody;
  String get requestSentSuccess;

  // Lot Lifecycle & Status
  String get statusPending;
  String get statusAccepted;
  String get statusPicked;
  String get statusDelivered;
  String get statusCompleted;
  String get statusCancelled;
  String get filterAll;
  String get filterPending;
  String get filterInProgress;
  String get filterCompleted;

  // Recycler Flow
  String get recyclerDashboardTitle;
  String get acceptLotCta;
  String get acceptLotConfirmTitle;
  String get confirmPickupCta;
  String get confirmDeliveryCta;
  String get completeLotCta;
  String get enterActualWeight;
  String get finalPriceLabel;

  // Transactions & Payment
  String get transactionsTitle;
  String get totalEarnings;
  String get pendingAmount;
  String get receivedAmount;
  String get paymentStatusPaid;
  String get paymentStatusPending;
  String get makePaymentCta;
  String get paymentSuccessMessage;

  // Aliases & Convenience getters
  String get pleaseEnterValidPhone => phoneRequired;
  String get passwordMinLength => passwordRequired;
  String get pleaseEnterFullName => nameRequired;
  String get pincodeMustBe6Digits => pincodeInvalid;
  String get roleRecycler => recyclerAccountBadge;
  String get roleCollector => collectorAccountBadge;
  String get fullName => fullNameLabel;
  String get pincodeOptional => pincodeLabel;

  String get welcomeGreeting => collectorGreeting;
  String get dashboardSubtitle => collectorSubGreeting;
  String get myRecentLots => recentLotsTitle;
  String get viewAll => viewAllAction;
  String get noScrapLots => noRecentLots;
  String get noScrapLotsSubtitle =>
      'नया लॉट जोड़ें और पास के रीसाइक्लर्स से तुरंत ऑफर पाएं';
  String get createNewLot => 'नया कबाड़ जोड़ें';
  String get todayRatesTitle => liveScrapRatesTitle;
  String get liveStatus => live;
  String get live => 'लाइव';
  String get perKg => 'प्रति किलोग्राम';
  String get categoryPcb => 'पीसीबी / ई-कचरा';
  String get collectorDashboardLoading => 'डैशबोर्ड लोड हो रहा है...';
  String get collectorDashboardLoadError => 'डैशबोर्ड लोड नहीं हो सका';
  String get lotsLoading => 'लॉट लोड हो रहे हैं...';
  String get lotsLoadError => 'लोड करने में समस्या हुई';
  String get noLotsFound => 'कोई लॉट नहीं मिला';
  String get statusCompletedDetailed => 'पूरा हुआ';
  String get searchingRecyclers => 'रीसाइक्लर खोजे जा रहे हैं...';
  String get searchingRecyclersSubtitle =>
      'आपके लॉट के लिए निकटतम और सबसे अच्छे रीसाइक्लर ढूंढे जा रहे हैं';
  String get recyclersLoadError => 'रीसाइक्लर लोड करने में समस्या';
  String get goBackAction => 'वापस जाएं';
  String matchPercentageLabel(int pct) => 'मैच: $pct%';
  String confirmOfferWithRecycler(String name) => 'ऑफर की पुष्टि करें ($name)';
  String get noIncomingLots => 'अभी कोई नया लॉट नहीं है';
  String get noIncomingLotsSubtitle => 'नए लॉट अनुरोध यहाँ दिखाई देंगे।';
  String get refreshAction => 'रिफ्रेश करें';
  String get pickupRequested => 'पिकअप अनुरोध';
  String get recyclerLotsLoadError => 'लॉट लोड करने में समस्या';
  String get kgUnit => 'किलो';
  String get createNewLotButton => 'नया लॉट बनाएं';
  String get nameLabel => 'पूरा नाम';
  String get nameHint => 'उदा. राहुल शर्मा';
  String get phoneLabel => 'मोबाइल नंबर';
  String get phoneHint => '10 अंकों का नंबर';
  String get createAccount => 'खाता बनाएं';

  String get takePhotoAi => 'फोटो लें और AI से कबाड़ की पहचान करें';
  String get takeScrapPhoto => 'कबाड़ की फोटो लें';
  String get takeScrapPhotoSubtitle => 'साफ़ फोटो से AI बेहतर पहचान कर पाएगा';
  String get camera => 'कैमरा';
  String get gallery => 'गैलरी';
  String get changePhoto => 'फोटो बदलें';
  String get aiClassifying => 'AI पहचान रहा है...';
  String get aiFailed => 'पहचान नहीं हो सकी';
  String get aiIdentified => 'AI से पहचान';
  String get confidence => 'विश्वास';
  String get scrapType => 'कबाड़ का प्रकार';
  String get weight => 'वज़न';
  String get findRecyclers => 'रीसाइक्लर खोजें';
  String get nearbyRecyclers => nearbyRecyclersTitle;
  String get selectRecycler => 'रीसाइक्लर चुनें';
  String get bestMatch => 'सर्वश्रेष्ठ मैच';
  String get proposedRate => 'प्रस्तावित दर';
  String get estimatedOffer => 'अनुमानित ऑफर';
  String get selected => 'चयनित';
  String get confirmRecycler => confirmOfferDialogTitle;
  String get confirmOffer => confirm;
  String get noRecyclersFound => 'कोई रीसाइक्लर नहीं मिला';

  String get lotDetails => 'लॉट विवरण';
  String get viewTransaction => 'लेन-देन देखें';
  String get allLots => filterAll;
  String get pendingLots => filterPending;
  String get inProgressLots => filterInProgress;
  String get completedLots => filterCompleted;

  String get newLotRequests => recyclerDashboardTitle;
  String get noLotsAvailable => 'अभी कोई नया लॉट नहीं है';
  String get incomingLotsSubtitle => 'आपके पास आने वाले कलेक्टर के लॉट';

  String get noTransactionsFound => 'कोई लेन-देन नहीं मिला';
  String get myEarningsAndTransactions => transactionsTitle;
  String get transactionDetails => 'लेन-देन विवरण';
  String get earningsSummary => 'कमाई का सारांश';
  String get paymentPending => pendingAmount;
  String get paymentCompleted => receivedAmount;
  String get paymentFailed => 'भुगतान विफल';
  String get allTransactions => filterAll;
  String get netPayable => 'शुद्ध राशि';
  String get viewDetails => 'विवरण देखें';
  String get settlementAmount => finalPriceLabel;
  String get cashPayment => 'नकद भुगतान';
  String get upiPayment => 'यूपीआई भुगतान';
  String get bankTransfer => 'बैंक ट्रांसफर';

  // Parametric Spoken Sentences
  String spokenDashboardSummary(
      {required int lotCount, required String topRate});
  String spokenLotDetails({
    required String material,
    required num weight,
    required num price,
    required String status,
  });
  String spokenEarnings({
    required num total,
    required num received,
    required num pending,
  });
  String spokenLifecycleUpdate({
    required String status,
    required String nextAction,
  });
}
