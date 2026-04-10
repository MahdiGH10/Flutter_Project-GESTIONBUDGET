import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';

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
  final _customCategoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animController;
  bool _isSubmitting = false;
  bool _showSubmitSuccess = false;
  bool _showSubmitError = false;
  String _submitStatusText = '';
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
    _customCategoryController.dispose();
    super.dispose();
  }

  bool _isOtherCategory(Category category) {
    final id = category.id.toLowerCase();
    final name = category.name.toLowerCase().trim();
    return id.contains('other') || name == 'other';
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

  String _friendlySubmitError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (error is TimeoutException || lower.contains('timed out')) {
      return 'Save timed out. Check your internet and try again.';
    }

    if (lower.contains('permission_denied') ||
        lower.contains('permission-denied')) {
      return 'Permission denied by Firestore. Check Firestore API and security rules.';
    }

    if (lower.contains('firestore api') &&
        (lower.contains('not been used') || lower.contains('disabled'))) {
      return 'Firestore API is disabled for this project. Enable it in Google Cloud Console.';
    }

    return raw.replaceFirst('Bad state: ', '');
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    Timer? slowHintTimer;

    final amount = double.tryParse(_amount);
    final categories = _categoriesFromProvider(context);
    Category? selectedCategory;
    try {
      selectedCategory = categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      selectedCategory = null;
    }

    final isOtherCategory =
        selectedCategory != null && _isOtherCategory(selectedCategory);
    final customCategoryName = _customCategoryController.text.trim();

    if (amount == null ||
        amount <= 0 ||
        selectedCategory == null ||
        (isOtherCategory && customCategoryName.isEmpty)) {
      final validationMessage = amount == null || amount <= 0
          ? 'Please enter a valid amount'
          : selectedCategory == null
              ? 'Please select a category'
              : 'Please enter a custom category name';

      setState(() {
        _isSubmitting = false;
        _showSubmitSuccess = false;
        _showSubmitError = true;
        _submitStatusText = validationMessage;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMessage),
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
      setState(() {
        _isSubmitting = true;
        _showSubmitSuccess = false;
        _showSubmitError = false;
        _submitStatusText = 'Saving transaction...';
      });

      slowHintTimer = Timer(const Duration(seconds: 8), () {
        if (!mounted || !_isSubmitting) return;
        setState(() {
          _submitStatusText =
              'Still saving... Please wait a moment.';
        });
      });

      await context
          .read<TransactionProvider>()
          .addTransaction(
            title: isOtherCategory ? customCategoryName : selectedCategory.name,
            amount: amount,
            date: _selectedDate,
            categoryId: _selectedCategoryId!,
            type: _type,
            description: _noteController.text.isNotEmpty
                ? _noteController.text
                : null,
          );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _showSubmitSuccess = true;
        _showSubmitError = false;
        _submitStatusText = _type == CategoryType.income
            ? 'Income added successfully.'
            : 'Expense added successfully.';
      });

      await Future<void>.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;

      final popped = await Navigator.of(context).maybePop(true);
      if (!mounted) return;

      if (!popped) {
        await Navigator.of(context, rootNavigator: true).maybePop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final message = _friendlySubmitError(e);
      setState(() {
        _isSubmitting = false;
        _showSubmitSuccess = false;
        _showSubmitError = true;
        _submitStatusText = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.danger500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      slowHintTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categoriesByType(_type);
    Category? selectedCategory;
    try {
      selectedCategory = categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      selectedCategory = null;
    }
    final showCustomCategoryInput =
        selectedCategory != null && _isOtherCategory(selectedCategory);

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

              // Type toggle + Amount (always visible)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.neutral200.withValues(alpha: 0.65),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary900.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Column(
                        children: [
                          Text('Amount', style: AppTheme.captionRegular),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1),
                            duration: const Duration(milliseconds: 200),
                            builder: (context, scale, child) {
                              return Transform.scale(scale: scale, child: child);
                            },
                            key: ValueKey(_amount),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 64),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.neutral100,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: RichText(
                                  text: TextSpan(
                                    text: _formattedAmount,
                                    style: AppTheme.amountLarge.copyWith(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.2,
                                      color: _type == CategoryType.income
                                          ? AppTheme.success500
                                          : AppTheme.danger500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' TND',
                                        style: AppTheme.h2Bold.copyWith(
                                          fontSize: 30,
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
                  ],
                ),
              ),

              // Scrollable form fields only
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Category',
                              style: AppTheme.bodySemiBold.copyWith(fontSize: 14),
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
                                      onTap: () => setState(() {
                                        _selectedCategoryId = cat.id;
                                        if (!_isOtherCategory(cat)) {
                                          _customCategoryController.clear();
                                        }
                                      }),
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

                      if (showCustomCategoryInput) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.neutral100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _customCategoryController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Custom category name',
                                prefixIcon: Icon(
                                  Icons.category_outlined,
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
                      ],

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

                      // Keypad (scrollable, not fixed)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const columns = 3;
                            const spacing = 10.0;
                            final itemWidth =
                                (constraints.maxWidth - ((columns - 1) * spacing)) /
                                    columns;
                            final itemHeight = itemWidth.clamp(56.0, 70.0);
                            final childAspectRatio = itemWidth / itemHeight;

                            return GridView.builder(
                              itemCount: _keypadValues.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

              // Submit (fixed)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _showSubmitSuccess)
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _type == CategoryType.income
                              ? AppTheme.success500
                              : AppTheme.danger500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Add ${_type == CategoryType.income ? 'Income' : 'Expense'}',
                                style: AppTheme.bodySemiBold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: (_isSubmitting || _showSubmitSuccess || _showSubmitError)
                          ? Container(
                              key: ValueKey(
                                '${_isSubmitting ? 'saving' : _showSubmitSuccess ? 'success' : 'error'}$_submitStatusText',
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _showSubmitSuccess
                                    ? AppTheme.success50
                                    : _showSubmitError
                                        ? AppTheme.danger50
                                        : AppTheme.neutral100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _showSubmitSuccess
                                      ? AppTheme.success100
                                      : _showSubmitError
                                          ? AppTheme.danger100
                                          : AppTheme.neutral200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _isSubmitting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : _showSubmitSuccess
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: AppTheme.success500,
                                              size: 18,
                                            )
                                          : const Icon(
                                              Icons.error_outline,
                                              color: AppTheme.danger500,
                                              size: 18,
                                            ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _submitStatusText,
                                      style: AppTheme.captionMedium.copyWith(
                                        color: _showSubmitSuccess
                                            ? AppTheme.success500
                                            : _showSubmitError
                                                ? AppTheme.danger500
                                                : AppTheme.neutral700,
                                      ),
                                    ),
                                  ),
                                  if (_showSubmitError) ...[
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: _isSubmitting ? null : _handleSubmit,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
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
