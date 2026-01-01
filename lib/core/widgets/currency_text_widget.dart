import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyTextWidget extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String currencySymbol;

  const CurrencyTextWidget({
    super.key,
    required this.amount,
    this.style,
    this.currencySymbol = 'S/',
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Text(
      formatter.format(amount),
      style: style,
    );
  }
}

