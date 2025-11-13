import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _timerEnabled = true;
  int _timerDuration = 30; // seconds
  int _dailyGoalCards = 20;
  int _cardsPerSession = 5; // NEW

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _timerEnabled = SettingsService.isTimerEnabled();
      _timerDuration = SettingsService.getTimerDuration();
      _dailyGoalCards = SettingsService.getDailyGoalTarget();
      _cardsPerSession = SettingsService.getCardsPerSession(); // NEW
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Study Settings Section
          Text('Study Settings', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),

          _buildSettingCard(
            title: 'Timer',
            subtitle: 'Enable countdown timer during study',
            child: Switch(
              value: _timerEnabled,
              onChanged: (value) async {
                await SettingsService.setTimerEnabled(value);
                setState(() {
                  _timerEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          if (_timerEnabled)
            _buildSettingCard(
              title: 'Timer Duration',
              subtitle: '$_timerDuration seconds per card',
              child: Slider(
                value: _timerDuration.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                label: '${_timerDuration}s',
                onChanged: (value) {
                  setState(() {
                    _timerDuration = value.toInt();
                  });
                },
                onChangeEnd: (value) async {
                  await SettingsService.setTimerDuration(value.toInt());
                },
                activeColor: AppColors.primary,
              ),
            ),

          const SizedBox(height: 12),

          // ===== NEW: Cards Per Session Setting =====
          _buildSettingCard(
            title: 'Cards Per Session',
            subtitle: '$_cardsPerSession cards per study session',
            child: Slider(
              value: _cardsPerSession.toDouble(),
              min: 5,
              max: 50,
              divisions: 9, // 5, 10, 15, 20, 25, 30, 35, 40, 45, 50
              label: '$_cardsPerSession cards',
              onChanged: (value) {
                setState(() {
                  _cardsPerSession = value.toInt();
                });
              },
              onChangeEnd: (value) async {
                await SettingsService.setCardsPerSession(value.toInt());
              },
              activeColor: AppColors.primary,
            ),
          ),

          // ==========================================
          const SizedBox(height: 32),

          // Goals Section
          Text('Goals', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),

          _buildSettingCard(
            title: 'Daily Goal',
            subtitle: '$_dailyGoalCards cards per day',
            child: Slider(
              value: _dailyGoalCards.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              label: '$_dailyGoalCards cards',
              onChanged: (value) {
                setState(() {
                  _dailyGoalCards = value.toInt();
                });
              },
              onChangeEnd: (value) async {
                await SettingsService.setDailyGoalTarget(value.toInt());
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          // Notifications Section
          Text('Notifications', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),

          _buildSettingCard(
            title: 'Daily Reminders',
            subtitle: 'Get reminded to study',
            child: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notifications
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            title: 'Streak Notifications',
            subtitle: 'Celebrate your streaks',
            child: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notifications
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          // About Section
          Text('About', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),

          _buildSettingCard(
            title: 'App Version',
            subtitle: '1.0.0',
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
