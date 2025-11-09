import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/badge.dart';
import '../models/daily_goal.dart';
import '../models/user_stats.dart';

// ===== 1. IMPORT THE SETTINGS SERVICE =====
import 'settings_service.dart';
// ==========================================

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== BADGES ====================
  // (All your badge code remains unchanged)

  /// Get user's unlocked badges
  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();

      return snapshot.docs.map((doc) => Badge.fromMap(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user badges: $e');
      }
      return [];
    }
  }

  /// Check and unlock new badges
  Future<List<Badge>> checkAndUnlockBadges({
    required String userId,
    required UserStats stats,
    int? sessionAverageTime,
  }) async {
    try {
      final unlockedBadges = await getUserBadges(userId);
      final unlockedIds = unlockedBadges.map((b) => b.id).toSet();
      final newlyUnlocked = <Badge>[];

      final allBadges = Badge.getAllBadges();

      for (final badge in allBadges) {
        // Skip if already unlocked
        if (unlockedIds.contains(badge.id)) continue;

        bool shouldUnlock = false;

        switch (badge.type) {
          case BadgeType.firstStudy:
            shouldUnlock = stats.totalSessions >= badge.requirement;
            break;

          case BadgeType.streak7:
            shouldUnlock = stats.currentStreak >= badge.requirement;
            break;

          case BadgeType.streak30:
            shouldUnlock = stats.currentStreak >= badge.requirement;
            break;

          case BadgeType.cards100:
            shouldUnlock = stats.totalCardsStudied >= badge.requirement;
            break;

          case BadgeType.cards500:
            shouldUnlock = stats.totalCardsStudied >= badge.requirement;
            break;

          case BadgeType.cards1000:
            shouldUnlock = stats.totalCardsStudied >= badge.requirement;
            break;

          case BadgeType.accuracy90:
            shouldUnlock = stats.overallAccuracy >= badge.requirement;
            break;

          case BadgeType.speedDemon:
            if (sessionAverageTime != null) {
              shouldUnlock = sessionAverageTime <= badge.requirement;
            }
            break;

          case BadgeType.earlyBird:
            final hour = DateTime.now().hour;
            shouldUnlock = hour < 8 && stats.totalSessions > 0;
            break;

          case BadgeType.nightOwl:
            final hour = DateTime.now().hour;
            shouldUnlock = hour >= 22 && stats.totalSessions > 0;
            break;

          case BadgeType.perfectWeek:
          case BadgeType.decksCompleted5:
            // TODO: Implement these when we have more data
            break;
        }

        if (shouldUnlock) {
          final unlockedBadge = badge.copyWith(unlockedAt: DateTime.now());
          await _unlockBadge(userId, unlockedBadge);
          newlyUnlocked.add(unlockedBadge);

          if (kDebugMode) {
            print('🎉 Badge unlocked: ${badge.name}');
          }
        }
      }

      return newlyUnlocked;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking badges: $e');
      }
      return [];
    }
  }

  /// Unlock a badge for user
  Future<void> _unlockBadge(String userId, Badge badge) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badge.id)
          .set(badge.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unlocking badge: $e');
      }
    }
  }

  Future<DailyGoal> getTodayGoal(String userId) async {
    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_goals')
          .doc(dateKey);

      final doc = await docRef.get();

      // Get the target from settings, we'll need it either way
      final int savedTarget = SettingsService.getDailyGoalTarget();

      if (doc.exists) {
        // --- START: NEW LOGIC ---
        final goal = DailyGoal.fromMap(doc.data()!, doc.id);

        // Check if the saved goal in Firestore matches the user's settings
        if (goal.targetCards != savedTarget) {
          // It doesn't match! Update the goal in Firestore.
          final updatedGoal = DailyGoal(
            id: goal.id,
            userId: goal.userId,
            date: goal.date,
            targetCards: savedTarget, // Use the new target from settings
            completedCards: goal.completedCards,
            // Re-check if it's completed with the new target
            isCompleted: goal.completedCards >= savedTarget,
          );

          await docRef.set(updatedGoal.toMap()); // Overwrite with correct data
          return updatedGoal; // Return the updated goal
        } else {
          // The target matches, just return the goal as is
          return goal;
        }
        // --- END: NEW LOGIC ---
      } else {
        // This is our previous fix, which is still correct for new days
        final newGoal = DailyGoal(
          id: dateKey,
          userId: userId,
          date: today,
          targetCards: savedTarget, // Use the saved target
        );

        await docRef.set(newGoal.toMap());
        return newGoal;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting daily goal: $e');
      }

      // Fallback logic (also uses saved target)
      final int target = SettingsService.getDailyGoalTarget();
      return DailyGoal(
        id: 'error',
        userId: userId,
        date: DateTime.now(),
        targetCards: target,
      );
    }
  }

  /// Update daily goal progress
  Future<void> updateDailyGoalProgress({
    required String userId,
    required int cardsStudied,
  }) async {
    try {
      final goal = await getTodayGoal(userId);
      final newCompleted = goal.completedCards + cardsStudied;
      final isCompleted = newCompleted >= goal.targetCards;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_goals')
          .doc(goal.id)
          .update({'completedCards': newCompleted, 'isCompleted': isCompleted});

      if (kDebugMode) {
        print('✅ Daily goal updated: $newCompleted/${goal.targetCards}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating daily goal: $e');
      }
    }
  }

  /// Get goal history
  Future<List<DailyGoal>> getGoalHistory(String userId, {int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_goals')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DailyGoal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching goal history: $e');
      }
      return [];
    }
  }

  // ==================== STREAK MANAGEMENT ====================
  // (All your streak management code remains unchanged)

  /// Check if streak should be reset
  bool shouldResetStreak(DateTime? lastStudyDate) {
    if (lastStudyDate == null) return false;

    final now = DateTime.now();
    final lastStudy = DateTime(
      lastStudyDate.year,
      lastStudyDate.month,
      lastStudyDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // If last study was before yesterday, streak is broken
    return lastStudy.isBefore(yesterday);
  }

  /// Get streak emoji based on count
  String getStreakEmoji(int streak) {
    if (streak >= 100) return '🏆';
    if (streak >= 50) return '💎';
    if (streak >= 30) return '🌟';
    if (streak >= 14) return '⚡';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '💪';
    return '✨';
  }

  /// Get motivational message for streak
  String getStreakMessage(int streak) {
    if (streak >= 100) return 'Legendary streak! You\'re unstoppable!';
    if (streak >= 50) return 'Incredible dedication! Keep it up!';
    if (streak >= 30) return 'You\'re on fire! Amazing consistency!';
    if (streak >= 14) return 'Two weeks strong! You\'re crushing it!';
    if (streak >= 7) return 'One week streak! Great momentum!';
    if (streak >= 3) return 'Great start! Keep the momentum going!';
    return 'New streak started! Keep going!';
  }
}
