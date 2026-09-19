import 'app_translations.dart';

class MarathiTranslations extends AppTranslations {
  const MarathiTranslations();

  // Common & Navigation
  @override
  String get appName => 'कबाडीवाला कनेक्ट';
  @override
  String get cancel => 'रद्द करा';
  @override
  String get confirm => 'निश्चित करा';
  @override
  String get retry => 'पुन्हा प्रयत्न करा';
  @override
  String get back => 'मागे';
  @override
  String get loading => 'लोड होत आहे...';
  @override
  String get success => 'यशस्वी';
  @override
  String get error => 'त्रुटी';
  @override
  String get networkError => 'इंटरनेट कनेक्शन उपलब्ध नाही';
  @override
  String get audioAssistance => 'ऑडिओ मदत';
  @override
  String get audioAssistanceSubtitle => 'बटणे आणि महत्त्वाची माहिती आवाजात ऐका';
  @override
  String get selectLanguage => 'भाषा निवडा';
  @override
  String get listenSample => 'ऐकून पाहा';
  @override
  String get sampleSpeech =>
      'नमस्कार! कबाडीवाला कनेक्ट मध्ये ऑडिओ मदत सुरू आहे.';
  @override
  String get audioTooltip => 'आवाजात ऐका';

  // Auth & Onboarding
  @override
  String get loginTitle => 'लॉग इन करा';
  @override
  String get loginSubtitle => 'नमस्कार!';
  @override
  String get enterMobile => 'आपला मोबाईल नंबर टाका';
  @override
  String get mobileHint => '10 अंकी नंबर';
  @override
  String get enterPassword => 'पासवर्ड टाका';
  @override
  String get passwordHint => 'पासवर्ड';
  @override
  String get createNewAccount => 'नवीन खाते तयार करा (भूमिका निवडा)';
  @override
  String get loginAction => 'लॉग इन करा';
  @override
  String get alreadyHaveAccount => 'आधीच खाते आहे? लॉग इन करा';
  @override
  String get registerTitle => 'खाते तयार करा';
  @override
  String get registerSubtitle =>
      'कबाडीवाला कनेक्ट मध्ये सामील होण्यासाठी माहिती टाका';
  @override
  String get fullNameLabel => 'पूर्ण नाव';
  @override
  String get fullNameHint => 'उदा. राहुल शर्मा';
  @override
  String get mobileLabel => 'मोबाईल नंबर';
  @override
  String get passwordLabel => 'पासवर्ड';
  @override
  String get passwordMinHint => 'किमान 6 अक्षरे';
  @override
  String get pincodeLabel => 'पिन कोड (पर्यायी)';
  @override
  String get pincodeHint => '6 अंकी पिन कोड';
  @override
  String get registerAction => 'नोंदणी करा';
  @override
  String get collectorAccountBadge => 'कलेक्टर खाते';
  @override
  String get recyclerAccountBadge => 'रिसायकलर खाते';
  @override
  String get spokenLoginGuide =>
      'कबाडीवाला कनेक्ट मध्ये आपले स्वागत आहे. आपला 10 अंकी मोबाईल नंबर आणि पासवर्ड टाकून लॉग इन करा.';

  // Validation
  @override
  String get nameRequired => 'कृपया आपले पूर्ण नाव टाका';
  @override
  String get phoneRequired => 'कृपया 10 अंकी वैध मोबाईल नंबर टाका';
  @override
  String get passwordRequired => 'पासवर्ड किमान 6 अक्षरांचा असावा';
  @override
  String get pincodeInvalid => 'पिन कोड 6 अंकांचा असावा';
  @override
  String get accountExistsError =>
      'या मोबाईल नंबर किंवा ईमेलवर आधीच खाते अस्तित्वात आहे';
  @override
  String get regSuccessLoginFallback =>
      'खाते तयार झाले आहे, कृपया मोबाईल नंबर आणि पासवर्डने लॉग इन करा';

  // Collector Dashboard
  @override
  String get collectorGreeting => 'नमस्कार, कबाडी मित्र';
  @override
  String get collectorSubGreeting => 'तुमच्यासाठी आजचे भंगार भाव';
  @override
  String get myLotsAction => 'माझे भंगार लॉट';
  @override
  String get myEarningsAction => 'माझी कमाई आणि व्यवहार';
  @override
  String get recentLotsTitle => 'माझे हालिया लॉट';
  @override
  String get viewAllAction => 'सर्व पाहा >';
  @override
  String get noRecentLots => 'सध्या कोणताही भंगार लॉट नाही';
  @override
  String get addFirstLotAction => 'लॉट जोडा';
  @override
  String get liveScrapRatesTitle => 'आजचे ताजे भंगार भाव';
  @override
  String get newScrapLotAction => 'नवीन भंगार लॉट तयार करा';

  // Scrap Categories
  @override
  String get categoryPlastic => 'प्लॅस्टिक';
  @override
  String get categoryEwaste => 'ई-कचरा';
  @override
  String get categoryMetal => 'धातू / लोखंड';
  @override
  String get categoryPaper => 'कागद';
  @override
  String get categoryBattery => 'बॅटरी';
  @override
  String get categoryCable => 'केबल';
  @override
  String get categoryGlass => 'काच';
  @override
  String get categoryOther => 'इतर';

  // New Lot & AI Matchmaking
  @override
  String get newLotTitle => 'नवीन भंगार लॉट';
  @override
  String get selectMaterial => 'भंगाराचा प्रकार निवडा';
  @override
  String get enterWeight => 'अंदाजे वजन (किलो)';
  @override
  String get estimatedPrice => 'अंदाजे किंमत';
  @override
  String get addPhoto => 'फोटो जोडा';
  @override
  String get createLotButton => 'लॉट सबमिट करा';
  @override
  String get nearbyRecyclersTitle => 'जवळचे रिसायकलर';
  @override
  String get confirmOfferDialogTitle => 'रिसायकलर निश्चित करा';
  @override
  String get confirmOfferDialogBody =>
      'तुम्ही या रिसायकलरला लॉट सोपवण्याची विनंती पाठवू इच्छिता का?';
  @override
  String get requestSentSuccess => 'रिसायकलरला विनंती पाठवली आहे!';

  // Lot Lifecycle & Status
  @override
  String get statusPending => 'प्रलंबित';
  @override
  String get statusAccepted => 'स्वीकारले';
  @override
  String get statusPicked => 'मार्गावर';
  @override
  String get statusDelivered => 'पोहोचले';
  @override
  String get statusCompleted => 'पूर्ण';
  @override
  String get statusCancelled => 'रद्द';
  @override
  String get filterAll => 'सर्व';
  @override
  String get filterPending => 'प्रलंबित';
  @override
  String get filterInProgress => 'प्रगतीपथावर';
  @override
  String get filterCompleted => 'पूर्ण';

  // Recycler Flow
  @override
  String get recyclerDashboardTitle => 'नवीन लॉट विनंत्या';
  @override
  String get acceptLotCta => 'लॉट स्वीकारा';
  @override
  String get acceptLotConfirmTitle => 'लॉट स्वीकृती निश्चित करा';
  @override
  String get confirmPickupCta => 'पिकअप निश्चित करा';
  @override
  String get confirmDeliveryCta => 'डिलिव्हरी निश्चित करा';
  @override
  String get completeLotCta => 'लॉट पूर्ण करा';
  @override
  String get enterActualWeight => 'खरे वजन टाका (किलो)';
  @override
  String get finalPriceLabel => 'अंतिम किंमत';

  // Transactions & Payment
  @override
  String get transactionsTitle => 'माझी कमाई आणि व्यवहार';
  @override
  String get totalEarnings => 'एकूण कमाई';
  @override
  String get pendingAmount => 'बाकी रक्कम';
  @override
  String get receivedAmount => 'मिळालेले पैसे';
  @override
  String get paymentStatusPaid => 'पेमेंट पूर्ण';
  @override
  String get paymentStatusPending => 'पेमेंट प्रतीक्षेत';
  @override
  String get makePaymentCta => 'पेमेंट पूर्ण करा';
  @override
  String get paymentSuccessMessage => 'पेमेंट यशस्वीरीत्या नोंदवले गेले!';

  // Parametric Spoken Sentences
  @override
  String spokenDashboardSummary({
    required int lotCount,
    required String topRate,
  }) {
    if (lotCount == 0) {
      return 'नमस्कार कबाडी मित्र. तुमच्याकडे सध्या कोणताही सक्रिय लॉट नाही. नवीन लॉट जोडण्यासाठी खालील बटण दाबा.';
    }
    return 'नमस्कार कबाडी मित्र. तुमच्याकडे आज $lotCount लॉट आहेत. आजचा मुख्य भाव $topRate आहे.';
  }

  @override
  String spokenLotDetails({
    required String material,
    required num weight,
    required num price,
    required String status,
  }) {
    return '$material, वजन $weight किलो, किंमत $price रुपये. सध्याची स्थिती: $status.';
  }

  @override
  String spokenEarnings({
    required num total,
    required num received,
    required num pending,
  }) {
    return 'तुमची एकूण कमाई $total रुपये आहे. मिळालेले पैसे $received रुपये, आणि बाकी रक्कम $pending रुपये आहे.';
  }

  @override
  String spokenLifecycleUpdate({
    required String status,
    required String nextAction,
  }) {
    return 'लॉट स्थिती आता $status आहे. $nextAction';
  }

  @override
  String get welcomeGreeting => 'नमस्कार, कबाडी मित्र';
  @override
  String get dashboardSubtitle => 'तुमच्यासाठी आजचे स्क्रॅप भाव';
  @override
  String get myRecentLots => 'माझे अलीकडील लॉट्स';
  @override
  String get viewAll => 'सर्व पहा';
  @override
  String get noScrapLots => 'सध्या कोणताही स्क्रॅप लॉट नाही';
  @override
  String get noScrapLotsSubtitle =>
      'नवीन लॉट जोडा आणि जवळच्या रीसायकलर्सकडून लगेच ऑफर मिळवा';
  @override
  String get createNewLot => 'नवीन स्क्रॅप लॉट तयार करा';
  @override
  String get todayRatesTitle => 'आजचे ताजे स्क्रॅप भाव';
  @override
  String get liveStatus => 'थेट';
  @override
  String get perKg => 'प्रति किलो';
  @override
  String get categoryPcb => 'पीसीबी / ई-कचरा';
  @override
  String get takePhotoAi => 'फोटो काढा आणि AI द्वारे स्क्रॅप ओळखा';
  @override
  String get takeScrapPhoto => 'स्क्रॅपचा फोटो काढा';
  @override
  String get takeScrapPhotoSubtitle => 'स्पष्ट फोटोमुळे AI अचूक ओळखू शकेल';
  @override
  String get camera => 'कॅमेरा';
  @override
  String get gallery => 'गॅलरी';
  @override
  String get changePhoto => 'फोटो बदला';
  @override
  String get aiClassifying => 'AI ओळखत आहे...';
  @override
  String get aiFailed => 'ओळखता आले नाही';
  @override
  String get aiIdentified => 'AI द्वारे ओळख';
  @override
  String get confidence => 'अचूकता';
  @override
  String get scrapType => 'स्क्रॅपचा प्रकार';
  @override
  String get weight => 'वजन';
  @override
  String get findRecyclers => 'रीसायकलर शोधा';
  @override
  String get nearbyRecyclers => 'जवळचे रीसायकलर्स';
  @override
  String get selectRecycler => 'रीसायकलर निवडा';
  @override
  String get bestMatch => 'सर्वोत्तम जुळणी';
  @override
  String get proposedRate => 'प्रस्तावित दर';
  @override
  String get estimatedOffer => 'अंदाजे ऑफर';
  @override
  String get selected => 'निवडलेले';
  @override
  String get confirmRecycler => 'रीसायकलर निश्चित करा';
  @override
  String get confirmOffer => 'ऑफर निश्चित करा';
  @override
  String get noRecyclersFound => 'कोणताही रीसायकलर आढळला नाही';
  @override
  String get lotDetails => 'लॉट तपशील';
  @override
  String get viewTransaction => 'व्यवहार पहा';
  @override
  String get allLots => 'सर्व लॉट्स';
  @override
  String get pendingLots => 'प्रलंबित';
  @override
  String get inProgressLots => 'प्रगतीपथावर';
  @override
  String get completedLots => 'पूर्ण झालेले';
  @override
  String get newLotRequests => 'नवीन लॉट विनंत्या';
  @override
  String get noLotsAvailable => 'सध्या कोणताही लॉट उपलब्ध नाही';
  @override
  String get incomingLotsSubtitle => 'तुमच्याकडे येणारे कलेक्टरचे लॉट्स';
  @override
  String get noTransactionsFound => 'कोणताही व्यवहार आढळला नाही';
  @override
  String get myEarningsAndTransactions => 'माझी कमाई आणि व्यवहार';
  @override
  String get transactionDetails => 'व्यवहार तपशील';
  @override
  String get earningsSummary => 'कमाईचा सारांश';
  @override
  String get paymentPending => 'देयक प्रलंबित';
  @override
  String get paymentCompleted => 'पेमेंट पूर्ण झाले';
  @override
  String get paymentFailed => 'पेमेंट अयशस्वी';
  @override
  String get allTransactions => 'सर्व व्यवहार';
  @override
  String get netPayable => 'निव्वळ रक्कम';
  @override
  String get viewDetails => 'तपशील पहा';
  @override
  String get settlementAmount => 'अंतिम रक्कम';
  @override
  String get cashPayment => 'रोख पेमेंट';
  @override
  @override
  String get bankTransfer => 'बँक हस्तांतरण';
  @override
  String get collectorDashboardLoading => 'डॅशबोर्ड लोड होत आहे...';
  @override
  String get collectorDashboardLoadError => 'डॅशबोर्ड लोड होऊ शकला नाही';
  @override
  String get lotsLoading => 'लॉट लोड होत आहेत...';
  @override
  String get lotsLoadError => 'लॉट लोड करताना त्रुटी आली';
  @override
  String get noLotsFound => 'कोणताही लॉट आढळला नाही';
  @override
  String get searchingRecyclers => 'रीसायकलर शोधत आहोत...';
  @override
  String get searchingRecyclersSubtitle =>
      'तुमच्या लॉटसाठी जवळचे रीसायकलर्स शोधले जात आहेत';
  @override
  String get recyclersLoadError => 'रीसायकलर लोड करताना त्रुटी';
  @override
  String get goBackAction => 'मागे जा';
  @override
  String matchPercentageLabel(int pct) => 'मॅच: $pct%';
  @override
  String confirmOfferWithRecycler(String name) => 'ऑफरची पुष्टी करा ($name)';
  @override
  String get noIncomingLots => 'सध्या कोणताही नवीन लॉट नाही';
  @override
  String get noIncomingLotsSubtitle => 'नवीन लॉट विनंत्या येथे दिसतील.';
  @override
  String get refreshAction => 'रिफ्रेश करा';
  @override
  String get pickupRequested => 'पिकअप विनंती';
  @override
  String get recyclerLotsLoadError => 'लॉट लोड करताना त्रुटी';
  @override
  String get kgUnit => 'किलो';
  @override
  String get live => 'लाईव्ह';
  @override
  String get statusCompletedDetailed => 'पूर्ण झाले';
}
