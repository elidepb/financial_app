import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatefulWidget {
  final List<MonthlyData> data;
  final Color barColor;

  const MonthlyBarChart({
    super.key,
    required this.data,
    this.barColor = const Color(0xFF7E57C2),
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int? _touchedIndex;
  Offset? _tooltipPosition;
  MonthlyData? _selectedData;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
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
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final double rawMaxY = widget.data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    final double maxY = rawMaxY * 1.1;
    final double interval = maxY / 5;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Mes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < widget.data.length) {
                                  final date = widget.data[index].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('MMM', 'es').format(date).toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    NumberFormat.compactCurrency(symbol: 'S/ ').format(value),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: widget.data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final isTouched = _touchedIndex == index;
                          final animatedValue = data.amount * _animation.value;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: animatedValue,
                                color: isTouched
                                    ? widget.barColor.withOpacity(1.0)
                                    : widget.barColor,
                                width: 22,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    widget.barColor.withOpacity(0.6),
                                    isTouched 
                                        ? widget.barColor 
                                        : widget.barColor.withOpacity(0.9),
                                  ],
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY,
                                  color: Colors.white.withOpacity(0.03),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.spot == null) {
                              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                                setState(() {
                                  _touchedIndex = -1;
                                  _showTooltip = false;
                                });
                              }
                              return;
                            }

                            final index = response.spot!.touchedBarGroupIndex;

                            setState(() {
                              _touchedIndex = index;
                              _showTooltip = true;
                              _tooltipPosition = event.localPosition;
                              _selectedData = widget.data[index];
                            });
                          },
                        ),
                        maxY: maxY,
                      ),
                    );
                  },
                ),
                if (_showTooltip && _tooltipPosition != null && _selectedData != null)
                  Positioned(
                    left: _tooltipPosition!.dx - 50,
                    top: _tooltipPosition!.dy - 70,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('MMMM', 'es').format(_selectedData!.date),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  NumberFormat.compactCurrency(symbol: 'S/ ').format(_selectedData!.amount),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}