import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/quick_action_button.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class QuickActionStaggeredGrid extends StatefulWidget {
  final List<QuickActionItem> items;

  const QuickActionStaggeredGrid({
    super.key,
    required this.items,
  });

  @override
  State<QuickActionStaggeredGrid> createState() => _QuickActionStaggeredGridState();
}

class _QuickActionStaggeredGridState extends State<QuickActionStaggeredGrid>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animations = List.generate(
      widget.items.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.8 + (index * 0.15),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppDimensions.breakpointMobile;
        final crossAxisCount = isMobile ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.paddingMD,
            mainAxisSpacing: AppDimensions.paddingMD,
            childAspectRatio: 1.1,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _animations[index].value,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      30 * (1 - _animations[index].value),
                    ),
                    child: child,
                  ),
                );
              },
              child: QuickActionButton(
                label: widget.items[index].label,
                icon: widget.items[index].icon,
                onTap: widget.items[index].onTap,
                color: widget.items[index].color,
              ),
            );
          },
        );
      },
    );
  }
}

