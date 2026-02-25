import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  CategoryType _type = CategoryType.expense;
  String _amount = '0';
  String? _selectedCategoryId;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animController;

  List<Category> get _categories => _type == CategoryType.income
      ? DefaultCategories.incomes
      : DefaultCategories.expenses;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleNumberPress(String num) {
    setState(() {
      if (_amount == '0' && num != '.') {
        _amount = num;
      } else if (num == '.' && _amount.contains('.')) {
        return;
      } else {
        _amount += num;
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _handleSubmit() {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            amount == null || amount <= 0
                ? 'Please enter a valid amount'
                : 'Please select a category',
          ),
          backgroundColor: AppTheme.danger500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final cat = _categories.firstWhere((c) => c.id == _selectedCategoryId);
    context.read<TransactionProvider>().addTransaction(
      title: cat.name,
      amount: amount,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      type: _type,
      description: _noteController.text.isNotEmpty
          ? _noteController.text
          : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOut,
          ),
          child: Column(
            children: [
              // Header
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
                        'New Transaction',
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
                  child: Column(
                    children: [
                      // Type Toggle
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
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
                              label: 'Income',
                              isActive: _type == CategoryType.income,
                              color: AppTheme.success500,
                              onTap: () => setState(() {
                                _type = CategoryType.income;
                                _selectedCategoryId = null;
                              }),
                            ),
                            _TypeToggle(
                              label: 'Expense',
                              isActive: _type == CategoryType.expense,
                              color: AppTheme.danger500,
                              onTap: () => setState(() {
                                _type = CategoryType.expense;
                                _selectedCategoryId = null;
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Amount Display
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Text('Amount', style: AppTheme.captionRegular),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              key: ValueKey(_amount),
                              child: RichText(
                                text: TextSpan(
                                  text: _amount,
                                  style: AppTheme.amountLarge.copyWith(
                                    color: _type == CategoryType.income
                                        ? AppTheme.success500
                                        : AppTheme.danger500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' TND',
                                      style: AppTheme.h2Bold.copyWith(
                                        color: _type == CategoryType.income
                                            ? AppTheme.success500
                                            : AppTheme.danger500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Categories
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Category',
                              style: AppTheme.bodySemiBold.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _categories.map((cat) {
                                final isSelected =
                                    _selectedCategoryId == cat.id;
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCategoryId = cat.id,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            76) /
                                        4,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary900
                                            : AppTheme.neutral200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: cat.color.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            cat.icon,
                                            color: cat.color,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cat.name.split(' ').first,
                                          style: AppTheme.smallMedium.copyWith(
                                            color: AppTheme.neutral900,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            hintText: 'Add a note (optional)',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.neutral100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.neutral500,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat(
                                    'EEEE, MMMM d, yyyy',
                                  ).format(_selectedDate),
                                  style: AppTheme.captionMedium.copyWith(
                                    color: AppTheme.neutral900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Keypad
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: [
                            ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map(
                              (n) => _KeypadButton(
                                label: '$n',
                                onTap: () => _handleNumberPress('$n'),
                              ),
                            ),
                            _KeypadButton(
                              label: '.',
                              onTap: () => _handleNumberPress('.'),
                            ),
                            _KeypadButton(
                              label: '0',
                              onTap: () => _handleNumberPress('0'),
                            ),
                            _KeypadButton(
                              label: '⌫',
                              onTap: _handleBackspace,
                              isIcon: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Submit button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _type == CategoryType.income
                          ? AppTheme.success500
                          : AppTheme.danger500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Add ${_type == CategoryType.income ? 'Income' : 'Expense'}',
                      style: AppTheme.bodySemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? AppTheme.shadowSm : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.bodySemiBold.copyWith(
              fontSize: 14,
              color: isActive ? color : AppTheme.neutral400,
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isIcon;

  const _KeypadButton({
    required this.label,
    required this.onTap,
    this.isIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.neutral100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: isIcon
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppTheme.neutral900,
                  size: 22,
                )
              : Text(label, style: AppTheme.h3SemiBold.copyWith(fontSize: 20)),
        ),
      ),
    );
  }
}
