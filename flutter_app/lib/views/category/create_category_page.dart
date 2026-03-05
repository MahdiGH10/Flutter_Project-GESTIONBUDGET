import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../theme/app_theme.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _uuid = const Uuid();
  CategoryType _type = CategoryType.expense;
  IconData _selectedIcon = Icons.receipt_long;
  Color _selectedColor = AppTheme.primary900;
  late AnimationController _animController;

  final _icons = <IconData>[
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.home,
    Icons.school,
    Icons.health_and_safety,
    Icons.sports_gymnastics,
    Icons.movie,
    Icons.local_gas_station,
    Icons.savings,
    Icons.attach_money,
    Icons.card_giftcard,
  ];

  final _colors = <Color>[
    AppTheme.primary900,
    AppTheme.success500,
    AppTheme.danger500,
    const Color(0xFF4ECDC4),
    const Color(0xFFFF6B6B),
    const Color(0xFF45B7D1),
    const Color(0xFF96CEB4),
    const Color(0xFFF7DC6F),
    const Color(0xFFDDA0DD),
    const Color(0xFF98D8C8),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a category name.'),
          backgroundColor: AppTheme.danger500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final category = Category(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      type: _type,
    );
    await context.read<CategoryProvider>().addCategory(category);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral100,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOut,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.neutral900),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'New Category',
                        textAlign: TextAlign.center,
                        style: AppTheme.h3SemiBold.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type', style: AppTheme.captionRegular),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.neutral100,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            _TypeToggle(
                              label: 'Expense',
                              isActive: _type == CategoryType.expense,
                              color: AppTheme.danger500,
                              onTap: () => setState(() {
                                _type = CategoryType.expense;
                              }),
                            ),
                            _TypeToggle(
                              label: 'Income',
                              isActive: _type == CategoryType.income,
                              color: AppTheme.success500,
                              onTap: () => setState(() {
                                _type = CategoryType.income;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Name', style: AppTheme.captionRegular),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Category name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Icon', style: AppTheme.captionRegular),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _icons.map((icon) {
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary900
                                      : AppTheme.neutral200,
                                ),
                                boxShadow: AppTheme.shadowSm,
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? AppTheme.primary900
                                    : AppTheme.neutral500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Color', style: AppTheme.captionRegular),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _colors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.neutral900
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text('Create Category'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? AppTheme.shadowSm : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.captionMedium.copyWith(
              color: isActive ? color : AppTheme.neutral500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
