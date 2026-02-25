import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  UserModel? _currentUser;
  final _uuid = const Uuid();

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulated user
    _currentUser = UserModel(
      id: _uuid.v4(),
      fullName: 'Alex Johnson',
      email: email,
      currency: 'TND',
    );
    return _currentUser!;
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String currency = 'TND',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: _uuid.v4(),
      fullName: fullName,
      email: email,
      currency: currency,
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? currency,
  }) async {
    if (_currentUser == null) return;
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      currency: currency,
    );
  }
}
