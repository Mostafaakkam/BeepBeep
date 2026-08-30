import 'package:flutter/foundation.dart';
import '../../../../data/repositories/store_owner_repository.dart';
import '../../../../data/models/models.dart';

enum OwnerOrderState {
  initial,
  loading,
  success,
  error,
}

// Store Owner Dashboard: order list/detail/status-update for whichever store
// is currently selected. The forward-only status walk
// (pending->confirmed->preparing->shipped->delivered) is enforced
// server-side (orderService.VALID_TRANSITIONS is the single source of
// truth) -- nextValidStatus below only mirrors it for a nicer UI (offering
// just the one legal next step instead of a free-form picker), it is not
// itself an authorization or validation boundary.
class OwnerOrderViewModel extends ChangeNotifier {
  final StoreOwnerRepository _repository;

  static const Map<String, String?> _nextStatusMap = {
    'pending': 'confirmed',
    'confirmed': 'preparing',
    'preparing': 'shipped',
    'shipped': 'delivered',
    'delivered': null,
    'cancelled': null,
  };

  OwnerOrderState _state = OwnerOrderState.initial;
  List<Order> _orders = [];
  Order? _selectedOrder;
  String? _errorMessage;
  bool _isOperationInProgress = false;
  int? _storeId;

  OwnerOrderViewModel({StoreOwnerRepository? repository})
      : _repository = repository ?? StoreOwnerRepository();

  OwnerOrderState get state => _state;
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == OwnerOrderState.loading;
  bool get isSuccess => _state == OwnerOrderState.success;
  bool get isError => _state == OwnerOrderState.error;
  bool get isEmpty => _orders.isEmpty;
  bool get isOperationInProgress => _isOperationInProgress;

  static String? nextValidStatus(String currentStatus) => _nextStatusMap[currentStatus];

  Future<void> loadOrders(int storeId, {String? status}) async {
    _storeId = storeId;
    _state = OwnerOrderState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.getStoreOrders(storeId, status: status);
      _state = OwnerOrderState.success;
      notifyListeners();
    } catch (e) {
      _state = OwnerOrderState.error;
      _errorMessage = 'Failed to load orders. Please try again.';
      _orders = [];
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_storeId != null) {
      await loadOrders(_storeId!);
    }
  }

  Future<void> loadOrderDetail(int storeId, int orderId) async {
    _storeId = storeId;
    _state = OwnerOrderState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.getStoreOrderDetail(storeId, orderId);
      _state = OwnerOrderState.success;
      notifyListeners();
    } catch (e) {
      _state = OwnerOrderState.error;
      _errorMessage = 'Failed to load order. Please try again.';
      _selectedOrder = null;
      notifyListeners();
    }
  }

  Future<void> updateStatus(int storeId, int orderId, String newStatus) async {
    _isOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.updateOrderStatus(storeId: storeId, orderId: orderId, status: newStatus);
      await loadOrderDetail(storeId, orderId);
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
