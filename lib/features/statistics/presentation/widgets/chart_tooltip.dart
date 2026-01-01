import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';
import 'package:intl/intl.dart';

class ChartTooltip extends StatelessWidget {
  final Offset position;
  final MonthlyData data;
  final Color lineColor;

  const ChartTooltip({
    super.key,
    required this.position,
    required this.data,
    this.lineColor = const Color(0xFF7E57C2),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 60,
      top: position.dy - 90,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 10),
              child: child,
            ),
          );
        },
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
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
                    DateFormat('MMMM yyyy', 'es').format(data.date),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: 'S/ ', decimalDigits: 0)
                        .format(data.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChartTooltipIndicator extends StatelessWidget {
  final Offset position;
  final Color lineColor;

  const ChartTooltipIndicator({
    super.key,
    required this.position,
    this.lineColor = const Color(0xFF7E57C2),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 6,
      top: position.dy - 6,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: lineColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: lineColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

