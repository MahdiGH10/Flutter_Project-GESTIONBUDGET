import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'add_transaction_page.dart';
import '../dashboard/home_shell.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _filter = 'all';
  String? _selectedCategoryId;
  String _searchQuery = '';

  Future<void> _openAddTransaction({required bool isIncome}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(
          initialType: isIncome ? CategoryType.income : CategoryType.expense,
        ),
      ),
    );

    if (!mounted || saved != true) return;

    final message = isIncome
        ? 'Income added successfully.'
        : 'Expense added successfully.';

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeShell(
          successMessage: message,
          successIsIncome: isIncome,
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _showSearchSheet() async {
    final controller = TextEditingController(text: _searchQuery);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search transactions', style: AppTheme.h3SemiBold),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Title, note, category, amount',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) {
                    setState(() => _searchQuery = controller.text.trim());
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Clear'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _searchQuery = controller.text.trim());
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Category> _availableCategories(CategoryProvider categoryProvider) {
    if (_filter == 'income') {
      return categoryProvider.categoriesByType(CategoryType.income);
    }
    if (_filter == 'expense') {
      return categoryProvider.categoriesByType(CategoryType.expense);
    }

    final all = [
      ...categoryProvider.categoriesByType(CategoryType.expense),
      ...categoryProvider.categoriesByType(CategoryType.income),
    ];

    final dedup = <String, Category>{};
    for (final c in all) {
      dedup[c.id] = c;
    }
    return dedup.values.toList();
  }

  String _categoryFilterLabel(CategoryProvider categoryProvider) {
    if (_selectedCategoryId == null) return 'All categories';
    final categories = _availableCategories(categoryProvider);
    for (final c in categories) {
      if (c.id == _selectedCategoryId) return c.name;
    }
    return 'All categories';
  }

  Future<void> _showCategoryFilterSheet(
    CategoryProvider categoryProvider,
  ) async {
    final categories = _availableCategories(categoryProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter by category', style: AppTheme.h3SemiBold),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.layers_clear,
                    color: AppTheme.neutral700,
                  ),
                  title: const Text('All categories'),
                  trailing: _selectedCategoryId == null
                      ? const Icon(Icons.check, color: AppTheme.success500)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategoryId = null);
                    Navigator.pop(context);
                  },
                ),
                if (categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No categories available for this transaction type.',
                      style: AppTheme.captionMedium.copyWith(
                        color: AppTheme.neutral500,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: cat.color.withValues(alpha: 0.12),
                            child: Icon(cat.icon, color: cat.color, size: 16),
                          ),
                          title: Text(cat.name),
                          trailing: _selectedCategoryId == cat.id
                              ? const Icon(
                                  Icons.check,
                                  color: AppTheme.success500,
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedCategoryId = cat.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, txnProvider, categoryProvider, _) {
        final categoryLookup = {
          for (final c in categoryProvider.categoriesByType(
            CategoryType.expense,
          ))
            c.id: c,
          for (final c in categoryProvider.categoriesByType(
            CategoryType.income,
          ))
            c.id: c,
        };

        final allTxns = txnProvider.transactions;
        final typeFilteredTxns = _filter == 'all'
            ? allTxns
            : _filter == 'income'
            ? allTxns.where((t) => t.isIncome).toList()
            : allTxns.where((t) => t.isExpense).toList();

        final categoryFilteredTxns = _selectedCategoryId == null
            ? typeFilteredTxns
            : typeFilteredTxns
                  .where((t) => t.categoryId == _selectedCategoryId)
                  .toList();

        final query = _searchQuery.trim().toLowerCase();
        final filteredTxns = query.isEmpty
            ? categoryFilteredTxns
            : categoryFilteredTxns.where((t) {
                final title = t.title.toLowerCase();
                final note = (t.description ?? '').toLowerCase();
                final amount = t.amount.toStringAsFixed(2);
                final categoryName =
                    (categoryLookup[t.categoryId]?.name ?? t.categoryId)
                        .toLowerCase();

                return title.contains(query) ||
                    note.contains(query) ||
                    amount.contains(query) ||
                    categoryName.contains(query);
              }).toList();

        return RefreshIndicator(
          onRefresh: txnProvider.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Text(
                        'Transactions',
                        style: AppTheme.h2Bold.copyWith(fontSize: 20),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _showSearchSheet,
                        icon: const Icon(
                          Icons.search,
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

              // Filter Tabs
              SliverToBoxAdapter(
                child: Container(
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
                    children: ['all', 'income', 'expense'].map((f) {
                      final isActive = _filter == f;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _filter = f;
                            _selectedCategoryId = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isActive ? AppTheme.shadowSm : null,
                            ),
                            child: Text(
                              f[0].toUpperCase() + f.substring(1),
                              textAlign: TextAlign.center,
                              style: AppTheme.captionMedium.copyWith(
                                color: isActive
                                    ? AppTheme.neutral900
                                    : AppTheme.neutral500,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.success500.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: AppTheme.success500,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Income', style: AppTheme.smallMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${txnProvider.totalIncome.toStringAsFixed(0)} TND',
                                style: AppTheme.h3SemiBold.copyWith(
                                  color: AppTheme.success500,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger500.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.trending_down,
                                      color: AppTheme.danger500,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Expense', style: AppTheme.smallMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${txnProvider.totalExpense.toStringAsFixed(0)} TND',
                                style: AppTheme.h3SemiBold.copyWith(
                                  color: AppTheme.danger500,
                                  fontSize: 18,
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

              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HISTORY',
                        style: AppTheme.smallMedium.copyWith(
                          color: AppTheme.neutral500,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showCategoryFilterSheet(categoryProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neutral100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.filter_list,
                                    color: AppTheme.neutral900,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _categoryFilterLabel(categoryProvider),
                                    style: AppTheme.captionMedium.copyWith(
                                      color: AppTheme.neutral900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('Search: "$_searchQuery"'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _searchQuery = ''),
                        ),
                      ],
                    ),
                  ),
                ),

              // Transaction list / loading / empty state
              if (txnProvider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: true,
                  child: TransactionListSkeleton(),
                )
              else if (filteredTxns.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: EmptyState(
                      title: 'No transactions yet',
                      message:
                          'Add your first income or expense to see it here.',
                      icon: Icons.receipt_long,
                      actionLabel: 'Add transaction',
                      onAction: () => _openAddTransaction(isIncome: false),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionTile(
                          transaction: filteredTxns[index],
                          categoryLookup: categoryLookup,
                          onDismissed: () async {
                            await txnProvider.deleteTransaction(
                              filteredTxns[index].id,
                            );
                          },
                        ),
                      );
                    }, childCount: filteredTxns.length),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
