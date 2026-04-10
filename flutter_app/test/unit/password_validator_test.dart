import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/utils/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('rejects weak passwords', () {
      expect(
        PasswordValidator.validateStrongPassword('abc123'),
        isNotNull,
      );
      expect(
        PasswordValidator.validateStrongPassword('Abcdef12'),
        isNotNull,
      );
      expect(
        PasswordValidator.validateStrongPassword('Abcdef!@'),
        isNotNull,
      );
    });

    test('accepts strong passwords', () {
      expect(
        PasswordValidator.validateStrongPassword('Abcdef1!'),
        isNull,
      );
    });

    test('validates email format', () {
      expect(PasswordValidator.isValidEmail('john@example.com'), isTrue);
      expect(PasswordValidator.isValidEmail('john@example'), isFalse);
      expect(PasswordValidator.isValidEmail(''), isFalse);
    });
  });
}
