import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';

class EmptyStateIllustrator extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateIllustrator({
    super.key,
    this.title = 'No hay movimientos',
    this.subtitle = 'Agrega tu primer movimiento para comenzar',
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyStateIllustrator> createState() => _EmptyStateIllustratorState();
}

class _EmptyStateIllustratorState extends State<EmptyStateIllustrator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildIllustration(),
              const SizedBox(height: 32),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: 32),
                _buildActionButton(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _EmptyWalletPainter(),
      ),
    );
  }

  Widget _buildActionButton() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      animateBorder: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAction,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7E57C2),
                  const Color(0xFF673AB7),
                ],
              ),
            ),
            child: Text(
              widget.actionLabel!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.3);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, paint);

    final cardOffset = radius * 0.3;
    for (var i = 0; i < 3; i++) {
      final yOffset = center.dy - cardOffset + (i * 15.0);
      canvas.drawLine(
        Offset(center.dx - radius * 0.6, yOffset),
        Offset(center.dx + radius * 0.6, yOffset),
        paint..strokeWidth = 2,
      );
    }

    final plusSize = radius * 0.4;
    final plusPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF7E57C2)
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - plusSize / 2, center.dy),
      Offset(center.dx + plusSize / 2, center.dy),
      plusPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - plusSize / 2),
      Offset(center.dx, center.dy + plusSize / 2),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

