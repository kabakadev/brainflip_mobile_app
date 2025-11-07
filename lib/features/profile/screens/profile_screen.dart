import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/progress_service.dart';
import '../../../services/user_flashcard_service.dart';
import '../../../services/firestore_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../models/user_stats.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();
  final UserFlashcardService _userFlashcardService = UserFlashcardService();
  final FirestoreService _firestoreService = FirestoreService();

  UserStats _userStats = UserStats();
  int _totalDueCards = 0;
  int _totalReviewedCards = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Load user stats
      final stats = await _progressService.getUserStats(userId);

      // Get all user's decks
      final selectedDeckIds = await _firestoreService.getUserSelectedDecks(
        userId,
      );

      // Count total due cards across all decks
      int totalDue = 0;
      for (final deckId in selectedDeckIds) {
        final dueCards = await _userFlashcardService.getDueCards(
          userId: userId,
          deckId: deckId,
        );
        totalDue += dueCards.length;
      }

      setState(() {
        _userStats = stats;
        _totalDueCards = totalDue;
        _totalReviewedCards = stats.totalCardsStudied;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(user?.email ?? ''),

                  const SizedBox(height: 32),

                  // Stats section
                  Text('Your Stats', style: AppTextStyles.headingLarge),

                  const SizedBox(height: 16),

                  _buildStatsGrid(),

                  const SizedBox(height: 32),

                  // Spaced repetition info
                  _buildSpacedRepetitionInfo(),

                  const SizedBox(height: 32),

                  // Achievements section
                  _buildAchievementsSection(),

                  const SizedBox(height: 32),

                  // Sign out button
                  CustomButton(
                    text: 'Sign Out',
                    onPressed: _handleSignOut,
                    type: ButtonType.outline,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Text(
              email.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(email, style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text(
            'Member since ${_userStats.lastStudyDate?.year ?? DateTime.now().year}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${_userStats.totalCardsStudied}',
                'Total Cards',
                Icons.style_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_userStats.currentStreak}',
                'Day Streak',
                Icons.local_fire_department,
                AppColors.streakOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${_userStats.overallAccuracy.toInt()}%',
                'Accuracy',
                Icons.show_chart,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_userStats.totalSessions}',
                'Sessions',
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(20),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headingLarge.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpacedRepetitionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Spaced Repetition', style: AppTextStyles.headingMedium),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Due for Review', '$_totalDueCards cards'),
          const SizedBox(height: 8),
          _buildInfoRow('Total Reviewed', '$_totalReviewedCards cards'),
          const SizedBox(height: 8),
          _buildInfoRow('Longest Streak', '${_userStats.longestStreak} days'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements', style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildAchievementBadge(
              Icons.emoji_events,
              'First Study',
              _userStats.totalSessions > 0,
            ),
            _buildAchievementBadge(
              Icons.local_fire_department,
              '7 Day Streak',
              _userStats.currentStreak >= 7,
            ),
            _buildAchievementBadge(
              Icons.star,
              '100 Cards',
              _userStats.totalCardsStudied >= 100,
            ),
            _buildAchievementBadge(
              Icons.speed,
              '90% Accuracy',
              _userStats.overallAccuracy >= 90,
            ),
            _buildAchievementBadge(
              Icons.psychology,
              'Brain Power',
              _userStats.totalCardsStudied >= 500,
            ),
            _buildAchievementBadge(
              Icons.military_tech,
              '30 Day Streak',
              _userStats.currentStreak >= 30,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.secondary.withOpacity(0.1)
                : AppColors.gray200,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? AppColors.secondary : AppColors.gray300,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? AppColors.secondary : AppColors.gray400,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
