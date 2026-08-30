import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';

// Store Owner Dashboard: single repository for every endpoint a store owner
// uses to manage their own store(s), products, and orders. Mirrors
// OrderRepository's convention of resolving the auth token internally via
// TokenStorage rather than requiring every call site to pass it explicitly.
// Every method here calls an endpoint that is authenticate + requireRole +
// (where applicable) requireStoreOwnership/requireProductOwnership on the
// backend (see routes/storeRoutes.js, routes/productRoutes.js) -- ownership
// is always re-verified server-side, never assumed here.
class StoreOwnerRepository {
  final ApiService _apiService;

  StoreOwnerRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<String> _requireToken() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return token;
  }

  /// The authenticated owner's own stores (GET /api/stores/mine).
  Future<List<Store>> getMyStores() async {
    try {
      final token = await _requireToken();
      final response = await _apiService.get(ApiConfig.storesMine, token: token);

      if (response['success'] == true && response['data'] != null) {
        final storesData = response['data'] as List<dynamic>;
        return storesData.map((s) => Store.fromJson(s as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Summary stats for one store's dashboard home
  /// (GET /api/stores/:storeId/dashboard).
  Future<DashboardStats> getDashboardStats(int storeId) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.get(
        '${ApiConfig.stores}/$storeId/dashboard',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return DashboardStats.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch dashboard stats');
    } catch (e) {
      rethrow;
    }
  }

  /// The owner's full product list for one store, including deactivated
  /// products (GET /api/stores/:storeId/products).
  Future<List<Product>> getStoreProducts(int storeId) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.get(
        '${ApiConfig.stores}/$storeId/products',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        final productsData = response['data'] as List<dynamic>;
        return productsData.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a product in the given store
  /// (POST /api/stores/:storeId/products). Returns the new product id.
  /// `variants` entries: {color?, size?, price, stock}. `images`: list of
  /// image path/URL strings -- matches the existing schema's product_images
  /// (id, image_path) and product_variants (id, color, size, price, stock)
  /// columns exactly; no new fields invented here.
  Future<int> createProduct({
    required int storeId,
    required String name,
    String? description,
    required int categoryId,
    required List<Map<String, dynamic>> variants,
    List<String> images = const [],
  }) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.post(
        '${ApiConfig.stores}/$storeId/products',
        {
          'name': name,
          'description': description,
          'categoryId': categoryId,
          'variants': variants,
          'images': images,
        },
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as Map<String, dynamic>)['id'] as int;
      }

      throw Exception(response['message'] ?? 'Failed to create product');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates a product already verified (server-side) to belong to the
  /// caller's store (PUT /api/products/:id). Existing variants are updated
  /// in place when a variant map includes its 'id'; variants without an
  /// 'id' are appended as new -- the backend never deletes a variant row
  /// through this endpoint (see productRepository.update's own comments).
  Future<void> updateProduct({
    required int productId,
    required String name,
    String? description,
    required int categoryId,
    required List<Map<String, dynamic>> variants,
    List<String> images = const [],
  }) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.put(
        '${ApiConfig.products}/$productId',
        {
          'name': name,
          'description': description,
          'categoryId': categoryId,
          'variants': variants,
          'images': images,
        },
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Soft-deletes (deactivates) a product already verified (server-side) to
  /// belong to the caller's store (PATCH /api/products/:id/deactivate).
  /// Never a hard delete -- see migration 003_add_product_is_active.sql.
  Future<void> deactivateProduct(int productId) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.patch(
        '${ApiConfig.products}/$productId/deactivate',
        {},
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to deactivate product');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Orders for one store (GET /api/stores/:storeId/orders) -- this endpoint
  /// predates the dashboard feature (Store Ownership work) and is reused
  /// as-is here.
  Future<List<Order>> getStoreOrders(int storeId, {String? status}) async {
    try {
      final token = await _requireToken();
      final query = status != null ? '?status=$status' : '';
      final response = await _apiService.get(
        '${ApiConfig.stores}/$storeId/orders$query',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        final ordersList = response['data'] as List<dynamic>;
        return ordersList.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Order detail scoped to one store
  /// (GET /api/stores/:storeId/orders/:orderId).
  Future<Order> getStoreOrderDetail(int storeId, int orderId) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.get(
        '${ApiConfig.stores}/$storeId/orders/$orderId',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch order');
    } catch (e) {
      rethrow;
    }
  }

  /// Validated order-status update
  /// (PATCH /api/stores/:storeId/orders/:orderId/status). The backend is the
  /// single source of truth for which transitions are legal
  /// (orderService.VALID_TRANSITIONS) -- this call can fail with a 400 and
  /// an INVALID_STATUS_TRANSITION code (surfaced via ApiException.code) even
  /// when the UI only offers valid-looking next steps, e.g. if the order
  /// changed status elsewhere in the meantime.
  Future<void> updateOrderStatus({
    required int storeId,
    required int orderId,
    required String status,
  }) async {
    try {
      final token = await _requireToken();
      final response = await _apiService.patch(
        '${ApiConfig.stores}/$storeId/orders/$orderId/status',
        {'status': status},
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
