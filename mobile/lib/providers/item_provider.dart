import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class ItemProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _isHealthy = false;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isHealthy => _isHealthy;

  Future<void> checkHealth() async {
    _isHealthy = await _apiService.checkHealth();
    notifyListeners();
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _apiService.getItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String name, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = await _apiService.createItem(name, description);
      _items.insert(0, newItem);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

