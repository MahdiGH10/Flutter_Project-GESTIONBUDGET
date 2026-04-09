import 'dart:async';

import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  final List<Category> _customCategories = [];
  StreamSubscription<List<Category>>? _subscription;
  bool _isLoading = false;
  String? _userId;

  bool get isLoading => _isLoading;
  List<Category> get customCategories => List.unmodifiable(_customCategories);

  bool isCustomCategory(String categoryId) {
    return _customCategories.any((c) => c.id == categoryId);
  }

  List<Category> categoriesByType(CategoryType type) {
    final defaults = DefaultCategories.all.where((c) => c.type == type);
    final custom = _customCategories.where((c) => c.type == type);
    return [...defaults, ...custom];
  }

  /// Load custom categories for [userId] from Firestore.
  Future<void> loadForUser(String userId) async {
    if (_userId == userId && _subscription != null) {
      return;
    }

    await _subscription?.cancel();
    _subscription = null;
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    final initialLoad = Completer<void>();
    _subscription = _repo.watchCustomCategories(userId: userId).listen(
      (loaded) {
        _customCategories
          ..clear()
          ..addAll(loaded);

        if (!initialLoad.isCompleted) {
          initialLoad.complete();
        }

        if (!_isLoading) {
          notifyListeners();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!initialLoad.isCompleted) {
          initialLoad.completeError(error, stackTrace);
        }
      },
    );

    try {
      await initialLoad.future;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear data on logout.
  void clear() {
    final sub = _subscription;
    _subscription = null;
    if (sub != null) {
      unawaited(sub.cancel());
    }
    _userId = null;
    _isLoading = false;
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
    await _repo.delete(id, userId: _userId!);
    _customCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    if (_userId == null) return;
    await _repo.update(category, userId: _userId!);
    final index = _customCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _customCategories[index] = category;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    final sub = _subscription;
    _subscription = null;
    if (sub != null) {
      unawaited(sub.cancel());
    }
    super.dispose();
  }
}
