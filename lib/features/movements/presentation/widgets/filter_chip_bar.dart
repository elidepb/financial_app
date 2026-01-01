import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';

class MovementFilterChip {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;

  const MovementFilterChip({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });
}

class FilterChipBar extends StatefulWidget {
  final List<MovementFilterChip> filters;
  final ValueChanged<String>? onFilterRemoved;
  final VoidCallback? onAddFilter;

  const FilterChipBar({
    super.key,
    required this.filters,
    this.onFilterRemoved,
    this.onAddFilter,
  });

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    for (var filter in widget.filters) {
      _keys[filter.id] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(FilterChipBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newFilterIds = widget.filters.map((f) => f.id).toSet();

    for (var filter in widget.filters) {
      if (!_keys.containsKey(filter.id)) {
        _keys[filter.id] = GlobalKey();
      }
    }

    _keys.removeWhere((id, _) => !newFilterIds.contains(id));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.filters.length + (widget.onAddFilter != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.filters.length && widget.onAddFilter != null) {
            return _buildAddFilterChip();
          }

          final filter = widget.filters[index];
          return _buildFilterChip(filter, index);
        },
      ),
    );
  }

  Widget _buildFilterChip(MovementFilterChip filter, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Transform.translate(
              offset: Offset((1 - value) * 50, 0),
              child: child,
            ),
          );
        },
        child: GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          animateBorder: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (filter.color ?? const Color(0xFF7E57C2)).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filter.icon != null) ...[
                  Icon(
                    filter.icon,
                    color: filter.color ?? const Color(0xFF7E57C2),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  filter.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    widget.onFilterRemoved?.call(filter.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFilterChip() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: widget.onAddFilter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Filtro',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
