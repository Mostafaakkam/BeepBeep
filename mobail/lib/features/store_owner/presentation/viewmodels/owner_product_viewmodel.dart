import 'package:flutter/foundation.dart';
import '../../../../data/repositories/store_owner_repository.dart';
import '../../../../data/models/models.dart';

enum OwnerProductState {
  initial,
  loading,
  success,
  error,
}

// Store Owner Dashboard: product list/create/update/deactivate for whichever
// store is currently selected (see StoreOwnerViewModel.selectedStore).
// Ownership of every product acted on here is re-verified server-side on
// every call (requireProductOwnership/requireStoreOwnership) -- this
// ViewModel never assumes the UI's own state is trustworthy.
class OwnerProductViewModel extends ChangeNotifier {
  final StoreOwnerRepository _repository;

  OwnerProductState _state = OwnerProductState.initial;
  List<Product> _products = [];
  String? _errorMessage;
  bool _isOperationInProgress = false;
  int? _storeId;

  OwnerProductViewModel({StoreOwnerRepository? repository})
      : _repository = repository ?? StoreOwnerRepository();

  OwnerProductState get state => _state;
  List<Product> get products => _products;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == OwnerProductState.loading;
  bool get isSuccess => _state == OwnerProductState.success;
  bool get isError => _state == OwnerProductState.error;
  bool get isEmpty => _products.isEmpty;
  bool get isOperationInProgress => _isOperationInProgress;

  Future<void> loadProducts(int storeId) async {
    _storeId = storeId;
    _state = OwnerProductState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getStoreProducts(storeId);
      _state = OwnerProductState.success;
      notifyListeners();
    } catch (e) {
      _state = OwnerProductState.error;
      _errorMessage = 'Failed to load products. Please try again.';
      _products = [];
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_storeId != null) {
      await loadProducts(_storeId!);
    }
  }

  Future<int> createProduct({
    required int storeId,
    required String name,
    String? description,
    required int categoryId,
    required List<Map<String, dynamic>> variants,
    List<String> images = const [],
  }) async {
    _isOperationInProgress = true;
    notifyListeners();

    try {
      final id = await _repository.createProduct(
        storeId: storeId,
        name: name,
        description: description,
        categoryId: categoryId,
        variants: variants,
        images: images,
      );
      await loadProducts(storeId);
      return id;
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    String? description,
    required int categoryId,
    required List<Map<String, dynamic>> variants,
    List<String> images = const [],
  }) async {
    _isOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.updateProduct(
        productId: productId,
        name: name,
        description: description,
        categoryId: categoryId,
        variants: variants,
        images: images,
      );
      if (_storeId != null) {
        await loadProducts(_storeId!);
      }
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }

  Future<void> deactivateProduct(int productId) async {
    _isOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.deactivateProduct(productId);
      if (_storeId != null) {
        await loadProducts(_storeId!);
      }
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
