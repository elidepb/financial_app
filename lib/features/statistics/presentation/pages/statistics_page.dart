import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/core/widgets/custom_bottom_nav.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/date_range_selector.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/adaptive_comparison_layout.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';
import 'package:app_gestor_financiero/features/statistics/data/providers/statistics_providers.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  final String? categoryFilter;

  const StatisticsPage({
    super.key,
    this.categoryFilter,
  });

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  DateRange _selectedRange = DateRange.sixMonths;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    
    switch (_selectedRange) {
      case DateRange.threeMonths:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 3, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case DateRange.sixMonths:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 6, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case DateRange.oneYear:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case DateRange.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return DateTimeRange(start: _customStartDate!, end: _customEndDate!);
        }
        return DateTimeRange(
          start: DateTime(now.year, now.month - 6, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
    }
  }

  List<double> _calculateTrend(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) return [];
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    
    final Map<DateTime, double> monthMap = {
      for (var data in monthlyData) data.date: data.amount
    };
    
    final result = <double>[];
    for (int i = 6; i >= 0; i--) {
      final month = DateTime(currentMonth.year, currentMonth.month - i, 1);
      result.add(monthMap[month] ?? 0.0);
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = _getDateRange();
    final monthlyDataAsync = ref.watch(monthlyDataProvider(dateRange));
    final topCategoriesAsync = ref.watch(topCategoriesProvider(dateRange));

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: monthlyDataAsync.when(
          data: (monthlyData) {
            return topCategoriesAsync.when(
              data: (topCategories) {
                final currentMonthAmount = monthlyData.isNotEmpty ? monthlyData.last.amount : 0.0;
                final previousMonthAmount = monthlyData.length > 1 
                    ? monthlyData[monthlyData.length - 2].amount 
                    : 0.0;
                
                final currentMonthTrend = _calculateTrend(monthlyData);
                final previousMonthTrend = monthlyData.length > 1 
                    ? _calculateTrend(monthlyData.sublist(0, monthlyData.length - 1))
                    : currentMonthTrend.map((e) => 0.0).toList();
                
                final trendData = monthlyData;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.categoryFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7E57C2).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.filter_list, color: Color(0xFF7E57C2), size: 20),
                                ),
                                const SizedBox(width: AppDimensions.paddingSM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filtro Activo',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        widget.categoryFilter!,
                                        style: const TextStyle(
                                          color: Colors.white, 
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white70),
                                  onPressed: () {
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      DateRangeSelector(
                        selectedRange: _selectedRange,
                        customStartDate: _customStartDate,
                        customEndDate: _customEndDate,
                        onRangeChanged: (range) => setState(() => _selectedRange = range),
                        onCustomRangeChanged: (range) {
                          if (range != null) {
                            setState(() {
                              _customStartDate = range.start;
                              _customEndDate = range.end;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLG),
                      
                      AdaptiveComparisonLayout(
                        monthlyData: monthlyData,
                        trendData: trendData,
                        topCategories: topCategories,
                        currentMonthAmount: currentMonthAmount,
                        previousMonthAmount: previousMonthAmount,
                        currentMonthTrend: currentMonthTrend.length >= 7 
                            ? currentMonthTrend 
                            : [...List.filled(7 - currentMonthTrend.length, 0.0), ...currentMonthTrend],
                        previousMonthTrend: previousMonthTrend.length >= 7
                            ? previousMonthTrend
                            : [...List.filled(7 - previousMonthTrend.length, 0.0), ...previousMonthTrend],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLG),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
