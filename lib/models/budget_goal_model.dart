class BudgetGoal {
  final String id;
  final String name;
  final String categoryId;
  final double targetAmount;
  final double currentAmount;
  final DateTime month; // year/month
  final bool isActive;

  BudgetGoal({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.month,
    this.isActive = true,
  });

  double get percentage =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  bool get isExceeded => currentAmount > targetAmount;
  bool get isWarning => percentage >= 70 && !isExceeded;
  bool get isOnTrack => !isExceeded && !isWarning;

  double get remaining =>
      (targetAmount - currentAmount).clamp(0, double.infinity);
  double get exceededBy => isExceeded ? currentAmount - targetAmount : 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'month': month.toIso8601String(),
    'isActive': isActive ? 1 : 0,
  };

  factory BudgetGoal.fromMap(Map<String, dynamic> map) => BudgetGoal(
    id: map['id'],
    name: map['name'],
    categoryId: map['categoryId'],
    targetAmount: (map['targetAmount'] as num).toDouble(),
    currentAmount: (map['currentAmount'] as num).toDouble(),
    month: DateTime.parse(map['month']),
    isActive: map['isActive'] == 1,
  );

  BudgetGoal copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    bool? isActive,
  }) => BudgetGoal(
    id: id,
    name: name ?? this.name,
    categoryId: categoryId,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    month: month,
    isActive: isActive ?? this.isActive,
  );
}
