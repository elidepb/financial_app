import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/core/widgets/custom_bottom_nav.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/date_range_selector.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/adaptive_comparison_layout.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';

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

  List<MonthlyData> _getMonthlyData() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return MonthlyData(
        date: date,
        amount: 1500.0 + (index * 200.0) + (index % 3) * 150.0,
      );
    });
  }

  List<MonthlyData> _getTrendData() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return MonthlyData(
        date: date,
        amount: 1200.0 + (index * 180.0) + (index % 2) * 100.0,
      );
    });
  }

  List<CategoryRankData> _getTopCategories() {
    return [
      const CategoryRankData(
        name: 'Alimentación',
        icon: Icons.restaurant,
        color: Color(0xFF7E57C2),
        amount: 2450.0,
      ),
      const CategoryRankData(
        name: 'Transporte',
        icon: Icons.directions_car,
        color: Color(0xFFE91E63),
        amount: 1800.0,
      ),
      const CategoryRankData(
        name: 'Hogar',
        icon: Icons.home,
        color: Color(0xFF26C6DA),
        amount: 1200.0,
      ),
      const CategoryRankData(
        name: 'Ocio',
        icon: Icons.movie,
        color: Color(0xFFFFB74D),
        amount: 850.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();
    final trendData = _getTrendData();
    final topCategories = _getTopCategories();
    
    final currentMonthAmount = monthlyData.isNotEmpty ? monthlyData.last.amount : 0.0;
    final previousMonthAmount = monthlyData.length > 1 
        ? monthlyData[monthlyData.length - 2].amount 
        : 0.0;
    
    final currentMonthTrend = [1200.0, 1350.0, 1400.0, 1500.0, 1600.0, 1700.0, currentMonthAmount];
    final previousMonthTrend = [1100.0, 1200.0, 1250.0, 1300.0, 1400.0, 1450.0, previousMonthAmount];

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                currentMonthTrend: currentMonthTrend,
                previousMonthTrend: previousMonthTrend,
              ),
              
              const SizedBox(height: AppDimensions.paddingLG),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}