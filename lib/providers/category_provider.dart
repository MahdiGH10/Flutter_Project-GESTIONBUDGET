import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  static const _storageKey = 'custom_categories';
  final List<Category> _customCategories = [];
  bool _isLoading = true;

  CategoryProvider() {
    _load();
  }

  bool get isLoading => _isLoading;
  List<Category> get customCategories => List.unmodifiable(_customCategories);

  List<Category> categoriesByType(CategoryType type) {
    final defaults = DefaultCategories.all.where((c) => c.type == type);
    final custom = _customCategories.where((c) => c.type == type);
    return [...defaults, ...custom];
  }

  Future<void> addCategory(Category category) async {
    _customCategories.add(category);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _customCategories
        ..clear()
        ..addAll(
          decoded.map(
            (item) => Category.fromMap(item as Map<String, dynamic>),
          ),
        );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _customCategories.map((c) => c.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
