import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/trend_line_chart.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/monthly_bar_chart.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/top_category_rank_card.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/comparison_card.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';

class AdaptiveComparisonLayout extends StatefulWidget {
  final List<MonthlyData> monthlyData;
  final List<MonthlyData> trendData;
  final List<CategoryRankData> topCategories;
  final double currentMonthAmount;
  final double previousMonthAmount;
  final List<double> currentMonthTrend;
  final List<double> previousMonthTrend;

  const AdaptiveComparisonLayout({
    super.key,
    required this.monthlyData,
    required this.trendData,
    required this.topCategories,
    required this.currentMonthAmount,
    required this.previousMonthAmount,
    required this.currentMonthTrend,
    required this.previousMonthTrend,
  });

  @override
  State<AdaptiveComparisonLayout> createState() => _AdaptiveComparisonLayoutState();
}

class _AdaptiveComparisonLayoutState extends State<AdaptiveComparisonLayout> {
  late PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9)
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppDimensions.breakpointMobile;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      key: const ValueKey('mobile_layout_col'),
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 2,
            itemBuilder: (context, index) {
              double percent = index - _pageOffset;
              double parallaxOffset = percent * 30;

              return Transform.translate(
                offset: Offset(parallaxOffset, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: index == 0
                      ? MonthlyBarChart(data: widget.monthlyData)
                      : TrendLineChart(data: widget.trendData),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF7E57C2)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        TopCategoryRankCard(
          categories: widget.topCategories,
        ),
        const SizedBox(height: 24),
        ComparisonCard(
          currentMonthAmount: widget.currentMonthAmount,
          previousMonthAmount: widget.previousMonthAmount,
          currentMonthTrend: widget.currentMonthTrend,
          previousMonthTrend: widget.previousMonthTrend,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return GridView.count(
      key: const ValueKey('desktop_layout_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        MonthlyBarChart(key: const ValueKey('bar'), data: widget.monthlyData),
        TrendLineChart(key: const ValueKey('line'), data: widget.trendData),
        TopCategoryRankCard(
          key: const ValueKey('rank'),
          categories: widget.topCategories,
        ),
        ComparisonCard(
          key: const ValueKey('comparison'),
          currentMonthAmount: widget.currentMonthAmount,
          previousMonthAmount: widget.previousMonthAmount,
          currentMonthTrend: widget.currentMonthTrend,
          previousMonthTrend: widget.previousMonthTrend,
        ),
      ],
    );
  }
}