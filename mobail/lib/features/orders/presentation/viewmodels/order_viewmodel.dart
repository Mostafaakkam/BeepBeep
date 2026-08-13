import 'package:flutter/foundation.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/models/models.dart';

enum OrderState {
  initial,
  loading,
  success,
  error,
}

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  
  OrderState _state = OrderState.initial;
  List<Order> _orders = [];
  Order? _selectedOrder;
  String? _errorMessage;
  bool _isOperationInProgress = false;
  
  OrderViewModel({OrderRepository? repository})
      : _repository = repository ?? OrderRepository();
  
  OrderState get state => _state;
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == OrderState.loading;
  bool get isSuccess => _state == OrderState.success;
  bool get isError => _state == OrderState.error;
  bool get isOperationInProgress => _isOperationInProgress;
  bool get hasOrders => _orders.isNotEmpty;
  
  Future<void> loadOrders() async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _orders = await _repository.getOrders();
      _state = OrderState.success;
      notifyListeners();
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = 'Failed to load orders. Please try again.';
      _orders = [];
      notifyListeners();
    }
  }
  
  Future<void> loadOrderById(int orderId) async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _selectedOrder = await _repository.getOrderById(orderId);
      _state = OrderState.success;
      notifyListeners();
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = 'Failed to load order. Please try again.';
      _selectedOrder = null;
      notifyListeners();
    }
  }
  
  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
  }) async {
    if (_isOperationInProgress) {
      throw Exception('Operation in progress');
    }
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      final result = await _repository.createOrder(
        customerName: customerName,
        customerPhone: customerPhone,
        deliveryAddress: deliveryAddress,
      );
      
      // Reload orders to get updated list
      await loadOrders();
      
      return result;
    } catch (e) {
      _errorMessage = 'Failed to create order. Please try again.';
      notifyListeners();
      rethrow;
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> cancelOrder(int orderId) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.cancelOrder(orderId);
      
      // Reload orders to get updated list
      await loadOrders();
    } catch (e) {
      _errorMessage = 'Failed to cancel order. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadOrders();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
