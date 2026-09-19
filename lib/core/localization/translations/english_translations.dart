import 'app_translations.dart';

class EnglishTranslations extends AppTranslations {
  const EnglishTranslations();

  // Common & Navigation
  @override
  String get appName => 'Kabadiwala Connect';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get retry => 'Retry';
  @override
  String get back => 'Back';
  @override
  String get loading => 'Loading...';
  @override
  String get success => 'Success';
  @override
  String get error => 'Error';
  @override
  String get networkError => 'No internet connection';
  @override
  String get audioAssistance => 'Audio Assistance';
  @override
  String get audioAssistanceSubtitle => 'Listen to buttons and important info';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get listenSample => 'Test Audio';
  @override
  String get sampleSpeech =>
      'Hello! Audio assistance is active in Kabadiwala Connect.';
  @override
  String get audioTooltip => 'Listen';

  // Auth & Onboarding
  @override
  String get loginTitle => 'Log In';
  @override
  String get loginSubtitle => 'Welcome!';
  @override
  String get enterMobile => 'Enter your mobile number';
  @override
  String get mobileHint => '10-digit number';
  @override
  String get enterPassword => 'Enter password';
  @override
  String get passwordHint => 'Password';
  @override
  String get createNewAccount => 'Create New Account (Select Role)';
  @override
  String get loginAction => 'Log In';
  @override
  String get alreadyHaveAccount => 'Already have an account? Log In';
  @override
  String get registerTitle => 'Create Account';
  @override
  String get registerSubtitle => 'Enter details to join Kabadiwala Connect';
  @override
  String get fullNameLabel => 'Full Name';
  @override
  String get fullNameHint => 'e.g. Rahul Sharma';
  @override
  String get mobileLabel => 'Mobile Number';
  @override
  String get passwordLabel => 'Password';
  @override
  String get passwordMinHint => 'At least 6 characters';
  @override
  String get pincodeLabel => 'Pincode (Optional)';
  @override
  String get pincodeHint => '6-digit pincode';
  @override
  String get registerAction => 'Register';
  @override
  String get collectorAccountBadge => 'Collector Account';
  @override
  String get recyclerAccountBadge => 'Recycler Account';
  @override
  String get spokenLoginGuide =>
      'Welcome to Kabadiwala Connect. Please enter your 10-digit mobile number and password to log in.';

  // Validation
  @override
  String get nameRequired => 'Please enter your full name';
  @override
  String get phoneRequired => 'Please enter a valid 10-digit mobile number';
  @override
  String get passwordRequired => 'Password must be at least 6 characters';
  @override
  String get pincodeInvalid => 'Pincode must be 6 digits';
  @override
  String get accountExistsError =>
      'An account with this phone number already exists';
  @override
  String get regSuccessLoginFallback =>
      'Account created, please log in with your phone and password';

  // Collector Dashboard
  @override
  String get collectorGreeting => 'Hello, Collector Partner';
  @override
  String get collectorSubGreeting => 'Today\'s scrap rates for you';
  @override
  String get myLotsAction => 'My Scrap Lots';
  @override
  String get myEarningsAction => 'My Earnings & Transactions';
  @override
  String get recentLotsTitle => 'My Recent Lots';
  @override
  String get viewAllAction => 'View All >';
  @override
  String get noRecentLots => 'No scrap lots yet';
  @override
  String get addFirstLotAction => 'Add Lot';
  @override
  String get liveScrapRatesTitle => 'Today\'s Live Scrap Rates';
  @override
  String get newScrapLotAction => 'Create New Scrap Lot';

  // Scrap Categories
  @override
  String get categoryPlastic => 'Plastic';
  @override
  String get categoryEwaste => 'E-Waste';
  @override
  String get categoryMetal => 'Metal / Iron';
  @override
  String get categoryPaper => 'Paper';
  @override
  String get categoryBattery => 'Battery';
  @override
  String get categoryCable => 'Cable';
  @override
  String get categoryGlass => 'Glass';
  @override
  String get categoryOther => 'Other';

  // New Lot & AI Matchmaking
  @override
  String get newLotTitle => 'New Scrap Lot';
  @override
  String get selectMaterial => 'Select Scrap Material';
  @override
  String get enterWeight => 'Estimated Weight (kg)';
  @override
  String get estimatedPrice => 'Estimated Price';
  @override
  String get addPhoto => 'Add Photo';
  @override
  String get createLotButton => 'Submit Lot';
  @override
  String get nearbyRecyclersTitle => 'Nearby Recyclers';
  @override
  String get confirmOfferDialogTitle => 'Confirm Recycler';
  @override
  String get confirmOfferDialogBody =>
      'Do you want to send a request to hand over this lot to this recycler?';
  @override
  String get requestSentSuccess => 'Request sent to recycler!';

  // Lot Lifecycle & Status
  @override
  String get statusPending => 'Pending';
  @override
  String get statusAccepted => 'Accepted';
  @override
  String get statusPicked => 'In Transit';
  @override
  String get statusDelivered => 'Delivered';
  @override
  String get statusCompleted => 'Completed';
  @override
  String get statusCancelled => 'Cancelled';
  @override
  String get filterAll => 'All';
  @override
  String get filterPending => 'Pending';
  @override
  String get filterInProgress => 'In Progress';
  @override
  String get filterCompleted => 'Completed';

  // Recycler Flow
  @override
  String get recyclerDashboardTitle => 'Incoming Lot Requests';
  @override
  String get acceptLotCta => 'Accept Lot';
  @override
  String get acceptLotConfirmTitle => 'Confirm Lot Acceptance';
  @override
  String get confirmPickupCta => 'Confirm Pickup';
  @override
  String get confirmDeliveryCta => 'Confirm Delivery';
  @override
  String get completeLotCta => 'Complete Lot';
  @override
  String get enterActualWeight => 'Enter Actual Weight (kg)';
  @override
  String get finalPriceLabel => 'Final Price';

  // Transactions & Payment
  @override
  String get transactionsTitle => 'My Earnings & Transactions';
  @override
  String get totalEarnings => 'Total Earnings';
  @override
  String get pendingAmount => 'Pending Amount';
  @override
  String get receivedAmount => 'Received Payment';
  @override
  String get paymentStatusPaid => 'Paid';
  @override
  String get paymentStatusPending => 'Payment Pending';
  @override
  String get makePaymentCta => 'Complete Payment';
  @override
  String get paymentSuccessMessage => 'Payment recorded successfully!';

  // Parametric Spoken Sentences
  @override
  String spokenDashboardSummary({
    required int lotCount,
    required String topRate,
  }) {
    if (lotCount == 0) {
      return 'Hello Collector Partner. You have no active scrap lots right now. Tap the button below to create one.';
    }
    return 'Hello Collector Partner. You have $lotCount scrap lots today. Today\'s top scrap rate is $topRate.';
  }

  @override
  String spokenLotDetails({
    required String material,
    required num weight,
    required num price,
    required String status,
  }) {
    return '$material, weight $weight kilograms, price $price rupees. Current status: $status.';
  }

  @override
  String spokenEarnings({
    required num total,
    required num received,
    required num pending,
  }) {
    return 'Your total earnings are $total rupees. Received payment is $received rupees, and pending amount is $pending rupees.';
  }

  @override
  String spokenLifecycleUpdate({
    required String status,
    required String nextAction,
  }) {
    return 'Lot status is now $status. $nextAction';
  }

  @override
  String get welcomeGreeting => 'Welcome, Scrap Collector';
  @override
  String get dashboardSubtitle => 'Scrap rates for you today';
  @override
  String get myRecentLots => 'My Recent Lots';
  @override
  String get viewAll => 'View All';
  @override
  String get noScrapLots => 'No Scrap Lots Yet';
  @override
  String get noScrapLotsSubtitle =>
      'Add a new scrap lot to receive quick offers';
  @override
  String get createNewLot => 'Create New Scrap Lot';
  @override
  String get todayRatesTitle => 'Today\'s Live Scrap Rates';
  @override
  String get liveStatus => 'LIVE';
  @override
  String get perKg => 'per kg';
  @override
  String get categoryPcb => 'PCB / E-Waste';
  @override
  String get takePhotoAi => 'Take a photo and classify with AI';
  @override
  String get takeScrapPhoto => 'Take Scrap Photo';
  @override
  String get takeScrapPhotoSubtitle => 'Clear photo helps AI classify better';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Gallery';
  @override
  String get changePhoto => 'Change Photo';
  @override
  String get aiClassifying => 'AI Classifying...';
  @override
  String get aiFailed => 'Classification Failed';
  @override
  String get aiIdentified => 'AI Identification';
  @override
  String get confidence => 'confidence';
  @override
  String get scrapType => 'Scrap Type';
  @override
  String get weight => 'Weight';
  @override
  String get findRecyclers => 'Find Recyclers';
  @override
  String get nearbyRecyclers => 'Nearby Recyclers';
  @override
  String get selectRecycler => 'Select Recycler';
  @override
  String get bestMatch => 'Best Match';
  @override
  String get proposedRate => 'Proposed Rate';
  @override
  String get estimatedOffer => 'Estimated Offer';
  @override
  String get selected => 'Selected';
  @override
  String get confirmRecycler => 'Confirm Recycler';
  @override
  String get confirmOffer => 'Confirm Offer';
  @override
  String get noRecyclersFound => 'No Recyclers Found';
  @override
  String get lotDetails => 'Lot Details';
  @override
  String get viewTransaction => 'View Transaction';
  @override
  String get allLots => 'All Lots';
  @override
  String get pendingLots => 'Pending';
  @override
  String get inProgressLots => 'In Progress';
  @override
  String get completedLots => 'Completed';
  @override
  String get newLotRequests => 'New Lot Requests';
  @override
  String get noLotsAvailable => 'No Lots Available';
  @override
  String get incomingLotsSubtitle => 'Incoming collector scrap lots for you';
  @override
  String get noTransactionsFound => 'No Transactions Found';
  @override
  String get myEarningsAndTransactions => 'My Earnings & Transactions';
  @override
  String get transactionDetails => 'Transaction Details';
  @override
  String get earningsSummary => 'Earnings Summary';
  @override
  String get paymentPending => 'Payment Pending';
  @override
  String get paymentCompleted => 'Payment Completed';
  @override
  String get paymentFailed => 'Payment Failed';
  @override
  String get allTransactions => 'All Transactions';
  @override
  String get netPayable => 'Net Amount';
  @override
  String get viewDetails => 'View Details';
  @override
  String get settlementAmount => 'Settlement Amount';
  @override
  @override
  String get upiPayment => 'UPI';
  @override
  String get bankTransfer => 'Bank Transfer';
  @override
  String get collectorDashboardLoading => 'Loading dashboard...';
  @override
  String get collectorDashboardLoadError => 'Could not load dashboard';
  @override
  String get lotsLoading => 'Loading lots...';
  @override
  String get lotsLoadError => 'Failed to load lots';
  @override
  String get noLotsFound => 'No lots found';
  @override
  String get searchingRecyclers => 'Searching for recyclers...';
  @override
  String get searchingRecyclersSubtitle =>
      'Finding the nearest and best recyclers for your lot';
  @override
  String get recyclersLoadError => 'Failed to load recyclers';
  @override
  String get goBackAction => 'Go Back';
  @override
  String matchPercentageLabel(int pct) => 'Match: $pct%';
  @override
  String confirmOfferWithRecycler(String name) => 'Confirm Offer ($name)';
  @override
  String get noIncomingLots => 'No incoming lots right now';
  @override
  String get noIncomingLotsSubtitle => 'New lot requests will appear here.';
  @override
  String get refreshAction => 'Refresh';
  @override
  String get pickupRequested => 'Pickup Requested';
  @override
  String get recyclerLotsLoadError => 'Failed to load lots';
  @override
  String get kgUnit => 'kg';
  @override
  String get live => 'Live';
  @override
  String get statusCompletedDetailed => 'Completed';
  @override
  String get nameLabel => 'Full Name';
  @override
  String get nameHint => 'e.g. Rahul Sharma';
  @override
  String get phoneLabel => 'Mobile Number';
  @override
  String get phoneHint => '10-digit number';
  @override
  String get createAccount => 'Create Account';
}
