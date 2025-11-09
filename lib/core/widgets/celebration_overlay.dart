import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool show;

  const CelebrationOverlay({super.key, required this.child, this.show = false});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Generate confetti
    _generateConfetti();

    // ===== THE FIX =====
    // Add this check to start the animation
    // if the widget is BUILT with show: true.
    if (widget.show) {
      _controller.forward(from: 0);
    }
    // =================
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confetti.add(
        Confetti(
          x: random.nextDouble(),
          y: -random.nextDouble() * 0.1,
          color: _getRandomColor(random),
          size: random.nextDouble() * 10 + 5,
          rotation: random.nextDouble() * math.pi * 2,
          velocity: random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      Colors.purple,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // In CelebrationOverlay.dart

  // In CelebrationOverlay.dart
  // In CelebrationOverlay.dart

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: The scrollable content
        widget.child,

        // Layer 2: The confetti
        if (widget.show)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // By default (size: Size.zero and no child),
                  // this CustomPaint will fill the constraints
                  // from Positioned.fill.
                  return CustomPaint(
                    painter: ConfettiPainter(
                      confetti: _confetti,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
        // The extra erroneous line has been removed from here.
      ],
    );
  }
}

class Confetti {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double rotation;
  final double velocity;

  Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocity,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double progress;

  ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final paint = Paint()
        ..color = piece.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      final x = piece.x * size.width;
      final y =
          piece.y * size.height + (progress * size.height * piece.velocity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + progress * math.pi * 4);

      // Draw confetti piece (rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.size,
        height: piece.size / 2,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
