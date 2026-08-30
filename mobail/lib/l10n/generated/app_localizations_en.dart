import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Beep Beep';

  @override
  String get welcome => 'Welcome back';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get home => 'Home';

  @override
  String get stores => 'Stores';

  @override
  String get products => 'Products';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get addresses => 'Addresses';

  @override
  String get categories => 'Categories';

  @override
  String get logout => 'Logout';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get clearAll => 'Clear All';

  @override
  String get apply => 'Apply Filters';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noProducts => 'No products available';

  @override
  String get noStores => 'No stores available';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noAddresses => 'No addresses yet';

  @override
  String get noResults => 'No results found';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get emptySearch => 'No results found';

  @override
  String get noCategories => 'No categories available';

  @override
  String get orderPlaced => 'Order Placed Successfully!';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get orderDate => 'Order Date';

  @override
  String get orderStatus => 'Status';

  @override
  String get total => 'Total';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get preparing => 'Preparing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get addressLabel => 'Label';

  @override
  String get recipientName => 'Recipient Name';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get defaultAddress => 'Default';

  @override
  String get setDefault => 'Set Default';

  @override
  String get addAddress => 'Add Address';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get productName => 'Product Name';

  @override
  String get productDescription => 'Description';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get color => 'Color';

  @override
  String get size => 'Size';

  @override
  String quantity(int quantity) {
    return 'x$quantity';
  }

  @override
  String get variant => 'Variant';

  @override
  String get images => 'Images';

  @override
  String get reviews => 'Reviews';

  @override
  String get rating => 'Rating';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to review this product';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort By';

  @override
  String get newest => 'Newest';

  @override
  String get priceAsc => 'Price: Low to High';

  @override
  String get priceDesc => 'Price: High to Low';

  @override
  String get nameAsc => 'Name: A to Z';

  @override
  String get nameDesc => 'Name: Z to A';

  @override
  String get minPrice => 'Min Price';

  @override
  String get maxPrice => 'Max Price';

  @override
  String get inStockOnly => 'In Stock Only';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get noMatchingProducts => 'No products match your filters';

  @override
  String get filterBy => 'Filter By';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get goBack => 'Go Back';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get viewOrder => 'View Order';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordHintCreate => 'Create a password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get phoneHint => '+963 900 000 000';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get haveAccountPrompt => 'Already have an account? ';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registrationSuccessful => 'Registration Successful';

  @override
  String get accountCreatedMessage => 'Your account has been created successfully!';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get tagline => 'Your Local Marketplace';

  @override
  String helloUser(String name) {
    return 'Hello, $name!';
  }

  @override
  String get discoverTagline => 'Discover the best local stores in Aleppo';

  @override
  String get searchPlaceholder => 'Search products, stores...';

  @override
  String get seeAll => 'See All';

  @override
  String get featuredStores => 'Featured Stores';

  @override
  String get noStoresSubtitle => 'Check back later for new stores';

  @override
  String nameValue(String value) {
    return 'Name: $value';
  }

  @override
  String roleValue(String value) {
    return 'Role: $value';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String get account => 'Account';

  @override
  String get myOrders => 'My Orders';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get comingSoonDescription => 'More profile features will be added in future updates.';

  @override
  String get logoutFailed => 'Logout failed. Please try again.';

  @override
  String get language => 'Language';

  @override
  String get englishLanguage => 'English';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get failedToLoadCart => 'Failed to load cart';

  @override
  String get emptyCartSubtitle => 'Add some products to get started';

  @override
  String subtotalItems(int count) {
    return 'Subtotal ($count items)';
  }

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get noCategoriesSubtitle => 'Categories will appear here when added';

  @override
  String get loginToViewFavorites => 'Login to View Favorites';

  @override
  String get loginRequiredFavoritesMessage => 'You need to be logged in to view your favorite products';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites';

  @override
  String get noFavoritesSubtitle => 'Start adding products to your favorites';

  @override
  String get loginToViewAddresses => 'Login to View Addresses';

  @override
  String get loginRequiredAddressesMessage => 'You need to be logged in to view your addresses';

  @override
  String get failedToLoadAddresses => 'Failed to load addresses';

  @override
  String get noAddressesSubtitle => 'Add your first delivery address';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get deleteAddressTitle => 'Delete Address';

  @override
  String get deleteAddressConfirm => 'Are you sure you want to delete this address?';

  @override
  String get labelHint => 'e.g., Home, Work';

  @override
  String get labelRequired => 'Label is required';

  @override
  String get recipientNameHint => 'Enter recipient name';

  @override
  String get recipientNameRequired => 'Recipient name is required';

  @override
  String get phoneHintGeneric => 'Enter phone number';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get deliveryAddressHint => 'Enter delivery address';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get setAsDefaultAddress => 'Set as default address';

  @override
  String get saving => 'Saving...';

  @override
  String get saveAddressButton => 'Save Address';

  @override
  String get failedToLoadStores => 'Failed to load stores';

  @override
  String productsOf(String name) {
    return '$name Products';
  }

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get adjustFiltersMessage => 'Try adjusting your filters or clearing them';

  @override
  String get storeNoProductsMessage => 'This store has no products yet';

  @override
  String get categoryNoProductsMessage => 'This category has no products yet';

  @override
  String get checkBackProductsMessage => 'Check back later for new products';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get loginToFavoritesMessage => 'Please login to add favorites';

  @override
  String get updateFavoritesFailed => 'Failed to update favorites';

  @override
  String get failedToLoadProduct => 'Failed to load product';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get selectVariantMessage => 'Please select a variant first';

  @override
  String get variantOutOfStockMessage => 'This variant is out of stock';

  @override
  String get addedToCartSuccess => 'Added to cart successfully';

  @override
  String get addToCartFailed => 'Failed to add to cart. Please try again.';

  @override
  String get storeMismatchTitle => 'Switch Store?';

  @override
  String get storeMismatchMessage => 'Your cart contains items from another store. Clear the cart and switch to this store?';

  @override
  String get clearAndSwitchStore => 'Clear & Switch';

  @override
  String get switchStoreFailed => 'Failed to switch store. Please try again.';

  @override
  String get availableVariants => 'Available Variants';

  @override
  String sizeValue(String size) {
    return 'Size: $size';
  }

  @override
  String stockCount(int stock) {
    return '($stock in stock)';
  }

  @override
  String get addingToCart => 'Adding...';

  @override
  String get filterProducts => 'Filter Products';

  @override
  String get priceRangeLabel => 'Price Range';

  @override
  String get anyHint => 'Any';

  @override
  String get zeroPlaceholder => '0';

  @override
  String get searchHint => 'Search products and stores...';

  @override
  String get searching => 'Searching...';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get searchPrompt => 'Search for products and stores';

  @override
  String get searchMinChars => 'Enter at least 2 characters to search';

  @override
  String get tryDifferentKeywords => 'Try different keywords';

  @override
  String get failedToLoadOrders => 'Failed to load orders';

  @override
  String get noOrdersSubtitle => 'Start shopping to place your first order';

  @override
  String orderIdHeading(int id) {
    return 'Order #$id';
  }

  @override
  String get failedToLoadOrder => 'Failed to load order';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderInformation => 'Order Information';

  @override
  String get customerInformation => 'Customer Information';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String get orderItems => 'Order Items';

  @override
  String get orderTotals => 'Order Totals';

  @override
  String get cancelOrderConfirm => 'Are you sure you want to cancel this order?';

  @override
  String get yesCancelOrder => 'Yes, Cancel';

  @override
  String get orderCancelledSuccess => 'Order cancelled successfully';

  @override
  String get cancelOrderFailed => 'Failed to cancel order';

  @override
  String get thankYouOrder => 'Thank you for your order!';

  @override
  String get placeOrderFailed => 'Failed to place order. Please try again.';

  @override
  String get emptyCartCheckoutSubtitle => 'Add some products to checkout';

  @override
  String get deliveryInformation => 'Delivery Information';

  @override
  String get useSavedAddress => 'Use saved address';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameTooShort => 'Name is too short';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pleaseEnterPhone => 'Please enter your phone number';

  @override
  String get invalidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get pleaseEnterAddress => 'Please enter your delivery address';

  @override
  String get addressTooShort => 'Address is too short';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get payOnDeliveryDescription => 'Pay when your order is delivered';

  @override
  String get placingOrder => 'Placing Order...';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get validatorNameRequired => 'Name is required';

  @override
  String get validatorNameTooShort => 'Name must be at least 2 characters';

  @override
  String get validatorPhoneRequired => 'Phone number is required';

  @override
  String get validatorPhoneInvalid => 'Invalid phone number';

  @override
  String get validatorEmailRequired => 'Email is required';

  @override
  String get validatorEmailInvalid => 'Invalid email address';

  @override
  String get validatorPasswordRequired => 'Password is required';

  @override
  String get validatorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get validatorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get validatorPasswordsMismatch => 'Passwords do not match';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorPleaseCheckInput => 'Please check your input and try again';

  @override
  String get errorNetworkCheckConnection => 'Network error. Please check your connection';

  @override
  String get errorLoginFailedTryAgain => 'Login failed. Please try again';

  @override
  String get errorEmailAlreadyRegistered => 'Email already registered';

  @override
  String get errorPhoneAlreadyRegistered => 'Phone number already registered';

  @override
  String get errorRegistrationFailedTryAgain => 'Registration failed. Please try again';

  @override
  String get seeAllStores => 'See all';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get editYourReview => 'Edit Your Review';

  @override
  String get yourReview => 'Your Review';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get yourReviewOptional => 'Your Review (optional)';

  @override
  String get reviewCommentHint => 'Share your thoughts about this product...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get reviewSubmitFailed => 'Failed to submit review. Please try again.';

  @override
  String get reviewSubmittedSuccess => 'Review submitted';

  @override
  String get reviewUpdatedSuccess => 'Review updated';

  @override
  String get reviewDeletedSuccess => 'Review deleted';

  @override
  String get reviewDeleteFailed => 'Failed to delete review. Please try again.';

  @override
  String get deleteReviewTitle => 'Delete Review';

  @override
  String get deleteReviewConfirmMessage => 'Are you sure you want to delete your review?';

  @override
  String get loginToReviewMessage => 'Login to write a review for this product';

  @override
  String get purchaseRequiredMessage => 'Only customers who purchased and received this product can leave a review';

  @override
  String reviewCountLabel(int count) {
    return '($count reviews)';
  }

  @override
  String get allReviews => 'All Reviews';

  @override
  String get ratingAverage => 'Rating Average';

  @override
  String get storeOwnerDashboard => 'Store Owner Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get noOwnedStores => 'No Stores Yet';

  @override
  String get noOwnedStoresMessage => 'You don\'t own any stores yet';

  @override
  String get storeStatusActive => 'Active';

  @override
  String get storeStatusInactive => 'Inactive';

  @override
  String get selectAStoreFirst => 'Please select a store first';

  @override
  String get noOwnedProducts => 'No Products Yet';

  @override
  String get noOwnedProductsMessage => 'Add your first product to get started';

  @override
  String get deactivateProduct => 'Deactivate Product';

  @override
  String deactivateProductConfirm(String name) {
    return 'Are you sure you want to deactivate \"$name\"?';
  }

  @override
  String get productDeactivatedSuccess => 'Product deactivated';

  @override
  String get productDeactivateFailed => 'Failed to deactivate product. Please try again.';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String storeLabel(String name) {
    return 'Store: $name';
  }

  @override
  String get productNameRequired => 'Product name is required';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get atLeastOneVariantRequired => 'At least one variant is required';

  @override
  String get invalidVariantPrice => 'Please enter a valid price';

  @override
  String get invalidVariantStock => 'Please enter a valid stock quantity';

  @override
  String get existingVariantsCannotBeRemoved => 'Existing variants can\'t be removed here';

  @override
  String get addVariant => 'Add Variant';

  @override
  String get imageUrlsHint => 'Enter one image URL per line';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get productCreatedSuccess => 'Product created';

  @override
  String get productUpdatedSuccess => 'Product updated';

  @override
  String get productCreateFailed => 'Failed to create product. Please try again.';

  @override
  String get productUpdateFailed => 'Failed to update product. Please try again.';

  @override
  String get noOwnedOrders => 'No Orders Yet';

  @override
  String get noOwnedOrdersMessage => 'Orders for this store will appear here';

  @override
  String markOrderAs(String status) {
    return 'Mark as $status';
  }

  @override
  String get orderStatusUpdatedSuccess => 'Order status updated';

  @override
  String get orderStatusUpdateFailed => 'Failed to update order status. Please try again.';

  @override
  String get storeOwnerWelcome => 'Welcome back!';

  @override
  String get currentlyManaging => 'Currently managing';

  @override
  String get switchStore => 'Switch';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get viewOrders => 'View Orders';
}
