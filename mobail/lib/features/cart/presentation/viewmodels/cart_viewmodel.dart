import 'package:flutter/foundation.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/models/models.dart';

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
    } catch (e) {
      _errorMessage = 'Failed to add item to cart. Please try again.';
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
