class PasswordValidator {
  static String? validateStrongPassword(String password) {
    if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Le mot de passe doit contenir une lettre majuscule.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Le mot de passe doit contenir une lettre minuscule.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Le mot de passe doit contenir un chiffre.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\\/]').hasMatch(password)) {
      return 'Le mot de passe doit contenir un caractère spécial.';
    }
    if (password.contains(' ')) {
      return 'Le mot de passe ne doit pas contenir d’espace.';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
  }
}
