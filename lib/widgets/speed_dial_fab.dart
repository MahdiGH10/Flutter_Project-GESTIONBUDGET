import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const SpeedDialFab({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.18)),
            ),
          ),

        // Income button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          bottom: _isOpen ? 136 : 0,
          right: _isOpen ? 52 : 24,
          child: _isOpen
              ? ScaleTransition(
                  scale: _scaleAnimation,
                  child: _SpeedDialAction(
                    heroTag: 'fab_income',
                    tooltip: 'Add Income',
                    icon: Icons.arrow_downward,
                    color: AppTheme.success500,
                    onTap: () {
                      _toggle();
                      widget.onAddIncome();
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Expense button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          bottom: _isOpen ? 84 : 0,
          right: _isOpen ? 12 : 24,
          child: _isOpen
              ? ScaleTransition(
                  scale: _scaleAnimation,
                  child: _SpeedDialAction(
                    heroTag: 'fab_expense',
                    tooltip: 'Add Expense',
                    icon: Icons.arrow_upward,
                    color: AppTheme.danger500,
                    onTap: () {
                      _toggle();
                      widget.onAddExpense();
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Main FAB
        RotationTransition(
          turns: _rotationAnimation,
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: AppTheme.primary900,
            elevation: 8,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isOpen ? Icons.close : Icons.add,
                key: ValueKey(_isOpen),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedDialAction extends StatefulWidget {
  final String heroTag;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialAction({
    required this.heroTag,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SpeedDialAction> createState() => _SpeedDialActionState();
}

class _SpeedDialActionState extends State<_SpeedDialAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          key: ValueKey(widget.heroTag),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _isPressed ? widget.color : AppTheme.neutral500,
          ),
        ),
      ),
    );
  }
}
