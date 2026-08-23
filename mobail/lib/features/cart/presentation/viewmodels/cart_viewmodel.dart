import 'package:flutter/foundation.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/models/models.dart';
import '../../../../data/services/api_service.dart';

// Single-Store Cart Rule: thrown by CartViewModel.addItem when the backend
// rejects a cross-store add with STORE_MISMATCH (see
// backend/src/controllers/cartController.js). Carries the same
// currentStore/requestedStore info the backend returns in `data`, so the
// UI (product_details_page.dart) can show a confirmation dialog naming
// both stores. Kept separate from the generic error-message flow below so
// existing add-to-cart error handling for every other failure is
// unchanged.
class StoreMismatchException implements Exception {
  final Map<String, dynamic>? currentStore;
  final Map<String, dynamic>? requestedStore;

  StoreMismatchException({this.currentStore, this.requestedStore});
}

enum CartState {
  initial,
  loading,
  success,
  error,
}

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  
  CartState _state = CartState.initial;
  Cart? _cart;
  String? _errorMessage;
  bool _isOperationInProgress = false;
  
  CartViewModel({CartRepository? repository})
      : _repository = repository ?? CartRepository();
  
  CartState get state => _state;
  Cart? get cart => _cart;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CartState.loading;
  bool get isSuccess => _state == CartState.success;
  bool get isError => _state == CartState.error;
  bool get isEmpty => _cart?.isEmpty ?? true;
  bool get isOperationInProgress => _isOperationInProgress;
  int get itemCount => _cart?.itemsCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0;
  double get total => _cart?.total ?? 0;
  
  Future<void> loadCart() async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _cart = await _repository.getCart();
      _state = CartState.success;
      notifyListeners();
    } catch (e) {
      _state = CartState.error;
      _errorMessage = 'Failed to load cart. Please try again.';
      _cart = null;
      notifyListeners();
    }
  }
  
  Future<void> addItem({
    required int productId,
    required int variantId,
    required int quantity,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.addItem(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      // Reload cart to get updated state
      await loadCart();
    } on ApiException catch (e) {
      // Single-Store Cart Rule: STORE_MISMATCH is not a generic failure --
      // the caller (product_details_page.dart) needs the current/requested
      // store info to show a confirmation dialog, so it is rethrown as a
      // typed exception instead of being folded into _errorMessage like
      // every other error below. The cart itself is left untouched by the
      // backend on this rejection, so there is nothing to reload.
      if (e.code == 'STORE_MISMATCH') {
        throw StoreMismatchException(
          currentStore: e.data?['currentStore'] as Map<String, dynamic>?,
          requestedStore: e.data?['requestedStore'] as Map<String, dynamic>?,
        );
      }
      _errorMessage = 'Failed to add item to cart. Please try again.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add item to cart. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }

  // Single-Store Cart Rule: atomic clear-and-add used when the customer
  // confirms "clear cart and switch stores" after a StoreMismatchException.
  // Mirrors addItem's loading/error handling; does not itself catch
  // STORE_MISMATCH since a same-item switch cannot mismatch against itself.
  Future<void> switchStore({
    required int productId,
    required int variantId,
    required int quantity,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.switchStore(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      // Reload cart to get updated state
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to switch store. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.updateItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      
      // Reload cart to get updated state
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to update cart. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> removeItem(int cartItemId) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.removeItem(cartItemId);
      
      // Reload cart to get updated state
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to remove item. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> clearCart() async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.clearCart();
      
      // Reload cart to get updated state
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to clear cart. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadCart();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
