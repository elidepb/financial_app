import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';

class CategoryData {
  final String name;
  final double amount;
  final Color color;
  final String? icon;

  CategoryData({
    required this.name,
    required this.amount,
    required this.color,
    this.icon,
  });
}

class DynamicSpendingChart extends StatefulWidget {
  final Map<String, CategoryData> categoryBreakdown;

  const DynamicSpendingChart({super.key, required this.categoryBreakdown});

  @override
  State<DynamicSpendingChart> createState() => _DynamicSpendingChartState();
}

class _DynamicSpendingChartState extends State<DynamicSpendingChart> {
  int _touchedIndex = -1;
  Set<String> _hiddenCategories = {};

  @override
  Widget build(BuildContext context) {
    final activeCategories = widget.categoryBreakdown.entries
        .where((e) => !_hiddenCategories.contains(e.key))
        .map((e) => e.value)
        .toList();
        
    final total = activeCategories.fold(0.0, (sum, item) => sum + item.amount);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Categoría',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCirc,
            builder: (context, animValue, child) {
              return SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 4,
                        centerSpaceRadius: 80,
                        startDegreeOffset: -90 * animValue,
                        sections: _buildSections(activeCategories, animValue),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6), 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 28, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: widget.categoryBreakdown.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_hiddenCategories.contains(entry.key)) {
                      _hiddenCategories.remove(entry.key);
                    } else {
                      _hiddenCategories.add(entry.key);
                    }
                  });
                },
                child: _buildLegendItem(entry.value, !_hiddenCategories.contains(entry.key)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<CategoryData> categories, double animValue) {
    return List.generate(categories.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 0.0;
      final radius = isTouched ? 30.0 : 22.0;
      final data = categories[i];

      return PieChartSectionData(
        color: data.color.withOpacity(animValue),
        value: data.amount,
        title: data.name,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: isTouched ? _buildTooltip(data) : null,
        badgePositionPercentageOffset: 1.6,
        borderSide: isTouched 
          ? const BorderSide(color: Colors.white, width: 2) 
          : BorderSide.none,
      );
    });
  }

  Widget _buildTooltip(CategoryData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Text(
        '\$${data.amount}',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLegendItem(CategoryData data, bool isVisible) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: data.color, 
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: data.color.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)
              ]
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.name, 
            style: TextStyle(
              color: Colors.white.withOpacity(0.8), 
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )
          ),
        ],
      ),
    );
  }
}