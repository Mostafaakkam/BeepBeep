import 'package:flutter/foundation.dart';
import '../../../../data/repositories/store_owner_repository.dart';
import '../../../../data/models/models.dart';

enum StoreOwnerState {
  initial,
  loading,
  success,
  error,
}

// Store Owner Dashboard: owns the "which store am I currently managing"
// selection shared by every tab in the dashboard shell (Dashboard, Products,
// Orders, Stores all read `selectedStore` from one instance of this
// ViewModel -- see StoreOwnerHomePage, which creates it once and passes it
// down). Switching stores here is what the Product/Order tabs react to.
class StoreOwnerViewModel extends ChangeNotifier {
  final StoreOwnerRepository _repository;

  StoreOwnerState _state = StoreOwnerState.initial;
  List<Store> _myStores = [];
  Store? _selectedStore;
  String? _errorMessage;

  StoreOwnerState _statsState = StoreOwnerState.initial;
  DashboardStats? _dashboardStats;

  StoreOwnerViewModel({StoreOwnerRepository? repository})
      : _repository = repository ?? StoreOwnerRepository();

  StoreOwnerState get state => _state;
  List<Store> get myStores => _myStores;
  Store? get selectedStore => _selectedStore;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == StoreOwnerState.loading;
  bool get isSuccess => _state == StoreOwnerState.success;
  bool get isError => _state == StoreOwnerState.error;
  bool get hasMultipleStores => _myStores.length > 1;

  StoreOwnerState get statsState => _statsState;
  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoadingStats => _statsState == StoreOwnerState.loading;

  Future<void> loadMyStores() async {
    _state = StoreOwnerState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _myStores = await _repository.getMyStores();
      _state = StoreOwnerState.success;

      // Auto-select a store so the Dashboard/Products/Orders tabs always
      // have something to show without requiring an extra tap for the
      // common single-store-owner case. A previously selected store (still
      // present in the refreshed list) is kept rather than reset.
      if (_myStores.isNotEmpty) {
        final stillValid = _selectedStore != null &&
            _myStores.any((s) => s.id == _selectedStore!.id);
        if (!stillValid) {
          _selectedStore = _myStores.first;
        }
        notifyListeners();
        await loadDashboardStats();
      } else {
        _selectedStore = null;
        notifyListeners();
      }
    } catch (e) {
      _state = StoreOwnerState.error;
      _errorMessage = 'Failed to load your stores. Please try again.';
      _myStores = [];
      notifyListeners();
    }
  }

  void selectStore(Store store) {
    if (_selectedStore?.id == store.id) return;
    _selectedStore = store;
    notifyListeners();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    final store = _selectedStore;
    if (store == null) return;

    _statsState = StoreOwnerState.loading;
    notifyListeners();

    try {
      _dashboardStats = await _repository.getDashboardStats(store.id);
      _statsState = StoreOwnerState.success;
    } catch (e) {
      _statsState = StoreOwnerState.error;
      _dashboardStats = null;
    }
    notifyListeners();
  }

  Future<void> retry() async {
    await loadMyStores();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
