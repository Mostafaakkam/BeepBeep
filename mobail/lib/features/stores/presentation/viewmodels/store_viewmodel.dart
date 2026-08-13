import 'package:flutter/foundation.dart';
import '../../../../data/repositories/store_repository.dart';
import '../../../../data/models/models.dart';

enum StoreState {
  initial,
  loading,
  success,
  error,
}

class StoreViewModel extends ChangeNotifier {
  final StoreRepository _repository;
  
  StoreState _state = StoreState.initial;
  List<Store> _stores = [];
  String? _errorMessage;
  
  StoreViewModel({StoreRepository? repository})
      : _repository = repository ?? StoreRepository();
  
  StoreState get state => _state;
  List<Store> get stores => _stores;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == StoreState.loading;
  bool get isSuccess => _state == StoreState.success;
  bool get isError => _state == StoreState.error;
  bool get isEmpty => _stores.isEmpty;
  
  Future<void> loadStores() async {
    _state = StoreState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _stores = await _repository.getAllStores();
      _state = StoreState.success;
      notifyListeners();
    } catch (e) {
      _state = StoreState.error;
      _errorMessage = 'Failed to load stores. Please try again.';
      _stores = [];
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadStores();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
