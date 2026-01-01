import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/currency_text_widget.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String currencySymbol;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOutExpo,
    this.currencySymbol = 'S/',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return CurrencyTextWidget(
          amount: animatedValue,
          style: style,
          currencySymbol: currencySymbol,
        );
      },
    );
  }
}

