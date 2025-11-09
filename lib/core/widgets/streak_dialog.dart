import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StreakDialog extends StatelessWidget {
  final int streakCount;
  final String message;

  const StreakDialog({
    super.key,
    required this.streakCount,
    required this.message,
  });

  static Future<void> show(
    BuildContext context, {
    required int streakCount,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          StreakDialog(streakCount: streakCount, message: message),
    );
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 100) return '🏆';
    if (streak >= 50) return '💎';
    if (streak >= 30) return '🌟';
    if (streak >= 14) return '⚡';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '💪';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.streakOrange,
              AppColors.streakOrange.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak emoji
            Text(
              _getStreakEmoji(streakCount),
              style: const TextStyle(fontSize: 80),
            ),

            const SizedBox(height: 16),

            // Streak count
            Text(
              '$streakCount Day Streak!',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.streakOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
