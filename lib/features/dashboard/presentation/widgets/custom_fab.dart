import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFAB extends StatefulWidget {
  final VoidCallback? onExpensePressed;
  final VoidCallback? onIncomePressed;
  final VoidCallback? onPressed;

  const CustomFAB({
    super.key,
    this.onExpensePressed,
    this.onIncomePressed,
    this.onPressed,
  });

  @override
  State<CustomFAB> createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB> with TickerProviderStateMixin {
  late final AnimationController _expandController;
  late final AnimationController _scaleController;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _expenseFabAnimation;
  late final Animation<double> _incomeFabAnimation;
  
  bool _isExpanded = false;

  final double _bottomPadding = 16.0;
  final double _rightPadding = 16.0;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _expenseFabAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _incomeFabAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(_) => _scaleController.forward();
  void _handleTapUp(_) => _scaleController.reverse();
  void _handleTapCancel() => _scaleController.reverse();

  void _toggle() {
    if (!mounted) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _onMainFabPressed() {
    if (widget.onExpensePressed != null || widget.onIncomePressed != null) {
      _toggle();
    } else {
      widget.onPressed?.call();
    }
  }

  void _handleSpeedDialTap(VoidCallback callback) {
    if (!mounted) return;
    callback();
    if (_isExpanded) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final hasSpeedDial =
        widget.onExpensePressed != null || widget.onIncomePressed != null;

    return Stack(
      fit: StackFit.expand, 
      clipBehavior: Clip.none,
      children: [
        if (_isExpanded && hasSpeedDial)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          ),
          
        if (hasSpeedDial && widget.onExpensePressed != null)
          _buildSpeedDialItem(
            index: 1,
            icon: Icons.money_off,
            color: const Color(0xFFEF5350),
            label: 'Gasto',
            animation: _expenseFabAnimation,
            onTap: () => _handleSpeedDialTap(widget.onExpensePressed!),
          ),

        if (hasSpeedDial && widget.onIncomePressed != null)
          _buildSpeedDialItem(
            index: 2,
            icon: Icons.attach_money,
            color: const Color(0xFF4CAF50),
            label: 'Ingreso',
            animation: _incomeFabAnimation,
            onTap: () => _handleSpeedDialTap(widget.onIncomePressed!),
          ),

        Positioned(
          right: _rightPadding,
          bottom: _bottomPadding,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _onMainFabPressed,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Hero(
                tag: 'add-movement',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2),
                    borderRadius: BorderRadius.circular(_isExpanded ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7E57C2).withOpacity(0.4),
                        blurRadius: _isExpanded ? 12 : 8,
                        spreadRadius: _isExpanded ? 4 : 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: RotationTransition(
                        turns: _rotateAnimation,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required int index,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animationValue = animation.value.clamp(0.0, 1.0);
        
        final bottomOffset = _bottomPadding + 56.0 + 16.0 + (60.0 * (index - 1));
        
        final currentBottom = Offset.lerp(
          Offset(_rightPadding, _bottomPadding),
          Offset(_rightPadding + 4, bottomOffset),
          animationValue,
        )!;

        if (animationValue == 0) return const SizedBox.shrink();

        return Positioned(
          right: currentBottom.dx,
          bottom: currentBottom.dy,
          child: Opacity(
            opacity: animationValue,
            child: Transform.scale(
              scale: animationValue,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Material(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 4,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}