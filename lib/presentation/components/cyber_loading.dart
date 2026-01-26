import 'package:flutter/material.dart';
import 'dart:math' as math;

class CyberLoadingAnim extends StatefulWidget {
  final bool? isPrimary; // Opcjonalne tło, by widget wiedział jak dobrać kontrast

  const CyberLoadingAnim({super.key, this.isPrimary = false});

  @override
  State<CyberLoadingAnim> createState() => _CyberLoadingAnimState();
}

class _CyberLoadingAnimState extends State<CyberLoadingAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LOGIKA KOLORÓW:
    // Jeśli tło jest w kolorze Primary (Neonowy niebieski), elementy animacji będą białe/ciemne.
    // Jeśli tło jest szare lub ciemne, używamy koloru Primary.
    final bool isOnPrimary = widget.isPrimary!;
    final Color mainColor = isOnPrimary ? Colors.white : Theme.of(context).primaryColor;
    final Color secondaryColor = isOnPrimary ? Colors.black.withOpacity(0.3) : mainColor.withOpacity(0.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pobieramy mniejszy wymiar, aby zachować proporcje koła
        final double size = math.min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Zewnętrzny pierścień
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: _RingPainter(color: mainColor, isOuter: true),
                      ),
                    ),
                    // 2. Wewnętrzny pierścień
                    Transform.rotate(
                      angle: -_controller.value * 4 * math.pi,
                      child: CustomPaint(
                        size: Size(size * 0.7, size * 0.7),
                        painter: _RingPainter(color: secondaryColor, isOuter: false),
                      ),
                    ),
                    // 3. Rdzeń
                    Container(
                      width: size * 0.15,
                      height: size * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor,
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.6 * (1 - _controller.value)),
                            blurRadius: (size * 0.15) * _controller.value,
                            spreadRadius: (size * 0.05) * _controller.value,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final bool isOuter;

  _RingPainter({required this.color, required this.isOuter});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (isOuter ? 0.04 : 0.03)
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < (isOuter ? 4 : 3); i++) {
      double startAngle = (i * (isOuter ? 90 : 120)) * math.pi / 180;
      double sweepAngle = (isOuter ? 45 : 70) * math.pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}