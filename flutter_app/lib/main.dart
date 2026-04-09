import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_page.dart';
import 'views/dashboard/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GestionBudgetaireApp());
}

class GestionBudgetaireApp extends StatelessWidget {
  const GestionBudgetaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'DEVMOB – GestionBudgetaire',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Checks if user is already logged in via Firebase and routes accordingly.
/// After auth, loads all user-scoped data from Firestore.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _isLoadingUserData = false;
  String? _loadedForUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  /// Load all user-scoped data from Firestore after authentication.
  ///
  /// Important: the previous implementation used a single boolean latch.
  /// If the very first load failed (network/rules/permission), it could stay
  /// stuck forever with empty UI until logout. This version retries safely.
  Future<void> _loadUserDataIfNeeded(String userId) async {
    if (_isLoadingUserData) return;
    if (_loadedForUserId == userId) return;

    _isLoadingUserData = true;
    try {
      debugPrint(
        'AuthGate loading user data | project=${Firebase.app().options.projectId} | uid=$userId',
      );
      await Future.wait([
        context.read<TransactionProvider>().loadForUser(userId),
        context.read<BudgetProvider>().loadForUser(userId),
        context.read<CategoryProvider>().loadForUser(userId),
      ]);
      _loadedForUserId = userId;
    } catch (e, stackTrace) {
      _loadedForUserId = null;
      debugPrint('AuthGate user data load failed for $userId: $e');
      debugPrint('$stackTrace');
    } finally {
      _isLoadingUserData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show loading while checking auth state
        if (!auth.initialized) {
          return Scaffold(
            backgroundColor: AppTheme.primary900,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.success500,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppTheme.success500,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
          );
        }

        // Route based on auth state
        if (auth.isLoggedIn) {
          // Load user data from Firestore
          final userId = auth.currentUser?.id;
          if (userId != null) {
            _loadUserDataIfNeeded(userId);
          }
          return const HomeShell();
        }

        // Reset state so data reloads on next login
        _loadedForUserId = null;
        _isLoadingUserData = false;
        return const LoginPage();
      },
    );
  }
}
