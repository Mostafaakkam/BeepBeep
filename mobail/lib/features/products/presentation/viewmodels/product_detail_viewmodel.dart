import 'package:flutter/foundation.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/models/models.dart';

enum ProductDetailState {
  initial,
  loading,
  success,
  error,
}

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  
  ProductDetailState _state = ProductDetailState.initial;
  Product? _product;
  String? _errorMessage;
  
  ProductDetailViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();
  
  ProductDetailState get state => _state;
  Product? get product => _product;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProductDetailState.loading;
  bool get isSuccess => _state == ProductDetailState.success;
  bool get isError => _state == ProductDetailState.error;
  
  Future<void> loadProduct(int productId) async {
    _state = ProductDetailState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _product = await _repository.getProductById(productId);
      _state = ProductDetailState.success;
      notifyListeners();
    } catch (e) {
      _state = ProductDetailState.error;
      _errorMessage = 'Failed to load product details. Please try again.';
      _product = null;
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    if (_product != null) {
      await loadProduct(_product!.id);
    }
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
