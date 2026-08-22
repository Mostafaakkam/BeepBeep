import 'package:flutter/foundation.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/models.dart';

enum CategoryState {
  initial,
  loading,
  success,
  error,
}

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;
  
  CategoryState _state = CategoryState.initial;
  List<CategoryModel> _categories = [];
  String? _errorMessage;
  
  CategoryViewModel({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();
  
  CategoryState get state => _state;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CategoryState.loading;
  bool get isSuccess => _state == CategoryState.success;
  bool get isError => _state == CategoryState.error;
  bool get hasCategories => _categories.isNotEmpty;
  
  Future<void> loadCategories() async {
    _state = CategoryState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _categories = await _repository.getCategories();
      _state = CategoryState.success;
      notifyListeners();
    } catch (e) {
      _state = CategoryState.error;
      _errorMessage = 'Failed to load categories. Please try again.';
      _categories = [];
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadCategories();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
