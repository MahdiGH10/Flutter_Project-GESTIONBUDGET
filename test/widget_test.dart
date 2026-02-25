import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GestionBudgetaireApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
