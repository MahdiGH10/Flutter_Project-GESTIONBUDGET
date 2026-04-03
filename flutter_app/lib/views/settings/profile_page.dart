import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_page.dart';
import 'budget_goal_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  late AnimationController _animController;

  static const Map<String, String> _currencyOptions = {
    'TND': 'TND - Tunisian Dinar',
    'USD': 'USD - US Dollar',
    'EUR': 'EUR - Euro',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _currencyLabel(String? code) {
    if (code == null || code.isEmpty) return 'TND - Tunisian Dinar';
    return _currencyOptions[code] ?? code;
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showEditProfileDialog(AuthProvider authProvider) async {
    final nameController = TextEditingController(
      text: authProvider.currentUser?.fullName ?? '',
    );
    final emailController = TextEditingController(
      text: authProvider.currentUser?.email ?? '',
    );

    final payload = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Account Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, {
                  'fullName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || payload == null) return;

    final success = await authProvider.updateProfile(
      fullName: payload['fullName'],
      email: payload['email'],
    );

    if (!mounted) return;

    if (success) {
      _showInfoSnackBar('Profile updated successfully.');
    } else {
      _showInfoSnackBar(authProvider.error ?? 'Failed to update profile.');
      authProvider.clearError();
    }
  }

  Future<void> _showCurrencyPicker(AuthProvider authProvider) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final current = authProvider.currentUser?.currency ?? 'TND';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose currency', style: AppTheme.h3SemiBold),
                const SizedBox(height: 8),
                ..._currencyOptions.entries.map(
                  (entry) => ListTile(
                    title: Text(entry.value),
                    trailing: current == entry.key
                        ? const Icon(Icons.check, color: AppTheme.success500)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, entry.key),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    final success = await authProvider.updateProfile(currency: selected);
    if (!mounted) return;

    if (success) {
      _showInfoSnackBar('Currency updated to ${_currencyLabel(selected)}.');
    } else {
      _showInfoSnackBar(authProvider.error ?? 'Failed to update currency.');
      authProvider.clearError();
    }
  }

  void _handleMenuTap(_ProfileAction action, AuthProvider authProvider) {
    switch (action) {
      case _ProfileAction.account:
        _showEditProfileDialog(authProvider);
        return;
      case _ProfileAction.notifications:
        _showInfoSnackBar('Notifications settings are coming soon.');
        return;
      case _ProfileAction.currency:
        _showCurrencyPicker(authProvider);
        return;
      case _ProfileAction.darkMode:
        return;
      case _ProfileAction.budgetGoals:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BudgetGoalPage()));
        return;
      case _ProfileAction.privacy:
        _showInfoSnackBar('Privacy & security settings are coming soon.');
        return;
      case _ProfileAction.support:
        _showInfoSnackBar('Help & support is coming soon.');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final txnProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final user = authProvider.currentUser;
    final userName = user?.fullName ?? 'User';
    final userEmail = user?.email ?? '';
    final userInitials = user?.initials ?? '?';
    final userCurrency = _currencyLabel(user?.currency);

    final allCategories = [
      ...categoryProvider.categoriesByType(CategoryType.expense),
      ...categoryProvider.categoriesByType(CategoryType.income),
    ];
    final uniqueCategoryCount = {for (final c in allCategories) c.id: c}.length;

    final menuItems = [
      _MenuItem(
        action: _ProfileAction.account,
        icon: Icons.person_outline,
        name: 'Account Settings',
        subtitle: 'Edit name and email',
      ),
      _MenuItem(
        action: _ProfileAction.notifications,
        icon: Icons.notifications_none,
        name: 'Notifications',
        subtitle: 'Push, email, SMS',
      ),
      _MenuItem(
        action: _ProfileAction.currency,
        icon: Icons.language,
        name: 'Currency',
        subtitle: userCurrency,
      ),
      _MenuItem(
        action: _ProfileAction.budgetGoals,
        icon: Icons.track_changes,
        name: 'Budget Goals',
        subtitle: 'Manage your monthly limits',
      ),
      _MenuItem(
        action: _ProfileAction.darkMode,
        icon: Icons.dark_mode_outlined,
        name: 'Dark Mode',
        subtitle: 'System default',
        isToggle: true,
      ),
      _MenuItem(
        action: _ProfileAction.privacy,
        icon: Icons.shield_outlined,
        name: 'Privacy & Security',
        subtitle: 'Coming soon',
      ),
      _MenuItem(
        action: _ProfileAction.support,
        icon: Icons.help_outline,
        name: 'Help & Support',
        subtitle: 'Coming soon',
      ),
    ];

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Text('Profile', style: AppTheme.h2Bold.copyWith(fontSize: 20)),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.neutral900,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile Card
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animController,
              curve: const Interval(0.0, 0.4),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.success500, Color(0xFF2ECC71)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userInitials,
                            style: AppTheme.h1Bold.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary900,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(userName, style: AppTheme.h3SemiBold),
                  const SizedBox(height: 4),
                  Text(userEmail, style: AppTheme.captionRegular),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileStat(
                        label: 'Transactions',
                        value: '${txnProvider.transactions.length}',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppTheme.neutral200,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _ProfileStat(
                        label: 'Categories',
                        value: '$uniqueCategoryCount',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppTheme.neutral200,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _ProfileStat(
                        label: 'Goals',
                        value: '${budgetProvider.goals.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Settings title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'SETTINGS',
              style: AppTheme.smallMedium.copyWith(
                color: AppTheme.neutral500,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Menu Items
        SliverToBoxAdapter(
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
                  ),
                ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.3, 0.6),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  children: menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: item.isToggle
                                ? null
                                : () =>
                                      _handleMenuTap(item.action, authProvider),
                            borderRadius: BorderRadius.vertical(
                              top: index == 0
                                  ? const Radius.circular(24)
                                  : Radius.zero,
                              bottom: index == menuItems.length - 1
                                  ? const Radius.circular(24)
                                  : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.neutral100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: AppTheme.neutral700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: AppTheme.bodySemiBold.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (!item.isToggle)
                                          Text(
                                            item.subtitle,
                                            style: AppTheme.smallMedium
                                                .copyWith(
                                                  color: AppTheme.neutral500,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (item.isToggle)
                                    Switch(
                                      value: _darkMode,
                                      onChanged: (v) =>
                                          setState(() => _darkMode = v),
                                      activeThumbColor: AppTheme.success500,
                                    )
                                  else
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppTheme.neutral400,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (index < menuItems.length - 1)
                          const Divider(
                            height: 1,
                            indent: 72,
                            color: AppTheme.neutral200,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        // Logout button
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animController,
              curve: const Interval(0.6, 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Clear all user-scoped data
                    context.read<TransactionProvider>().clear();
                    context.read<BudgetProvider>().clear();
                    context.read<CategoryProvider>().clear();
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger500.withValues(alpha: 0.1),
                    foregroundColor: AppTheme.danger500,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: AppTheme.bodySemiBold.copyWith(
                          color: AppTheme.danger500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.h3SemiBold),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.smallMedium),
      ],
    );
  }
}

class _MenuItem {
  final _ProfileAction action;
  final IconData icon;
  final String name;
  final String subtitle;
  final bool isToggle;

  _MenuItem({
    required this.action,
    required this.icon,
    required this.name,
    required this.subtitle,
    this.isToggle = false,
  });
}

enum _ProfileAction {
  account,
  notifications,
  currency,
  budgetGoals,
  darkMode,
  privacy,
  support,
}
