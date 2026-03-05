import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Stream of auth state changes (login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Convert Firebase User to our UserModel
  UserModel _userFromFirebase(User firebaseUser, {String? displayName}) {
    return UserModel(
      id: firebaseUser.uid,
      fullName: displayName ?? firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      currency: 'TND',
    );
  }

  /// Try to restore session from existing Firebase user
  Future<UserModel?> tryAutoLogin() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      _currentUser = _userFromFirebase(firebaseUser);
      return _currentUser;
    }
    return null;
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = _userFromFirebase(credential.user!);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String currency = 'TND',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Set display name
      await credential.user!.updateDisplayName(fullName);

      _currentUser = _userFromFirebase(credential.user!, displayName: fullName);
      _currentUser = _currentUser!.copyWith(currency: currency);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? currency,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null || _currentUser == null) return;

    if (fullName != null) {
      await firebaseUser.updateDisplayName(fullName);
    }
    if (email != null) {
      await firebaseUser.verifyBeforeUpdateEmail(email);
    }

    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      currency: currency,
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre réseau.';
      default:
        return 'Une erreur est survenue ($code). Réessayez.';
    }
  }
}
