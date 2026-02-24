import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RadialBackground extends StatelessWidget {
  final Widget child;
  final Color? color;

  const RadialBackground({
    super.key,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color ?? AppColors.lightBlue,
      body: Stack(
        children: [
          // Radial Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Colors.white,
                  AppColors.lightBlue,
                ],
              ),
            ),
          ),
          
          // Dotted Pattern Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: DotPainter(
                color: AppColors.dotAccent,
                spacing: 30,
              ),
            ),
          ),
          
          // Subtle glowing orbs for "futuristic" feel
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class DotPainter extends CustomPainter {
  final Color color;
  final double spacing;

  DotPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x + y) % (spacing * 2) == 0) continue; // Create a pattern
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
