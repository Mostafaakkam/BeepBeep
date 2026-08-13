import 'package:flutter/foundation.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/models/models.dart';

enum ProductState {
  initial,
  loading,
  success,
  error,
}

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  
  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  String? _errorMessage;
  int? _storeId;
  
  ProductViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();
  
  ProductState get state => _state;
  List<Product> get products => _products;
  String? get errorMessage => _errorMessage;
  int? get storeId => _storeId;
  bool get isLoading => _state == ProductState.loading;
  bool get isSuccess => _state == ProductState.success;
  bool get isError => _state == ProductState.error;
  bool get isEmpty => _products.isEmpty;
  
  Future<void> loadProducts({int? storeId}) async {
    _state = ProductState.loading;
    _errorMessage = null;
    _storeId = storeId;
    notifyListeners();
    
    try {
      _products = await _repository.getAllProducts(storeId: storeId);
      _state = ProductState.success;
      notifyListeners();
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = 'Failed to load products. Please try again.';
      _products = [];
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadProducts(storeId: _storeId);
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
