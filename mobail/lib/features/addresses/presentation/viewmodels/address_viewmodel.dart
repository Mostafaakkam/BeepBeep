import 'package:flutter/foundation.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/models/models.dart';

enum AddressState {
  initial,
  loading,
  success,
  error,
}

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository;
  
  AddressState _state = AddressState.initial;
  List<AddressModel> _addresses = [];
  AddressModel? _defaultAddress;
  String? _errorMessage;
  bool _isOperationInProgress = false;
  
  AddressViewModel({AddressRepository? repository})
      : _repository = repository ?? AddressRepository();
  
  AddressState get state => _state;
  List<AddressModel> get addresses => _addresses;
  AddressModel? get defaultAddress => _defaultAddress;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AddressState.loading;
  bool get isSuccess => _state == AddressState.success;
  bool get isError => _state == AddressState.error;
  bool get isOperationInProgress => _isOperationInProgress;
  bool get hasAddresses => _addresses.isNotEmpty;
  
  Future<void> loadAddresses() async {
    _state = AddressState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _addresses = await _repository.getAddresses();
      _defaultAddress = _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _addresses.isEmpty ? _addresses.first : _addresses.first,
      );
      _state = AddressState.success;
      notifyListeners();
    } catch (e) {
      _state = AddressState.error;
      _errorMessage = 'Failed to load addresses. Please try again.';
      _addresses = [];
      _defaultAddress = null;
      notifyListeners();
    }
  }
  
  Future<void> addAddress(AddressModel address) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.createAddress(address);
      await loadAddresses();
    } catch (e) {
      _errorMessage = 'Failed to add address. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> updateAddress(AddressModel address) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.updateAddress(address);
      await loadAddresses();
    } catch (e) {
      _errorMessage = 'Failed to update address. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteAddress(int id) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.deleteAddress(id);
      await loadAddresses();
    } catch (e) {
      _errorMessage = 'Failed to delete address. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> setDefaultAddress(int id) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    notifyListeners();
    
    try {
      await _repository.setDefaultAddress(id);
      await loadAddresses();
    } catch (e) {
      _errorMessage = 'Failed to set default address. Please try again.';
      notifyListeners();
    } finally {
      _isOperationInProgress = false;
      notifyListeners();
    }
  }
  
  Future<void> retry() async {
    await loadAddresses();
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
