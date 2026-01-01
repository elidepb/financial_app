import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/core/router/route_paths.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/widgets/ranking_tile.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';

class TopCategoryRankCard extends StatelessWidget {
  final List<CategoryRankData> categories;

  const TopCategoryRankCard({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.isNotEmpty
        ? categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b)
        : 0.0;

    final topThree = categories.take(3).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Top Categorías',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...topThree.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              duration: Duration(milliseconds: 600 + (index * 200)),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: index != 2 ? 16.0 : 0),
                      child: child,
                    ),
                  ),
                );
              },
              child: RankingTile(
                position: index + 1,
                categoryName: category.name,
                categoryIcon: category.icon,
                categoryColor: category.color,
                amount: category.amount,
                maxAmount: maxAmount,
                onTap: () {
                  context.push(
                    '${RoutePaths.expenses}?category=${category.name}',
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}