import 'package:flutter/foundation.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/models.dart';

enum ProductState {
  initial,
  loading,
  success,
  error,
}

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final CategoryRepository _categoryRepository;
  
  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  String? _errorMessage;
  ProductFilter _filter = ProductFilter();
  
  ProductViewModel({ProductRepository? repository, CategoryRepository? categoryRepository})
      : _repository = repository ?? ProductRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();
  
  ProductState get state => _state;
  List<Product> get products => _products;
  String? get errorMessage => _errorMessage;
  ProductFilter get filter => _filter;
  bool get isLoading => _state == ProductState.loading;
  bool get isSuccess => _state == ProductState.success;
  bool get isError => _state == ProductState.error;
  bool get isEmpty => _products.isEmpty;
  bool get hasFilters => _filter.hasFilters;
  
  Future<void> loadProducts({int? storeId, int? categoryId, String? storeName, String? categoryName}) async {
    _state = ProductState.loading;
    _errorMessage = null;
    
    // Update filter with navigation parameters
    if (storeId != null || categoryId != null) {
      _filter = _filter.copyWith(
        storeId: storeId,
        storeName: storeName,
        categoryId: categoryId,
        categoryName: categoryName,
      );
    }
    
    notifyListeners();
    
    try {
      _products = await _repository.getAllProducts(
        storeId: _filter.storeId,
        categoryId: _filter.categoryId,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        inStock: _filter.inStock,
        sortBy: _filter.sortBy,
      );
      _state = ProductState.success;
      notifyListeners();
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = 'Failed to load products. Please try again.';
      _products = [];
      notifyListeners();
    }
  }
  
  Future<void> applyFilter(ProductFilter newFilter) async {
    _filter = newFilter;
    await loadProducts();
  }
  
  Future<void> clearFilters() async {
    _filter = _filter.clearFilters();
    await loadProducts();
  }
  
  Future<void> retry() async {
    await loadProducts();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    _categoryRepository.dispose();
    super.dispose();
  }
}
