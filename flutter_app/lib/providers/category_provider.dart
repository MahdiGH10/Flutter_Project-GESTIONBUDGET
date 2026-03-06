import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  final List<Category> _customCategories = [];
  bool _isLoading = false;
  String? _userId;

  bool get isLoading => _isLoading;
  List<Category> get customCategories => List.unmodifiable(_customCategories);

  List<Category> categoriesByType(CategoryType type) {
    final defaults = DefaultCategories.all.where((c) => c.type == type);
    final custom = _customCategories.where((c) => c.type == type);
    return [...defaults, ...custom];
  }

  /// Load custom categories for [userId] from SQLite.
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    final loaded = await _repo.getCustomCategories(userId: userId);
    _customCategories
      ..clear()
      ..addAll(loaded);
    _isLoading = false;
    notifyListeners();
  }

  /// Clear data on logout.
  void clear() {
    _userId = null;
    _customCategories.clear();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    if (_userId == null) return;
    await _repo.insert(category, userId: _userId!);
    _customCategories.add(category);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    if (_userId == null) return;
    await _repo.delete(id);
    _customCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
