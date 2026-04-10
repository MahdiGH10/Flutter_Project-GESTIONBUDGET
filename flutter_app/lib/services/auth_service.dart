import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  String _currencyKey(String uid) => 'user_currency_$uid';
  String _avatarKey(String uid) => 'user_avatar_$uid';

  Future<String> _loadCurrency(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey(uid)) ?? 'TND';
  }

  Future<String?> _loadAvatarUrl(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey(uid));
  }

  Future<void> _saveCurrency(String uid, String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey(uid), currency);
  }

  Future<void> _saveAvatarUrl(String uid, String? avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      await prefs.remove(_avatarKey(uid));
      return;
    }
    await prefs.setString(_avatarKey(uid), avatarUrl.trim());
  }

  /// Stream of auth state changes (login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Convert Firebase User to our UserModel
  UserModel _userFromFirebase(
    User firebaseUser, {
    String? displayName,
    String currency = 'TND',
    String? avatarUrl,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      fullName: displayName ?? firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      currency: currency,
      avatarUrl: avatarUrl,
    );
  }

  /// Try to restore session from existing Firebase user
  Future<UserModel?> tryAutoLogin() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final currency = await _loadCurrency(firebaseUser.uid);
      final avatarUrl = await _loadAvatarUrl(firebaseUser.uid);
      _currentUser = _userFromFirebase(
        firebaseUser,
        currency: currency,
        avatarUrl: avatarUrl,
      );
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
      final user = credential.user!;
      final currency = await _loadCurrency(user.uid);
      final avatarUrl = await _loadAvatarUrl(user.uid);
      _currentUser = _userFromFirebase(
        user,
        currency: currency,
        avatarUrl: avatarUrl,
      );
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

      await _saveCurrency(credential.user!.uid, currency);
      await _saveAvatarUrl(credential.user!.uid, null);
      _currentUser = _userFromFirebase(
        credential.user!,
        displayName: fullName,
        currency: currency,
        avatarUrl: null,
      );
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
    String? avatarUrl,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null || _currentUser == null) return;

    if (fullName != null && fullName.trim().isNotEmpty) {
      await firebaseUser.updateDisplayName(fullName.trim());
    }
    if (email != null && email.trim().isNotEmpty) {
      final normalizedEmail = email.trim();
      if (normalizedEmail != (firebaseUser.email ?? '').trim()) {
        await firebaseUser.verifyBeforeUpdateEmail(normalizedEmail);
      }
    }

    if (currency != null && currency.isNotEmpty) {
      await _saveCurrency(firebaseUser.uid, currency);
    }

    if (avatarUrl != null) {
      await _saveAvatarUrl(firebaseUser.uid, avatarUrl);
    }

    _currentUser = _currentUser!.copyWith(
      fullName: fullName?.trim(),
      email: email?.trim(),
      currency: currency,
      avatarUrl: avatarUrl,
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
