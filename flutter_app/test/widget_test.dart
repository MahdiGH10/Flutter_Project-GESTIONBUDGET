import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/models/budget_goal_model.dart';

void main() {
  test('budget goal model smoke test', () {
    final goal = BudgetGoal(
      id: 'smoke',
      name: 'Smoke goal',
      categoryId: 'food',
      targetAmount: 100,
      currentAmount: 20,
      month: DateTime(2026, 3, 1),
    );

    expect(goal.isOnTrack, isTrue);
    expect(goal.remaining, 80);
  });
}
