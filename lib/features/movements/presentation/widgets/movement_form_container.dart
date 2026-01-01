import 'dart:ui';
import 'package:flutter/material.dart';

class MovementFormContainer extends StatelessWidget {
  final Widget child;
  final bool isMobile;

  const MovementFormContainer({
    super.key,
    required this.child,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(isMobile ? 24 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 24 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: isMobile
                ? null
                : const BoxConstraints(
                    maxHeight: 700,
                  ),
            child: child,
          ),
        ),
      ),
    );
  }
}

