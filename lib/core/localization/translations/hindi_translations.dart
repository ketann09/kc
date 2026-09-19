import 'app_translations.dart';

class HindiTranslations extends AppTranslations {
  const HindiTranslations();

  // Common & Navigation
  @override
  String get appName => 'कबाड़ीवाला कनेक्ट';
  @override
  String get cancel => 'रद्द करें';
  @override
  String get confirm => 'पुष्टि करें';
  @override
  String get retry => 'पुनः प्रयास करें';
  @override
  String get back => 'पीछे';
  @override
  String get loading => 'लोड हो रहा है...';
  @override
  String get success => 'सफल';
  @override
  String get error => 'त्रुटि';
  @override
  String get networkError => 'इंटरनेट कनेक्शन उपलब्ध नहीं है';
  @override
  String get audioAssistance => 'आवाज सहायता';
  @override
  String get audioAssistanceSubtitle => 'बटन और जरूरी जानकारी आवाज में सुनें';
  @override
  String get selectLanguage => 'भाषा चुनें';
  @override
  String get listenSample => 'सुनकर देखें';
  @override
  String get sampleSpeech =>
      'नमस्ते! कबाड़ीवाला कनेक्ट में आवाज सहायता चालू है।';
  @override
  String get audioTooltip => 'आवाज से सुनें';

  // Auth & Onboarding
  @override
  String get loginTitle => 'लॉग इन करें';
  @override
  String get loginSubtitle => 'नमस्ते!';
  @override
  String get enterMobile => 'अपना मोबाइल नंबर दर्ज करें';
  @override
  String get mobileHint => '10 अंकों का नंबर';
  @override
  String get enterPassword => 'पासवर्ड दर्ज करें';
  @override
  String get passwordHint => 'पासवर्ड';
  @override
  String get createNewAccount => 'नया खाता बनाएं (रोल चुनें)';
  @override
  String get loginAction => 'लॉग इन करें';
  @override
  String get alreadyHaveAccount => 'पहले से खाता है? लॉग इन करें';
  @override
  String get registerTitle => 'खाता बनाएं';
  @override
  String get registerSubtitle =>
      'कबाड़ीवाला कनेक्ट में शामिल होने के लिए विवरण दर्ज करें';
  @override
  String get fullNameLabel => 'पूरा नाम';
  @override
  String get fullNameHint => 'उदा. राहुल शर्मा';
  @override
  String get mobileLabel => 'मोबाइल नंबर';
  @override
  String get passwordLabel => 'पासवर्ड';
  @override
  String get passwordMinHint => 'कम से कम 6 अक्षर';
  @override
  String get pincodeLabel => 'पिन कोड (वैकल्पिक)';
  @override
  String get pincodeHint => '6 अंकों का पिन कोड';
  @override
  String get registerAction => 'पंजीकरण करें';
  @override
  String get collectorAccountBadge => 'कलेक्टर खाता';
  @override
  String get recyclerAccountBadge => 'रीसाइक्लर खाता';
  @override
  String get spokenLoginGuide =>
      'कबाड़ीवाला कनेक्ट में आपका स्वागत है। अपना 10 अंकों का मोबाइल नंबर और पासवर्ड दर्ज करके लॉग इन करें।';

  // Validation
  @override
  String get nameRequired => 'कृपया अपना पूरा नाम दर्ज करें';
  @override
  String get phoneRequired => 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें';
  @override
  String get passwordRequired => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';
  @override
  String get pincodeInvalid => 'पिन कोड 6 अंकों का होना चाहिए';
  @override
  String get accountExistsError =>
      'इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है';
  @override
  String get regSuccessLoginFallback =>
      'खाता बन गया है, कृपया मोबाइल नंबर और पासवर्ड से लॉग इन करें';

  // Collector Dashboard
  @override
  String get collectorGreeting => 'नमस्ते, कबाड़ी साथी';
  @override
  String get collectorSubGreeting => 'आपके पास कबाड़ का भाव, आज के लिए';
  @override
  String get myLotsAction => 'मेरे कबाड़ लॉट';
  @override
  String get myEarningsAction => 'मेरी कमाई और लेन-देन';
  @override
  String get recentLotsTitle => 'मेरे हालिया लॉट';
  @override
  @override
  String get viewAllAction => 'सभी देखें';
  @override
  String get noRecentLots => 'अभी कोई कबाड़ लॉट नहीं है';
  @override
  String get addFirstLotAction => 'लॉट जोड़ें';
  @override
  String get liveScrapRatesTitle => 'आज के ताज़ा स्क्रैप भाव';
  @override
  String get newScrapLotAction => 'नया कबाड़ लॉट बनाएं';

  // Scrap Categories
  @override
  String get categoryPlastic => 'प्लास्टिक';
  @override
  String get categoryEwaste => 'ई-वेस्ट';
  @override
  String get categoryPcb => 'पीसीबी / ई-कचरा';
  @override
  String get categoryMetal => 'धातु / लोहा';
  @override
  String get categoryPaper => 'कागज़';
  @override
  String get categoryBattery => 'बैटरी';
  @override
  String get categoryCable => 'केबल';
  @override
  String get categoryGlass => 'कांच';
  @override
  String get categoryOther => 'अन्य';

  // New Lot & AI Matchmaking
  @override
  String get newLotTitle => 'नया कबाड़ लॉट';
  @override
  String get selectMaterial => 'कबाड़ का प्रकार चुनें';
  @override
  String get enterWeight => 'अनुमानित वजन (किलो)';
  @override
  String get estimatedPrice => 'अनुमानित कीमत';
  @override
  String get addPhoto => 'फोटो जोड़ें';
  @override
  String get createLotButton => 'लॉट जमा करें';
  @override
  String get nearbyRecyclersTitle => 'पास के रीसाइक्लर';
  @override
  String get confirmOfferDialogTitle => 'रीसाइक्लर की पुष्टि करें';
  @override
  String get confirmOfferDialogBody =>
      'क्या आप इस रीसाइक्लर को लॉट सौंपने का अनुरोध भेजना चाहते हैं?';
  @override
  String get requestSentSuccess => 'रीसाइक्लर को अनुरोध भेज दिया गया है!';

  // Lot Lifecycle & Status
  @override
  String get statusPending => 'लंबित';
  @override
  String get statusAccepted => 'स्वीकृत';
  @override
  String get statusPicked => 'रास्ते में';
  @override
  String get statusDelivered => 'पहुंच गया';
  @override
  String get statusCompleted => 'पूर्ण';
  @override
  String get statusCompletedDetailed => 'पूरा हुआ';
  @override
  String get statusCancelled => 'रद्द';
  @override
  String get filterAll => 'सभी';
  @override
  String get filterPending => 'लंबित';
  @override
  String get filterInProgress => 'प्रगति पर';
  @override
  String get filterCompleted => 'पूर्ण';

  // Recycler Flow
  @override
  String get recyclerDashboardTitle => 'नए लॉट अनुरोध';
  @override
  String get acceptLotCta => 'लॉट स्वीकार करें';
  @override
  String get acceptLotConfirmTitle => 'लॉट स्वीकृति की पुष्टि';
  @override
  String get confirmPickupCta => 'पिकअप कन्फर्म करें';
  @override
  String get confirmDeliveryCta => 'डिलीवरी कन्फर्म करें';
  @override
  String get completeLotCta => 'लॉट पूरा करें';
  @override
  String get enterActualWeight => 'वास्तविक वजन दर्ज करें (किलो)';
  @override
  String get finalPriceLabel => 'अंतिम मूल्य';

  // Transactions & Payment
  @override
  String get transactionsTitle => 'मेरी कमाई और लेन-देन';
  @override
  String get totalEarnings => 'कुल कमाई';
  @override
  String get pendingAmount => 'भुगतान बाकी';
  @override
  String get receivedAmount => 'भुगतान पूरा';
  @override
  String get paymentStatusPaid => 'भुगतान पूरा';
  @override
  String get paymentStatusPending => 'भुगतान बाकी';
  @override
  String get makePaymentCta => 'भुगतान पूरा करें';
  @override
  String get paymentSuccessMessage => 'भुगतान सफलतापूर्वक दर्ज किया गया!';

  @override
  String get collectorDashboardLoading => 'डैशबोर्ड लोड हो रहा है...';
  @override
  String get collectorDashboardLoadError => 'डैशबोर्ड लोड नहीं हो सका';
  @override
  String get lotsLoading => 'लॉट लोड हो रहे हैं...';
  @override
  String get lotsLoadError => 'लोड करने में समस्या हुई';
  @override
  String get noLotsFound => 'कोई लॉट नहीं मिला';
  @override
  String get searchingRecyclers => 'रीसाइक्लर खोजे जा रहे हैं...';
  @override
  String get searchingRecyclersSubtitle =>
      'आपके लॉट के लिए निकटतम और सबसे अच्छे रीसाइक्लर ढूंढे जा रहे हैं';
  @override
  String get recyclersLoadError => 'रीसाइक्लर लोड करने में समस्या';
  @override
  String get goBackAction => 'वापस जाएं';
  @override
  String matchPercentageLabel(int pct) => 'मैच: $pct%';
  @override
  String confirmOfferWithRecycler(String name) => 'ऑफर की पुष्टि करें ($name)';
  @override
  String get noIncomingLots => 'अभी कोई नया लॉट नहीं है';
  @override
  String get noIncomingLotsSubtitle => 'नए लॉट अनुरोध यहाँ दिखाई देंगे।';
  @override
  String get refreshAction => 'रिफ्रेश करें';
  @override
  String get pickupRequested => 'पिकअप अनुरोध';
  @override
  String get recyclerLotsLoadError => 'लॉट लोड करने में समस्या';
  @override
  String get kgUnit => 'किलो';
  @override
  String get live => 'लाइव';
  @override
  String get liveStatus => 'लाइव';

  // Parametric Spoken Sentences
  @override
  String spokenDashboardSummary({
    required int lotCount,
    required String topRate,
  }) {
    if (lotCount == 0) {
      return 'नमस्ते कबाड़ी साथी। आपके पास अभी कोई सक्रिय लॉट नहीं है। नया लॉट जोड़ने के लिए नीचे दिए गए बटन को दबाएं।';
    }
    return 'नमस्ते कबाड़ी साथी। आपके पास आज $lotCount लॉट हैं। आज का प्रमुख भाव $topRate है।';
  }

  @override
  String spokenLotDetails({
    required String material,
    required num weight,
    required num price,
    required String status,
  }) {
    return '$material, वजन $weight किलो, मूल्य $price रुपये। वर्तमान स्थिति: $status।';
  }

  @override
  String spokenEarnings({
    required num total,
    required num received,
    required num pending,
  }) {
    return 'आपकी कुल कमाई $total रुपये है। प्राप्त भुगतान $received रुपये, और बकाया राशि $pending रुपये है।';
  }

  @override
  String spokenLifecycleUpdate({
    required String status,
    required String nextAction,
  }) {
    return 'लॉट स्थिति अब $status है। $nextAction';
  }

  @override
  String get offlineStaleNotice => 'ऑफलाइन — पिछली जानकारी दिखाई जा रही है';

  @override
  String get refreshFailedKeepExisting =>
      'नया डेटा लोड नहीं हो सका — पहले की जानकारी दिखाई जा रही है';

  @override
  String get lastUpdatedPrefix => 'अंतिम अपडेट';

  // Offline Mutation Blocking & Sheet
  @override
  String get offlineNoticeTitle => 'आप अभी ऑफलाइन हैं';
  @override
  String get offlineNoticeSubtitle =>
      'यह काम इंटरनेट आने के बाद ही किया जा सकता है';
  @override
  String get offlineActionHelp =>
      'कृपया अपना मोबाइल डेटा या वाई-फाई चालू करें और पुनः प्रयास करें।';
  @override
  String get checkConnectionAction => 'इंटरनेट कनेक्शन जांचें';
  @override
  String get connectionChecking => 'कनेक्शन जांच रहे हैं...';
  @override
  String get connectionStillOffline =>
      'अभी भी ऑफलाइन हैं। कृपया नेटवर्क चालू करें।';
  @override
  String get connectionRestored => 'इंटरनेट कनेक्ट हो गया!';

  // Mutation-Specific Explanations
  @override
  String get offlineCreateLotBlocked =>
      'नया कबाड़ लॉट इंटरनेट आने के बाद ही बनाया जा सकता है।';
  @override
  String get offlineAcceptLotBlocked =>
      'लॉट स्वीकारने के लिए इंटरनेट कनेक्शन आवश्यक है।';
  @override
  String get offlineMarkPickedBlocked =>
      'लॉट पिकअप चिह्नित करने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineMarkDeliveredBlocked =>
      'लॉट डिलीवर चिह्नित करने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineCompleteLotBlocked =>
      'लॉट पूरा करने और अंतिम बिल बनाने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineCreateTransactionBlocked =>
      'लेन-देन बनाने के लिए इंटरनेट कनेक्शन आवश्यक है।';
  @override
  String get offlineUpdateHandoverBlocked =>
      'हैंडओवर विवरण सहेजने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineUpdatePaymentBlocked =>
      'भुगतान स्थिति अपडेट करने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineConfirmOfferBlocked =>
      'रीसाइक्लर का प्रस्ताव स्वीकारने के लिए इंटरनेट आवश्यक है।';
  @override
  String get offlineRegisterBlocked =>
      'नया खाता बनाने के लिए इंटरनेट कनेक्शन आवश्यक है।';
}
