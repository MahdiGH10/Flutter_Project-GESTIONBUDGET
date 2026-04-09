import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/home_shell.dart';

class AddTransactionPage extends StatefulWidget {
  final CategoryType initialType;

  const AddTransactionPage({
    super.key,
    this.initialType = CategoryType.expense,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  static const int _maxIntegerDigits = 8;
  static const int _maxFractionDigits = 2;

  late CategoryType _type = widget.initialType;
  String _amount = '0';
  String? _selectedCategoryId;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animController;
  final List<String> _keypadValues = const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '.',
    '0',
    '⌫',
  ];

  List<Category> _categoriesFromProvider(BuildContext context) {
    return context.read<CategoryProvider>().categoriesByType(_type);
  }

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
      if (num == '.' && _amount.contains('.')) {
        return;
      }

      if (num == '.') {
        _amount = '$_amount.';
        return;
      }

      final parts = _amount.split('.');
      final hasFraction = parts.length > 1;

      if (hasFraction) {
        final fraction = parts[1];
        if (fraction.length >= _maxFractionDigits) return;
        _amount += num;
        return;
      }

      final integer = parts[0] == '0' ? '' : parts[0];
      if (integer.length >= _maxIntegerDigits) return;

      _amount = _amount == '0' ? num : _amount + num;
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

  String get _formattedAmount {
    if (_amount.isEmpty) return '0';

    final parts = _amount.split('.');
    final rawInteger = parts.first.isEmpty ? '0' : parts.first;
    final integerNumber = int.tryParse(rawInteger) ?? 0;
    final formattedInteger = NumberFormat.decimalPattern().format(integerNumber);

    if (parts.length == 1) return formattedInteger;

    final fraction = parts[1];
    if (_amount.endsWith('.')) return '$formattedInteger.';
    return '$formattedInteger.$fraction';
  }

  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amount);
    final categories = _categoriesFromProvider(context);
    Category? selectedCategory;
    try {
      selectedCategory = categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      selectedCategory = null;
    }

    if (amount == null || amount <= 0 || selectedCategory == null) {
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

    try {
      await context.read<TransactionProvider>().addTransaction(
        title: selectedCategory.name,
        amount: amount,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        type: _type,
        description: _noteController.text.isNotEmpty
            ? _noteController.text
            : null,
      );

      if (!mounted) return;
      final isIncome = _type == CategoryType.income;
      final rootNavigator = Navigator.of(context, rootNavigator: true);

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isIncome
                  ? 'Income added successfully.'
                  : 'Expense added successfully.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isIncome
                ? AppTheme.success500
                : AppTheme.danger500,
            action: SnackBarAction(
              label: 'View Balance',
              textColor: Colors.white,
              onPressed: () {
                rootNavigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeShell()),
                  (_) => false,
                );
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Bad state: ', '')),
          backgroundColor: AppTheme.danger500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categoriesByType(_type);

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
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 56),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    text: TextSpan(
                                      text: _formattedAmount,
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 12.0;
                                const minTileWidth = 78.0;
                                final crossAxisCount = (constraints.maxWidth /
                                        (minTileWidth + spacing))
                                    .floor()
                                    .clamp(3, 5);
                                final tileWidth =
                                    (constraints.maxWidth -
                                            ((crossAxisCount - 1) * spacing)) /
                                        crossAxisCount;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: categories.map((cat) {
                                    final isSelected = _selectedCategoryId == cat.id;
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedCategoryId = cat.id),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: tileWidth,
                                        constraints:
                                            const BoxConstraints(minHeight: 96),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primary900
                                                : AppTheme.neutral200,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: cat.color.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                cat.icon,
                                                color: cat.color,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              cat.name.split(' ').first,
                                              style: AppTheme.smallMedium.copyWith(
                                                color: AppTheme.neutral900,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.neutral100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _noteController,
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: 'Add a note (optional)',
                              prefixIcon: Icon(
                                Icons.edit_note_rounded,
                                color: AppTheme.neutral500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
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
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'EEEE, MMMM d, yyyy',
                                    ).format(_selectedDate),
                                    style: AppTheme.captionMedium.copyWith(
                                      color: AppTheme.neutral900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppTheme.neutral500,
                                  size: 20,
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const columns = 3;
                            const spacing = 10.0;
                            final itemWidth =
                                (constraints.maxWidth - ((columns - 1) * spacing)) /
                                    columns;
                            final itemHeight = itemWidth.clamp(56.0, 74.0);
                            final childAspectRatio = itemWidth / itemHeight;

                            return GridView.builder(
                              itemCount: _keypadValues.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: childAspectRatio,
                                mainAxisSpacing: spacing,
                                crossAxisSpacing: spacing,
                              ),
                              itemBuilder: (context, index) {
                                final key = _keypadValues[index];
                                final isBackspace = key == '⌫';
                                return _KeypadButton(
                                  label: key,
                                  onTap: isBackspace
                                      ? _handleBackspace
                                      : () => _handleNumberPress(key),
                                  isIcon: isBackspace,
                                );
                              },
                            );
                          },
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
