import 'category_model.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;
  final CategoryType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.description,
  });

  bool get isIncome => type == CategoryType.income;
  bool get isExpense => type == CategoryType.expense;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'categoryId': categoryId,
    'description': description,
    'type': type.name,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'],
    title: map['title'],
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date']),
    categoryId: map['categoryId'],
    description: map['description'],
    type: CategoryType.values.byName(map['type']),
  );

  Transaction copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? description,
    CategoryType? type,
  }) => Transaction(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    type: type ?? this.type,
  );
}
