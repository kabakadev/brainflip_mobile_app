import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/deck_model.dart';
import '../../home/screens/dashboard_screen.dart';
import 'study_session_screen.dart';

class SessionCompleteScreen extends StatefulWidget {
  final DeckModel deck;
  final int cardsStudied;
  final int correctCount;
  final int incorrectCount;
  final Duration duration;

  const SessionCompleteScreen({
    super.key,
    required this.deck,
    required this.cardsStudied,
    required this.correctCount,
    required this.incorrectCount,
    required this.duration,
  });

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _accuracyPercentage {
    if (widget.cardsStudied == 0) return 0;
    return (widget.correctCount / widget.cardsStudied * 100);
  }

  String get _performanceMessage {
    if (_accuracyPercentage >= 90) return 'Excellent Work!';
    if (_accuracyPercentage >= 75) return 'Great Job!';
    if (_accuracyPercentage >= 60) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  Color get _performanceColor {
    if (_accuracyPercentage >= 90) return AppColors.success;
    if (_accuracyPercentage >= 75) return const Color(0xFF10B981);
    if (_accuracyPercentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // 1. ADD THIS WIDGET
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Circular progress indicator
                _buildCircularProgress(),

                const SizedBox(height: 24),

                // Performance message
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Text(
                    _performanceMessage,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: _performanceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'You\'ve completed your study session',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Stats cards
                _buildStatsCards(),

                const SizedBox(height: 32),

                // Streak indicator
                _buildStreakIndicator(),

                const SizedBox(height: 32),

                // Badges earned (placeholder)
                _buildBadgesSection(),

                // 2. REMOVE THE SPACER
                // const Spacer(),

                // 3. ADD A SIZEDBOX FOR SPACING
                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.layers, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text('FlashLearn', style: AppTextStyles.headingLarge),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            children: [
              // Background circle
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  backgroundColor: AppColors.gray200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gray200,
                  ),
                ),
              ),

              // Animated progress circle
              SizedBox(
                width: 180,
                height: 180,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: CircularProgressIndicator(
                    value:
                        _progressAnimation.value * (_accuracyPercentage / 100),
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _performanceColor,
                    ),
                  ),
                ),
              ),

              // Center text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_accuracyPercentage * _progressAnimation.value).toInt()}%',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: 48,
                        color: _performanceColor,
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${widget.cardsStudied}',
            'Cards',
            Icons.style_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${widget.correctCount}',
            'Correct',
            Icons.check_circle_outline,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            _formatDuration(widget.duration),
            'Time',
            Icons.timer_outlined,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStreakIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.streakOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.streakOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('8 Day Streak!', style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(
                  'Keep it going',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Badges Earned', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(Icons.emoji_events, 'First Study'),
            const SizedBox(width: 16),
            _buildBadge(Icons.speed, 'Speed Demon'),
            const SizedBox(width: 16),
            _buildBadge(Icons.psychology, 'Brain Power'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 2),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Study Again',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => StudySessionScreen(deck: widget.deck),
              ),
            );
          },
          icon: Icons.replay,
        ),
        const SizedBox(height: 12),

        // =====  This is the correct, non-lazy implementation =====
        CustomButton(
          text: 'Back to Home',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
          type: ButtonType.text, // This will now work correctly
        ),
        // =========================================================
      ],
    );
  }
}
