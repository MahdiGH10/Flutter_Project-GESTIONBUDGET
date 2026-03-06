import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/budget_provider.dart';
import '../../theme/app_theme.dart';

class BudgetGoalPage extends StatefulWidget {
  const BudgetGoalPage({super.key});

  @override
  State<BudgetGoalPage> createState() => _BudgetGoalPageState();
}

class _BudgetGoalPageState extends State<BudgetGoalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

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

  IconData _getIconForCategory(String categoryId) {
    final cat = DefaultCategories.all
        .where((c) => c.id == categoryId)
        .firstOrNull;
    return cat?.icon ?? Icons.track_changes;
  }

  Color _getColorForCategory(String categoryId) {
    final cat = DefaultCategories.all
        .where((c) => c.id == categoryId)
        .firstOrNull;
    return cat?.color ?? AppTheme.success500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral100,
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, _) {
            final goals = budgetProvider.goals;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.neutral900,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.neutral100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Budget Goals',
                            textAlign: TextAlign.center,
                            style: AppTheme.h3SemiBold.copyWith(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddGoalDialog(context),
                          icon: const Icon(
                            Icons.add,
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

                // Summary Card
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.0, 0.4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary900,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'February 2026 Progress',
                            style: AppTheme.captionRegular.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${budgetProvider.onTrackCount} of ${goals.length} goals on track',
                            style: AppTheme.h2Bold.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _GoalIndicator(
                                color: AppTheme.success500,
                                label:
                                    '${budgetProvider.onTrackCount} On Track',
                              ),
                              const SizedBox(width: 16),
                              _GoalIndicator(
                                color: AppTheme.danger500,
                                label:
                                    '${budgetProvider.exceededCount} Exceeded',
                              ),
                              const SizedBox(width: 16),
                              _GoalIndicator(
                                color: const Color(0xFFFFEAA7),
                                label: '${budgetProvider.warningCount} Warning',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Goals header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'YOUR GOALS',
                      style: AppTheme.smallMedium.copyWith(
                        color: AppTheme.neutral500,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Goals list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final goal = goals[index];
                      final icon = _getIconForCategory(goal.categoryId);
                      final color = _getColorForCategory(goal.categoryId);

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.name,
                                          style: AppTheme.bodySemiBold.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${goal.isExceeded ? "Exceeded by " : ""}${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} TND',
                                          style: AppTheme.smallMedium.copyWith(
                                            color: AppTheme.neutral500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${goal.percentage.toStringAsFixed(0)}%',
                                    style: AppTheme.bodySemiBold.copyWith(
                                      color: goal.isExceeded
                                          ? AppTheme.danger500
                                          : AppTheme.success500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: goal.percentage / 100,
                                  ),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animValue, _) {
                                    return LinearProgressIndicator(
                                      value: animValue,
                                      backgroundColor: AppTheme.neutral200,
                                      valueColor: AlwaysStoppedAnimation(
                                        goal.isExceeded
                                            ? AppTheme.danger500
                                            : goal.isWarning
                                            ? const Color(0xFFF7DC6F)
                                            : color,
                                      ),
                                      minHeight: 8,
                                    );
                                  },
                                ),
                              ),
                              if (goal.isExceeded) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      color: AppTheme.danger500,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'You\'ve exceeded your budget by ${goal.exceededBy.toStringAsFixed(0)} TND',
                                      style: AppTheme.smallMedium.copyWith(
                                        color: AppTheme.danger500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (goal.isWarning) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber,
                                      color: Color(0xFFF7DC6F),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Approaching budget limit',
                                      style: AppTheme.smallMedium.copyWith(
                                        color: const Color(0xFFF7DC6F),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }, childCount: goals.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategoryId = 'food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.neutral300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('New Budget Goal', style: AppTheme.h3SemiBold),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'Goal name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Target amount (TND)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: AppTheme.captionMedium.copyWith(
                      color: AppTheme.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DefaultCategories.expenses.map((cat) {
                      final isSelected = selectedCategoryId == cat.id;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedCategoryId = cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cat.color.withOpacity(0.2)
                                : AppTheme.neutral100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? cat.color
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 16, color: cat.color),
                              const SizedBox(width: 6),
                              Text(
                                cat.name.split(' ').first,
                                style: AppTheme.smallMedium.copyWith(
                                  color: AppTheme.neutral900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountCtrl.text);
                        if (nameCtrl.text.isNotEmpty &&
                            amount != null &&
                            amount > 0) {
                          await context.read<BudgetProvider>().addGoal(
                            name: nameCtrl.text,
                            categoryId: selectedCategoryId,
                            targetAmount: amount,
                            month: DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                            ),
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('Create Goal'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GoalIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _GoalIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.smallMedium.copyWith(color: Colors.white)),
      ],
    );
  }
}
