import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;
  final double budget;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.budget = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'iconCodePoint': icon.codePoint,
    'colorValue': color.value,
    'type': type.name,
    'budget': budget,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
    color: Color(map['colorValue']),
    type: CategoryType.values.byName(map['type']),
    budget: (map['budget'] ?? 0).toDouble(),
  );

  Category copyWith({
    String? name,
    IconData? icon,
    Color? color,
    double? budget,
  }) => Category(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type,
    budget: budget ?? this.budget,
  );
}

// Default categories matching the design tokens
class DefaultCategories {
  static const List<Category> expenses = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B6B),
      type: CategoryType.expense,
      budget: 400,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF4ECDC4),
      type: CategoryType.expense,
      budget: 200,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFF45B7D1),
      type: CategoryType.expense,
      budget: 300,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.flash_on,
      color: Color(0xFF96CEB4),
      type: CategoryType.expense,
      budget: 150,
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite,
      color: Color(0xFFFFEAA7),
      type: CategoryType.expense,
      budget: 100,
    ),
    Category(
      id: 'housing',
      name: 'Housing',
      icon: Icons.home,
      color: Color(0xFFDDA0DD),
      type: CategoryType.expense,
      budget: 800,
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt,
      color: Color(0xFF98D8C8),
      type: CategoryType.expense,
      budget: 150,
    ),
    Category(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFFF7DC6F),
      type: CategoryType.expense,
      budget: 200,
    ),
  ];

  static const List<Category> incomes = [
    Category(
      id: 'salary',
      name: 'Salary',
      icon: Icons.business_center,
      color: Color(0xFF4CD964),
      type: CategoryType.income,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac,
      color: Color(0xFF2ECC71),
      type: CategoryType.income,
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up,
      color: Color(0xFF27AE60),
      type: CategoryType.income,
    ),
    Category(
      id: 'gift',
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: Color(0xFF1ABC9C),
      type: CategoryType.income,
    ),
    Category(
      id: 'other_income',
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFF4CD964),
      type: CategoryType.income,
    ),
  ];

  static List<Category> get all => [...expenses, ...incomes];
}
