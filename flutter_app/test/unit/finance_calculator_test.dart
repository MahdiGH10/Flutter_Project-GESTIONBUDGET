import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/models/category_model.dart';
import 'package:gestion_budgetaire/models/budget_goal_model.dart';
import 'package:gestion_budgetaire/models/transaction_model.dart';
import 'package:gestion_budgetaire/utils/finance_calculator.dart';

void main() {
  group('FinanceCalculator', () {
    final transactions = <Transaction>[
      Transaction(
        id: 't1',
        title: 'Salary',
        amount: 3000,
        date: DateTime(2026, 3, 1),
        categoryId: 'salary',
        type: CategoryType.income,
      ),
      Transaction(
        id: 't2',
        title: 'Freelance',
        amount: 500,
        date: DateTime(2026, 3, 2),
        categoryId: 'freelance',
        type: CategoryType.income,
      ),
      Transaction(
        id: 't3',
        title: 'Groceries',
        amount: 120,
        date: DateTime(2026, 3, 3),
        categoryId: 'food',
        type: CategoryType.expense,
      ),
      Transaction(
        id: 't4',
        title: 'Restaurant',
        amount: 80,
        date: DateTime(2026, 3, 8),
        categoryId: 'food',
        type: CategoryType.expense,
      ),
      Transaction(
        id: 't5',
        title: 'Bus',
        amount: 30,
        date: DateTime(2026, 3, 9),
        categoryId: 'transport',
        type: CategoryType.expense,
      ),
      Transaction(
        id: 't6',
        title: 'Old month food',
        amount: 999,
        date: DateTime(2026, 2, 28),
        categoryId: 'food',
        type: CategoryType.expense,
      ),
    ];

    test('calculates balance correctly', () {
      final income = FinanceCalculator.totalIncome(transactions);
      final expense = FinanceCalculator.totalExpense(transactions);
      final balance = FinanceCalculator.balance(transactions);

      expect(income, 3500);
      expect(expense, 1229);
      expect(balance, 2271);
    });

    test('calculates category totals for expenses only', () {
      final totals = FinanceCalculator.expenseTotalsByCategory(transactions);

      expect(totals['food'], 1199);
      expect(totals['transport'], 30);
      expect(totals.containsKey('salary'), isFalse);
    });

    test('calculates monthly category spending for budget checks', () {
      final marchFood = FinanceCalculator.spentForCategoryInMonth(
        transactions,
        categoryId: 'food',
        month: DateTime(2026, 3, 1),
      );

      expect(marchFood, 200);
    });
  });

  group('BudgetGoal ceiling status', () {
    test('detects exceeded budget limit', () {
      final goal = BudgetGoal(
        id: 'g1',
        name: 'Food limit',
        categoryId: 'food',
        targetAmount: 150,
        currentAmount: 200,
        month: DateTime(2026, 3, 1),
      );

      expect(goal.isExceeded, isTrue);
      expect(goal.exceededBy, 50);
      expect(goal.isWarning, isFalse);
      expect(goal.isOnTrack, isFalse);
    });

    test('detects warning zone before exceed', () {
      final goal = BudgetGoal(
        id: 'g2',
        name: 'Transport limit',
        categoryId: 'transport',
        targetAmount: 100,
        currentAmount: 75,
        month: DateTime(2026, 3, 1),
      );

      expect(goal.isExceeded, isFalse);
      expect(goal.isWarning, isTrue);
      expect(goal.isOnTrack, isFalse);
      expect(goal.remaining, 25);
    });
  });
}
