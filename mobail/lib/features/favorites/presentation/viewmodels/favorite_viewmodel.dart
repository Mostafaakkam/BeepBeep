import 'package:flutter/foundation.dart';
import '../../../../data/repositories/favorite_repository.dart';

enum FavoriteState {
  initial,
  loading,
  success,
  error,
}

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;
  
  FavoriteState _state = FavoriteState.initial;
  List<dynamic> _favorites = [];
  Set<int> _favoriteProductIds = {};
  String? _errorMessage;
  bool _isOperationInProgress = false;
  
  FavoriteViewModel({FavoriteRepository? repository})
      : _repository = repository ?? FavoriteRepository();
  
  FavoriteState get state => _state;
  List<dynamic> get favorites => _favorites;
  Set<int> get favoriteProductIds => _favoriteProductIds;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == FavoriteState.loading;
  bool get isSuccess => _state == FavoriteState.success;
  bool get isError => _state == FavoriteState.error;
  bool get isOperationInProgress => _isOperationInProgress;
  bool get hasFavorites => _favorites.isNotEmpty;
  
  Future<void> loadFavorites() async {
    _state = FavoriteState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _favorites = await _repository.getFavorites();
      _favoriteProductIds = _favorites.map((f) => f['product_id'] as int).toSet();
      _state = FavoriteState.success;
      notifyListeners();
    } catch (e) {
      _state = FavoriteState.error;
      _errorMessage = 'Failed to load favorites. Please try again.';
      _favorites = [];
      _favoriteProductIds = {};
      notifyListeners();
    }
  }
  
  Future<void> addFavorite(int productId) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.addFavorite(productId);
      
      // Reload favorites to get updated state
      await loadFavorites();
    } catch (e) {
      _errorMessage = 'Failed to add favorite. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> removeFavorite(int productId) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.removeFavorite(productId);
      
      // Reload favorites to get updated state
      await loadFavorites();
    } catch (e) {
      _errorMessage = 'Failed to remove favorite. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<bool> checkFavorite(int productId) async {
    try {
      return await _repository.checkFavorite(productId);
    } catch (e) {
      return false;
    }
  }
  
  bool isFavorite(int productId) {
    return _favoriteProductIds.contains(productId);
  }
  
  Future<void> retry() async {
    await loadFavorites();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
