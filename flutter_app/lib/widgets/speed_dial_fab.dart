import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onOpenGoals;

  const SpeedDialFab({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onOpenGoals,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _menuOpacity;
  late final Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _menuOpacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
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

  void _openMenu() {
    setState(() => _isOpen = true);
    _controller.forward();
  }

  void _closeMenu() {
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    _isOpen ? _closeMenu() : _openMenu();
  }

  void _onActionTap(VoidCallback action) {
    HapticFeedback.lightImpact();
    _closeMenu();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _SpeedDialEntry(
        label: 'Add income',
        icon: Icons.arrow_downward_rounded,
        accent: AppTheme.success500,
        onTap: widget.onAddIncome,
      ),
      _SpeedDialEntry(
        label: 'Add expense',
        icon: Icons.arrow_upward_rounded,
        accent: AppTheme.danger500,
        onTap: widget.onAddExpense,
      ),
      _SpeedDialEntry(
        label: 'Budget goals',
        icon: Icons.flag_rounded,
        accent: AppTheme.primary900,
        onTap: widget.onOpenGoals,
      ),
    ];

    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IgnorePointer(
            ignoring: !_isOpen,
            child: AnimatedOpacity(
              opacity: _isOpen ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(actions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SpeedDialActionTile(
                      index: index,
                      controller: _controller,
                      opacity: _menuOpacity,
                      entry: actions[index],
                      onTap: () => _onActionTap(actions[index].onTap),
                    ),
                  );
                }),
              ),
            ),
          ),
          Tooltip(
            message: _isOpen ? 'Close quick actions' : 'Open quick actions',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isOpen
                      ? [AppTheme.primary700, AppTheme.primary900]
                      : [AppTheme.primary800, AppTheme.primary900],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary900.withValues(
                      alpha: _isOpen ? 0.30 : 0.22,
                    ),
                    blurRadius: _isOpen ? 24 : 16,
                    offset: Offset(0, _isOpen ? 10 : 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _toggle,
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          _isOpen ? Icons.close_rounded : Icons.add_rounded,
                          key: ValueKey(_isOpen),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedDialEntry {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _SpeedDialEntry({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

class _SpeedDialActionTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Animation<double> opacity;
  final _SpeedDialEntry entry;
  final VoidCallback onTap;

  const _SpeedDialActionTile({
    required this.index,
    required this.controller,
    required this.opacity,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.10).clamp(0.0, 0.45);
    final end = (start + 0.45).clamp(0.0, 1.0);
    final itemAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.22, 0.08),
          end: Offset.zero,
        ).animate(itemAnimation),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary900.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                entry.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: AppTheme.primary900.withValues(alpha: 0.14),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(entry.icon, size: 20, color: entry.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
