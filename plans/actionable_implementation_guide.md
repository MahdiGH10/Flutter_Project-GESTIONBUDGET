# Actionable Implementation Guide
## Immediate Actions for Flutter Budget App Enhancement

This document provides a prioritized, step-by-step implementation guide based on the comprehensive planning documentation and specific UI/UX recommendations.

---

## 🚀 Quick Wins (Week 1) - Immediate UI/UX Improvements

### Priority 1: Visual Hierarchy & Home Screen
**Estimated Time**: 2-3 days

#### Balance Card Component
```dart
// lib/widgets/balance_card.dart
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Income',
                  income,
                  Icons.arrow_downward,
                  Colors.green[300]!,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Expense',
                  expense,
                  Icons.arrow_upward,
                  Colors.red[300]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### Enhanced Transaction List Item
```dart
// lib/widgets/transaction_list_item.dart
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      background: _buildSwipeBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        } else {
          onEdit();
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: category.color,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
  
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

### Priority 2: Empty States & Loading
**Estimated Time**: 1 day

#### Empty State Widget
```dart
// lib/widgets/empty_state.dart
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Skeleton Loading
```dart
// lib/widgets/skeleton_loading.dart
class SkeletonLoading extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  
  const SkeletonLoading({
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius,
  });
  
  @override
  _SkeletonLoadingState createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Transaction List Skeleton
class TransactionListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                SkeletonLoading(
                  height: 48,
                  width: 48,
                  borderRadius: BorderRadius.circular(12),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(height: 16, width: double.infinity),
                      SizedBox(height: 8),
                      SkeletonLoading(height: 12, width: 120),
                    ],
                  ),
                ),
                SkeletonLoading(height: 20, width: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Priority 3: Enhanced FAB with Speed Dial
**Estimated Time**: 0.5 day

```dart
// lib/widgets/speed_dial_fab.dart
class SpeedDialFAB extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  
  const SpeedDialFAB({
    required this.onAddIncome,
    required this.onAddExpense,
  });
  
  @override
  _SpeedDialFABState createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSpeedDialButton(
                label: 'Add Income',
                icon: Icons.arrow_downward,
                color: Colors.green,
                onTap: () {
                  _toggle();
                  widget.onAddIncome();
                },
              ),
            ),
            SizedBox(height: 16),
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSpeedDialButton(
                label: 'Add Expense',
                icon: Icons.arrow_upward,
                color: Colors.red,
                onTap: () {
                  _toggle();
                  widget.onAddExpense();
                },
              ),
            ),
            SizedBox(height: 16),
            RotationTransition(
              turns: _rotationAnimation,
              child: FloatingActionButton(
                onPressed: _toggle,
                child: Icon(_isOpen ? Icons.close : Icons.add),
                elevation: 6,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSpeedDialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 12),
        FloatingActionButton(
          mini: true,
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}
```

---

## 📊 Phase 1: Foundation (Weeks 1-3)

### Step 1: SQLite Database Setup
**Files to Create**:
- `lib/database/database_helper.dart`
- `lib/database/migrations/migration_v1.dart`
- `lib/database/migrations/migration_manager.dart`

**Implementation Order**:
1. Create DatabaseHelper singleton
2. Define initial schema (users, transactions, budget_goals, categories)
3. Implement migration system
4. Add database initialization
5. Create indexes for performance

### Step 2: Repository Layer
**Files to Create**:
- `lib/repositories/base_repository.dart`
- `lib/repositories/user_repository.dart`
- `lib/repositories/transaction_repository.dart`
- `lib/repositories/budget_repository.dart`
- `lib/repositories/category_repository.dart`
- `lib/data_sources/local_data_source.dart`

**Implementation Order**:
1. Create base repository interface
2. Implement LocalDataSource
3. Implement each repository
4. Add error handling
5. Write unit tests

### Step 3: Service Migration
**Files to Modify**:
- `lib/services/auth_service.dart`
- `lib/services/transaction_service.dart`
- `lib/services/budget_service.dart`

**Implementation Order**:
1. Update AuthService to use UserRepository
2. Update TransactionService to use TransactionRepository
3. Update BudgetService to use BudgetRepository
4. Remove in-memory storage
5. Test data persistence

---

## 🎯 Phase 2: Core Features (Weeks 4-6)

### Step 1: Recurring Transactions
**Files to Create**:
- `lib/models/recurring_transaction_model.dart`
- `lib/repositories/recurring_transaction_repository.dart`
- `lib/services/recurring_transaction_service.dart`
- `lib/providers/recurring_transaction_provider.dart`
- `lib/views/recurring/recurring_transactions_page.dart`
- `lib/views/recurring/add_recurring_transaction_page.dart`
- `lib/services/background_task_service.dart`

**Implementation Order**:
1. Create RecurringTransaction model with pattern logic
2. Add database table and repository
3. Implement service layer
4. Create UI for managing recurring transactions
5. Implement background task for auto-creation
6. Add notifications before creation

### Step 2: Notification System
**Files to Create**:
- `lib/services/notification_service.dart`
- `lib/services/notification_manager.dart`
- `lib/views/settings/notification_settings_page.dart`

**Dependencies to Add**:
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
```

**Implementation Order**:
1. Set up flutter_local_notifications
2. Create NotificationService
3. Implement budget alert notifications
4. Implement bill reminder notifications
5. Add notification settings page
6. Handle notification taps

### Step 3: Data Export
**Files to Create**:
- `lib/services/export_service.dart`
- `lib/views/settings/export_settings_page.dart`

**Dependencies to Add**:
```yaml
dependencies:
  pdf: ^3.10.8
  csv: ^6.0.0
  share_plus: ^7.2.2
  file_picker: ^8.0.0
```

**Implementation Order**:
1. Implement CSV export
2. Implement PDF report generation
3. Add date range filtering
4. Create export UI
5. Implement share functionality

---

## 📈 Phase 3: Analytics & Insights (Weeks 7-9)

### Step 1: Analytics Service
**Files to Create**:
- `lib/services/analytics_service.dart`
- `lib/models/analytics_models.dart` (SpendingTrend, CategoryInsight, CashFlowPrediction)
- `lib/providers/analytics_provider.dart`

**Implementation Order**:
1. Create AnalyticsService with caching
2. Implement spending trend calculations
3. Implement category analysis
4. Implement income analysis
5. Add comparison calculations

### Step 2: Insights Dashboard
**Files to Create**:
- `lib/views/insights/insights_page.dart`
- `lib/widgets/charts/spending_trend_chart.dart`
- `lib/widgets/charts/category_breakdown_chart.dart`
- `lib/widgets/charts/cash_flow_chart.dart`

**Implementation Order**:
1. Create InsightsPage layout
2. Implement spending trends visualization
3. Add category insights
4. Show actionable recommendations
5. Add time period selection

---

## 🔒 Phase 4: Security (Weeks 10-11)

### Step 1: Data Encryption
**Files to Create**:
- `lib/services/security_service.dart`
- `lib/utils/encryption_helper.dart`

**Dependencies to Add**:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.3
```

**Implementation Order**:
1. Implement SecurityService
2. Add database encryption
3. Encrypt backup files
4. Use secure storage for credentials
5. Test encryption performance

### Step 2: Biometric Authentication
**Dependencies to Add**:
```yaml
dependencies:
  local_auth: ^2.1.8
```

**Files to Create**:
- `lib/views/auth/biometric_setup_page.dart`
- `lib/views/settings/security_settings_page.dart`

**Implementation Order**:
1. Integrate local_auth package
2. Implement biometric check on app launch
3. Add fallback PIN option
4. Create security settings page
5. Handle biometric failures

---

## 🎨 UI/UX Enhancements Checklist

### Immediate (Week 1)
- [ ] Implement Balance Card with gradient
- [ ] Redesign Transaction List Items with cards
- [ ] Add Empty States for all lists
- [ ] Implement Skeleton Loading screens
- [ ] Add Speed Dial FAB
- [ ] Implement Swipe Gestures on transactions
- [ ] Add Pull-to-Refresh
- [ ] Improve Form Validation with inline errors
- [ ] Add Haptic Feedback

### Short Term (Weeks 2-3)
- [ ] Implement Category Grid Selection
- [ ] Add Interactive Charts with tooltips
- [ ] Create Date Range Selector
- [ ] Implement Dark Mode
- [ ] Add Bottom Navigation Bar
- [ ] Improve Accessibility (semantic labels, touch targets)
- [ ] Add Confirmation Dialogs for destructive actions
- [ ] Implement Smooth Transitions

### Medium Term (Weeks 4-6)
- [ ] Add Receipt Photo Attachment
- [ ] Implement Advanced Filtering
- [ ] Create Savings Goals Feature
- [ ] Add Bill Reminders
- [ ] Implement Tags System
- [ ] Add Split Transactions
- [ ] Create Calendar View
- [ ] Implement Undo Functionality

---

## 📦 Package Installation Order

### Week 1
```bash
flutter pub add sqflite path_provider
```

### Week 2
```bash
flutter pub add flutter_secure_storage encrypt
```

### Week 3
```bash
flutter pub add flutter_local_notifications timezone
```

### Week 4
```bash
flutter pub add pdf csv share_plus file_picker
```

### Week 5
```bash
flutter pub add local_auth
```

### Week 6
```bash
flutter pub add image_picker
```

---

## 🧪 Testing Strategy

### Unit Tests (Ongoing)
- Test all repository methods
- Test service layer logic
- Test model serialization
- Test analytics calculations

### Widget Tests (After UI Changes)
- Test all new widgets
- Test user interactions
- Test form validations
- Test navigation

### Integration Tests (End of Each Phase)
- Test complete user workflows
- Test data persistence
- Test backup/restore
- Test export/import

---

## 📝 Daily Development Checklist

### Morning
- [ ] Pull latest code
- [ ] Review today's tasks
- [ ] Check for any blockers
- [ ] Update task status

### During Development
- [ ] Write code following architecture patterns
- [ ] Add inline documentation
- [ ] Write unit tests for new code
- [ ] Test on both iOS and Android
- [ ] Check for memory leaks

### End of Day
- [ ] Commit code with clear messages
- [ ] Update documentation
- [ ] Update task status
- [ ] Plan tomorrow's tasks
- [ ] Review code quality

---

## 🚨 Common Pitfalls to Avoid

1. **Don't skip database migrations** - Always create migration files
2. **Don't forget error handling** - Wrap database operations in try-catch
3. **Don't block UI thread** - Use async/await properly
4. **Don't forget to dispose** - Dispose controllers and streams
5. **Don't hardcode strings** - Use localization from the start
6. **Don't skip testing** - Write tests as you go
7. **Don't ignore accessibility** - Add semantic labels
8. **Don't forget null safety** - Handle null cases properly

---

## 📊 Progress Tracking

### Week 1
- [ ] Database setup complete
- [ ] Repository layer implemented
- [ ] Balance Card UI implemented
- [ ] Transaction List redesigned
- [ ] Empty states added
- [ ] Skeleton loading implemented

### Week 2
- [ ] Service migration complete
- [ ] Data persistence working
- [ ] Speed Dial FAB implemented
- [ ] Swipe gestures added
- [ ] Form validation improved

### Week 3
- [ ] All data persisting correctly
- [ ] No data loss on app restart
- [ ] Performance acceptable
- [ ] Unit tests passing
- [ ] Phase 1 complete

---

## 🎯 Success Metrics

### Technical Metrics
- Database query time < 100ms
- App launch time < 2 seconds
- Zero data loss incidents
- 80%+ code coverage
- Zero critical bugs

### User Metrics
- 90%+ users enable biometric auth
- 80%+ users create recurring transactions
- 60%+ users enable notifications
- 40%+ users export data
- 4.5+ star rating

---

## 📞 Support & Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [SQLite Docs](https://www.sqlite.org/docs.html)
- [Provider Package](https://pub.dev/packages/provider)

### Code Examples
- See `plans/technical_architecture.md` for detailed code examples
- See `plans/flutter_app_improvements.md` for feature specifications

### Getting Help
- Review planning documentation first
- Check technical architecture for patterns
- Refer to priority matrix for dependencies
- Ask team for clarification when needed

---

**Last Updated**: February 11, 2026  
**Status**: Ready for Implementation  
**Next Review**: After Week 1 Completion
