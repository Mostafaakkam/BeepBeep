class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';

  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String me = '$auth/me';

  static const String reviews = '/reviews';

  static const String stores = '/stores';
  // Store Owner Dashboard: the authenticated owner's own stores. Registered
  // server-side BEFORE '/stores/:id' for the same reason this is a distinct
  // constant here -- it's a literal path segment, not a store id.
  static const String storesMine = '$stores/mine';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String cartSwitchStore = '/cart/switch-store';
  static const String orders = '/orders';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String addresses = '/addresses';
  static const String categories = '/categories';

  static const Duration timeout = Duration(seconds: 30);
}
