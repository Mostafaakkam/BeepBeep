import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بيب بيب';

  @override
  String get welcome => 'مرحباً بعودتك';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get home => 'الرئيسية';

  @override
  String get stores => 'المتاجر';

  @override
  String get products => 'المنتجات';

  @override
  String get cart => 'السلة';

  @override
  String get orders => 'الطلبات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get search => 'بحث';

  @override
  String get favorites => 'المفضلة';

  @override
  String get addresses => 'العناوين';

  @override
  String get categories => 'التصنيفات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get checkout => 'إتمام الشراء';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get apply => 'تطبيق الفلاتر';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارِ التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get noProducts => 'لا توجد منتجات متاحة';

  @override
  String get noStores => 'لا توجد متاجر متاحة';

  @override
  String get noOrders => 'لا توجد طلبات بعد';

  @override
  String get noFavorites => 'لا توجد عناصر مفضلة بعد';

  @override
  String get noAddresses => 'لا توجد عناوين بعد';

  @override
  String get noResults => 'لم يتم العثور على نتائج';

  @override
  String get emptyCart => 'سلتك فارغة';

  @override
  String get emptySearch => 'لم يتم العثور على نتائج';

  @override
  String get noCategories => 'لا توجد تصنيفات متاحة';

  @override
  String get orderPlaced => 'تم تقديم الطلب بنجاح!';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String get orderStatus => 'الحالة';

  @override
  String get total => 'الإجمالي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get preparing => 'قيد التجهيز';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'ملغى';

  @override
  String get addressLabel => 'التسمية';

  @override
  String get recipientName => 'اسم المستلم';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get defaultAddress => 'افتراضي';

  @override
  String get setDefault => 'تعيين كافتراضي';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productDescription => 'الوصف';

  @override
  String get price => 'السعر';

  @override
  String get stock => 'المخزون';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'نفدت الكمية';

  @override
  String get color => 'اللون';

  @override
  String get size => 'المقاس';

  @override
  String quantity(int quantity) {
    return 'x$quantity';
  }

  @override
  String get variant => 'النوع';

  @override
  String get images => 'الصور';

  @override
  String get reviews => 'التقييمات';

  @override
  String get rating => 'التقييم';

  @override
  String get noReviews => 'لا توجد تقييمات بعد';

  @override
  String get beFirstToReview => 'كن أول من يقيّم هذا المنتج';

  @override
  String get filter => 'تصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get newest => 'الأحدث';

  @override
  String get priceAsc => 'السعر: من الأقل إلى الأعلى';

  @override
  String get priceDesc => 'السعر: من الأعلى إلى الأقل';

  @override
  String get nameAsc => 'الاسم: أ إلى ي';

  @override
  String get nameDesc => 'الاسم: ي إلى أ';

  @override
  String get minPrice => 'أقل سعر';

  @override
  String get maxPrice => 'أعلى سعر';

  @override
  String get inStockOnly => 'المتوفر فقط';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get noMatchingProducts => 'لا توجد منتجات مطابقة للفلاتر';

  @override
  String get filterBy => 'تصفية حسب';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get discardChanges => 'تجاهل التغييرات';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get confirmation => 'تأكيد';

  @override
  String get success => 'تم بنجاح';

  @override
  String get failed => 'فشل';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get goBack => 'رجوع';

  @override
  String get continueShopping => 'متابعة التسوق';

  @override
  String get viewOrder => 'عرض الطلب';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get passwordHintCreate => 'أنشئ كلمة مرور';

  @override
  String get confirmPasswordHint => 'أكّد كلمة المرور';

  @override
  String get nameHint => 'أدخل اسمك الكامل';

  @override
  String get phoneHint => '+963 900 000 000';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟ ';

  @override
  String get haveAccountPrompt => 'لديك حساب بالفعل؟ ';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registrationSuccessful => 'تم التسجيل بنجاح';

  @override
  String get accountCreatedMessage => 'تم إنشاء حسابك بنجاح!';

  @override
  String get goToLogin => 'الذهاب لتسجيل الدخول';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get tagline => 'سوقك المحلي';

  @override
  String helloUser(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get discoverTagline => 'اكتشف أفضل المتاجر المحلية في حلب';

  @override
  String get searchPlaceholder => 'ابحث عن منتجات، متاجر...';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get featuredStores => 'متاجر مميزة';

  @override
  String get noStoresSubtitle => 'تحقق لاحقاً من المتاجر الجديدة';

  @override
  String nameValue(String value) {
    return 'الاسم: $value';
  }

  @override
  String roleValue(String value) {
    return 'الدور: $value';
  }

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get account => 'الحساب';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get myFavorites => 'مفضلتي';

  @override
  String get myAddresses => 'عناويني';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get comingSoonDescription => 'سيتم إضافة المزيد من ميزات الملف الشخصي في التحديثات القادمة.';

  @override
  String get logoutFailed => 'فشل تسجيل الخروج. يرجى المحاولة مرة أخرى.';

  @override
  String get language => 'اللغة';

  @override
  String get englishLanguage => 'الإنجليزية';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get shoppingCart => 'سلة التسوق';

  @override
  String get failedToLoadCart => 'فشل تحميل السلة';

  @override
  String get emptyCartSubtitle => 'أضف بعض المنتجات للبدء';

  @override
  String subtotalItems(int count) {
    return 'المجموع الفرعي ($count عناصر)';
  }

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get failedToLoadCategories => 'فشل تحميل التصنيفات';

  @override
  String get noCategoriesSubtitle => 'ستظهر التصنيفات هنا عند إضافتها';

  @override
  String get loginToViewFavorites => 'سجّل الدخول لعرض المفضلة';

  @override
  String get loginRequiredFavoritesMessage => 'يجب تسجيل الدخول لعرض منتجاتك المفضلة';

  @override
  String get failedToLoadFavorites => 'فشل تحميل المفضلة';

  @override
  String get noFavoritesSubtitle => 'ابدأ بإضافة منتجات إلى مفضلتك';

  @override
  String get loginToViewAddresses => 'سجّل الدخول لعرض العناوين';

  @override
  String get loginRequiredAddressesMessage => 'يجب تسجيل الدخول لعرض عناوينك';

  @override
  String get failedToLoadAddresses => 'فشل تحميل العناوين';

  @override
  String get noAddressesSubtitle => 'أضف أول عنوان توصيل لك';

  @override
  String get addNewAddress => 'إضافة عنوان جديد';

  @override
  String get deleteAddressTitle => 'حذف العنوان';

  @override
  String get deleteAddressConfirm => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get labelHint => 'مثال: المنزل، العمل';

  @override
  String get labelRequired => 'التسمية مطلوبة';

  @override
  String get recipientNameHint => 'أدخل اسم المستلم';

  @override
  String get recipientNameRequired => 'اسم المستلم مطلوب';

  @override
  String get phoneHintGeneric => 'أدخل رقم الهاتف';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get deliveryAddressHint => 'أدخل عنوان التوصيل';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get setAsDefaultAddress => 'تعيين كعنوان افتراضي';

  @override
  String get saving => 'جارِ الحفظ...';

  @override
  String get saveAddressButton => 'حفظ العنوان';

  @override
  String get failedToLoadStores => 'فشل تحميل المتاجر';

  @override
  String productsOf(String name) {
    return 'منتجات $name';
  }

  @override
  String get failedToLoadProducts => 'فشل تحميل المنتجات';

  @override
  String get adjustFiltersMessage => 'حاول تعديل الفلاتر أو مسحها';

  @override
  String get storeNoProductsMessage => 'لا يحتوي هذا المتجر على منتجات بعد';

  @override
  String get categoryNoProductsMessage => 'لا يحتوي هذا التصنيف على منتجات بعد';

  @override
  String get checkBackProductsMessage => 'تحقق لاحقاً من المنتجات الجديدة';

  @override
  String get productDetailsTitle => 'تفاصيل المنتج';

  @override
  String get loginToFavoritesMessage => 'يرجى تسجيل الدخول لإضافة المفضلة';

  @override
  String get updateFavoritesFailed => 'فشل تحديث المفضلة';

  @override
  String get failedToLoadProduct => 'فشل تحميل المنتج';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get selectVariantMessage => 'يرجى اختيار النوع أولاً';

  @override
  String get variantOutOfStockMessage => 'هذا النوع غير متوفر حالياً';

  @override
  String get addedToCartSuccess => 'تمت الإضافة إلى السلة بنجاح';

  @override
  String get addToCartFailed => 'فشلت إضافة المنتج إلى السلة. يرجى المحاولة مرة أخرى.';

  @override
  String get storeMismatchTitle => 'تبديل المتجر؟';

  @override
  String get storeMismatchMessage => 'تحتوي سلتك على منتجات من متجر آخر. هل تريد تفريغ السلة والتبديل إلى هذا المتجر؟';

  @override
  String get clearAndSwitchStore => 'تفريغ والتبديل';

  @override
  String get switchStoreFailed => 'فشل تبديل المتجر. يرجى المحاولة مرة أخرى.';

  @override
  String get availableVariants => 'الأنواع المتوفرة';

  @override
  String sizeValue(String size) {
    return 'المقاس: $size';
  }

  @override
  String stockCount(int stock) {
    return '(متوفر $stock)';
  }

  @override
  String get addingToCart => 'جارِ الإضافة...';

  @override
  String get filterProducts => 'تصفية المنتجات';

  @override
  String get priceRangeLabel => 'نطاق السعر';

  @override
  String get anyHint => 'أي';

  @override
  String get zeroPlaceholder => '0';

  @override
  String get searchHint => 'ابحث عن منتجات ومتاجر...';

  @override
  String get searching => 'جارِ البحث...';

  @override
  String get searchFailed => 'فشل البحث';

  @override
  String get searchPrompt => 'ابحث عن منتجات ومتاجر';

  @override
  String get searchMinChars => 'أدخل حرفين على الأقل للبحث';

  @override
  String get tryDifferentKeywords => 'جرّب كلمات مفتاحية مختلفة';

  @override
  String get failedToLoadOrders => 'فشل تحميل الطلبات';

  @override
  String get noOrdersSubtitle => 'ابدأ التسوق لتقديم طلبك الأول';

  @override
  String orderIdHeading(int id) {
    return 'الطلب رقم $id';
  }

  @override
  String get failedToLoadOrder => 'فشل تحميل الطلب';

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String get orderInformation => 'معلومات الطلب';

  @override
  String get customerInformation => 'معلومات العميل';

  @override
  String get paymentInformation => 'معلومات الدفع';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get orderTotals => 'إجمالي الطلب';

  @override
  String get cancelOrderConfirm => 'هل أنت متأكد من إلغاء هذا الطلب؟';

  @override
  String get yesCancelOrder => 'نعم، إلغاء';

  @override
  String get orderCancelledSuccess => 'تم إلغاء الطلب بنجاح';

  @override
  String get cancelOrderFailed => 'فشل إلغاء الطلب';

  @override
  String get thankYouOrder => 'شكراً لطلبك!';

  @override
  String get placeOrderFailed => 'فشل تقديم الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get emptyCartCheckoutSubtitle => 'أضف بعض المنتجات لإتمام الشراء';

  @override
  String get deliveryInformation => 'معلومات التوصيل';

  @override
  String get useSavedAddress => 'استخدام عنوان محفوظ';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get nameTooShort => 'الاسم قصير جداً';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get pleaseEnterPhone => 'يرجى إدخال رقم هاتفك';

  @override
  String get invalidPhoneNumber => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get pleaseEnterAddress => 'يرجى إدخال عنوان التوصيل';

  @override
  String get addressTooShort => 'العنوان قصير جداً';

  @override
  String get selectAddress => 'اختر عنواناً';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get payOnDeliveryDescription => 'ادفع عند استلام طلبك';

  @override
  String get placingOrder => 'جارِ تقديم الطلب...';

  @override
  String get placeOrder => 'تقديم الطلب';

  @override
  String get validatorNameRequired => 'الاسم مطلوب';

  @override
  String get validatorNameTooShort => 'يجب أن يتكون الاسم من حرفين على الأقل';

  @override
  String get validatorPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get validatorPhoneInvalid => 'رقم هاتف غير صالح';

  @override
  String get validatorEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validatorEmailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String get validatorPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validatorPasswordTooShort => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get validatorConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get validatorPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errorInvalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get errorPleaseCheckInput => 'يرجى التحقق من المدخلات والمحاولة مرة أخرى';

  @override
  String get errorNetworkCheckConnection => 'خطأ في الشبكة. يرجى التحقق من اتصالك';

  @override
  String get errorLoginFailedTryAgain => 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى';

  @override
  String get errorEmailAlreadyRegistered => 'البريد الإلكتروني مسجل بالفعل';

  @override
  String get errorPhoneAlreadyRegistered => 'رقم الهاتف مسجل بالفعل';

  @override
  String get errorRegistrationFailedTryAgain => 'فشل التسجيل. يرجى المحاولة مرة أخرى';

  @override
  String get seeAllStores => 'عرض الكل';

  @override
  String get writeAReview => 'اكتب تقييماً';

  @override
  String get editYourReview => 'تعديل تقييمك';

  @override
  String get yourReview => 'تقييمك';

  @override
  String get yourRating => 'تقييمك';

  @override
  String get yourReviewOptional => 'تقييمك (اختياري)';

  @override
  String get reviewCommentHint => 'شارك رأيك حول هذا المنتج...';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get pleaseSelectRating => 'يرجى اختيار تقييم';

  @override
  String get reviewSubmitFailed => 'فشل إرسال التقييم. يرجى المحاولة مرة أخرى.';

  @override
  String get reviewSubmittedSuccess => 'تم إرسال التقييم';

  @override
  String get reviewUpdatedSuccess => 'تم تحديث التقييم';

  @override
  String get reviewDeletedSuccess => 'تم حذف التقييم';

  @override
  String get reviewDeleteFailed => 'فشل حذف التقييم. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteReviewTitle => 'حذف التقييم';

  @override
  String get deleteReviewConfirmMessage => 'هل أنت متأكد من حذف تقييمك؟';

  @override
  String get loginToReviewMessage => 'سجّل الدخول لكتابة تقييم لهذا المنتج';

  @override
  String get purchaseRequiredMessage => 'يمكن فقط للعملاء الذين اشتروا واستلموا هذا المنتج ترك تقييم';

  @override
  String reviewCountLabel(int count) {
    return '($count تقييم)';
  }

  @override
  String get allReviews => 'جميع التقييمات';

  @override
  String get ratingAverage => 'متوسط التقييم';

  @override
  String get storeOwnerDashboard => 'لوحة تحكم صاحب المتجر';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get noOwnedStores => 'لا توجد متاجر بعد';

  @override
  String get noOwnedStoresMessage => 'لا تملك أي متجر حتى الآن';

  @override
  String get storeStatusActive => 'نشط';

  @override
  String get storeStatusInactive => 'غير نشط';

  @override
  String get selectAStoreFirst => 'يرجى اختيار متجر أولاً';

  @override
  String get noOwnedProducts => 'لا توجد منتجات بعد';

  @override
  String get noOwnedProductsMessage => 'أضف منتجك الأول للبدء';

  @override
  String get deactivateProduct => 'إلغاء تفعيل المنتج';

  @override
  String deactivateProductConfirm(String name) {
    return 'هل أنت متأكد أنك تريد إلغاء تفعيل \"$name\"؟';
  }

  @override
  String get productDeactivatedSuccess => 'تم إلغاء تفعيل المنتج';

  @override
  String get productDeactivateFailed => 'فشل إلغاء تفعيل المنتج. يرجى المحاولة مرة أخرى.';

  @override
  String get inactiveLabel => 'غير نشط';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String storeLabel(String name) {
    return 'المتجر: $name';
  }

  @override
  String get productNameRequired => 'اسم المنتج مطلوب';

  @override
  String get pleaseSelectCategory => 'يرجى اختيار فئة';

  @override
  String get atLeastOneVariantRequired => 'مطلوب متغير واحد على الأقل';

  @override
  String get invalidVariantPrice => 'يرجى إدخال سعر صحيح';

  @override
  String get invalidVariantStock => 'يرجى إدخال كمية مخزون صحيحة';

  @override
  String get existingVariantsCannotBeRemoved => 'لا يمكن إزالة المتغيرات الحالية من هنا';

  @override
  String get addVariant => 'إضافة متغير';

  @override
  String get imageUrlsHint => 'أدخل رابط صورة واحد في كل سطر';

  @override
  String get saveProduct => 'حفظ المنتج';

  @override
  String get category => 'الفئة';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get productCreatedSuccess => 'تم إنشاء المنتج';

  @override
  String get productUpdatedSuccess => 'تم تحديث المنتج';

  @override
  String get productCreateFailed => 'فشل إنشاء المنتج. يرجى المحاولة مرة أخرى.';

  @override
  String get productUpdateFailed => 'فشل تحديث المنتج. يرجى المحاولة مرة أخرى.';

  @override
  String get noOwnedOrders => 'لا توجد طلبات بعد';

  @override
  String get noOwnedOrdersMessage => 'ستظهر طلبات هذا المتجر هنا';

  @override
  String markOrderAs(String status) {
    return 'تحديد كـ $status';
  }

  @override
  String get orderStatusUpdatedSuccess => 'تم تحديث حالة الطلب';

  @override
  String get orderStatusUpdateFailed => 'فشل تحديث حالة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get storeOwnerWelcome => 'مرحباً بعودتك!';

  @override
  String get currentlyManaging => 'تدير حالياً';

  @override
  String get switchStore => 'تبديل';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get viewOrders => 'عرض الطلبات';
}
