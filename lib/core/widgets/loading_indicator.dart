import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
        ),
      ),
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
