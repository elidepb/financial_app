import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/chart_tooltip.dart';
import 'package:intl/intl.dart';

class TrendLineChart extends StatefulWidget {
  final List<MonthlyData> data;
  final Color lineColor;

  const TrendLineChart({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF7E57C2),
  });

  @override
  State<TrendLineChart> createState() => _TrendLineChartState();
}

class _TrendLineChartState extends State<TrendLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Offset? _tooltipPosition;
  MonthlyData? _selectedData;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
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

    final maxY = widget.data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    final minY = widget.data.map((d) => d.amount).reduce((a, b) => a < b ? a : b) * 0.8;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia de Gastos',
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
                    final currentLimit = (_animation.value * widget.data.length).ceil();
                    final visibleSpots = widget.data
                        .asMap()
                        .entries
                        .where((e) => e.key < currentLimit)
                        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                        .toList();

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxY - minY) / 4,
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
                              interval: 1,
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
                              interval: (maxY - minY) / 4,
                              getTitlesWidget: (value, meta) {
                                if (value == minY) return const SizedBox.shrink(); 
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: visibleSpots,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: widget.lineColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: widget.lineColor,
                                );
                              },
                              checkToShowDot: (spot, barData) {
                                return spot.x == _selectedData?.date.month;
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  widget.lineColor.withOpacity(0.3),
                                  widget.lineColor.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.8],
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: false,
                          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.lineBarSpots == null) {
                              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                                setState(() {
                                  _showTooltip = false;
                                  _selectedData = null;
                                });
                              }
                              return;
                            }
                            
                            final spot = response.lineBarSpots!.first;
                            final index = spot.x.toInt();

                            if (index >= 0 && index < widget.data.length) {
                              setState(() {
                                _showTooltip = true;
                                _tooltipPosition = event.localPosition;
                                _selectedData = widget.data[index];
                              });
                            }
                          },
                        ),
                        minY: minY,
                        maxY: maxY * 1.1,
                        minX: 0,
                        maxX: (widget.data.length - 1).toDouble(),
                      ),
                    );
                  },
                ),

                if (_showTooltip && _tooltipPosition != null && _selectedData != null)
                  ChartTooltip(
                    position: _tooltipPosition!,
                    data: _selectedData!,
                    lineColor: widget.lineColor,
                  ),
                
                 if (_showTooltip && _tooltipPosition != null)
                   ChartTooltipIndicator(
                     position: _tooltipPosition!,
                     lineColor: widget.lineColor,
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}