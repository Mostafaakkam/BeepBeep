import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../../data/repositories/search_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _results;
  Timer? _debounceTimer;
  
  SearchViewModel({SearchRepository? repository})
      : _repository = repository ?? SearchRepository();
  
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get results => _results;
  List<dynamic> get products => _results?['products'] as List<dynamic>? ?? [];
  List<dynamic> get stores => _results?['stores'] as List<dynamic>? ?? [];
  bool get hasResults => (products.isNotEmpty || stores.isNotEmpty);
  bool get hasQuery => _query.isNotEmpty;
  
  void setQuery(String value) {
    _query = value;
    notifyListeners();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (value.isEmpty) {
      _results = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    // Debounce search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }
  
  void clearQuery() {
    _query = '';
    _results = null;
    _errorMessage = null;
    _isLoading = false;
    _debounceTimer?.cancel();
    notifyListeners();
  }
  
  Future<void> _performSearch() async {
    if (_query.trim().length < 2) {
      _results = {'products': [], 'stores': []};
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _results = await _repository.search(_query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Search failed. Please try again.';
      notifyListeners();
    }
  }
  
  void retry() {
    if (_query.isNotEmpty) {
      _performSearch();
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
