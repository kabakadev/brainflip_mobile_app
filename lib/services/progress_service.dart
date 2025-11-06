import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/study_progress.dart';
import '../models/user_stats.dart';
import '../models/deck_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STUDY PROGRESS ====================

  /// Save a completed study session
  Future<void> saveStudySession({
    required String userId,
    required String deckId,
    required int cardsStudied,
    required int correctAnswers,
    required int incorrectAnswers,
    required Duration duration,
  }) async {
    try {
      final accuracy = cardsStudied > 0
          ? (correctAnswers / cardsStudied * 100)
          : 0.0;

      final progress = StudyProgress(
        id: '',
        userId: userId,
        deckId: deckId,
        cardsStudied: cardsStudied,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        sessionDate: DateTime.now(),
        duration: duration,
        accuracy: accuracy,
      );

      // Save to study_progress collection
      await _firestore.collection('study_progress').add(progress.toMap());

      // Update user stats
      await _updateUserStats(
        userId: userId,
        cardsStudied: cardsStudied,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        duration: duration,
      );

      // Update deck progress
      await _updateDeckProgress(
        userId: userId,
        deckId: deckId,
        cardsStudied: cardsStudied,
      );

      if (kDebugMode) {
        print('✅ Study session saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving study session: $e');
      }
      rethrow;
    }
  }

  /// Get user's study history
  Future<List<StudyProgress>> getStudyHistory(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('study_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('sessionDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StudyProgress.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching study history: $e');
      }
      return [];
    }
  }

  // ==================== USER STATS ====================

  /// Get user stats
  Future<UserStats> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('overall')
          .get();

      if (doc.exists) {
        return UserStats.fromMap(doc.data()!);
      }

      // Return default stats if none exist
      return UserStats();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user stats: $e');
      }
      return UserStats();
    }
  }

  /// Update user stats after a study session
  Future<void> _updateUserStats({
    required String userId,
    required int cardsStudied,
    required int correctAnswers,
    required int incorrectAnswers,
    required Duration duration,
  }) async {
    try {
      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('overall');

      final doc = await statsRef.get();
      UserStats currentStats;

      if (doc.exists) {
        currentStats = UserStats.fromMap(doc.data()!);
      } else {
        currentStats = UserStats();
      }

      // Calculate new stats
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastStudyDay = currentStats.lastStudyDate != null
          ? DateTime(
              currentStats.lastStudyDate!.year,
              currentStats.lastStudyDate!.month,
              currentStats.lastStudyDate!.day,
            )
          : null;

      // Update cards studied today
      int cardsStudiedToday;
      if (lastStudyDay == today) {
        cardsStudiedToday = currentStats.cardsStudiedToday + cardsStudied;
      } else {
        cardsStudiedToday = cardsStudied;
      }

      // Update streak
      int currentStreak = currentStats.currentStreak;
      if (lastStudyDay == null) {
        // First time studying
        currentStreak = 1;
      } else if (lastStudyDay == today) {
        // Already studied today, maintain streak
        currentStreak = currentStats.currentStreak;
      } else if (lastStudyDay == today.subtract(const Duration(days: 1))) {
        // Studied yesterday, increment streak
        currentStreak = currentStats.currentStreak + 1;
      } else {
        // Missed days, reset streak
        currentStreak = 1;
      }

      // Update longest streak
      final longestStreak = currentStreak > currentStats.longestStreak
          ? currentStreak
          : currentStats.longestStreak;

      // Calculate new overall accuracy
      final totalCorrect =
          (currentStats.overallAccuracy /
              100 *
              currentStats.totalCardsStudied) +
          correctAnswers;
      final newTotalCards = currentStats.totalCardsStudied + cardsStudied;
      final newAccuracy = newTotalCards > 0
          ? (totalCorrect / newTotalCards * 100)
          : 0.0;

      // Create updated stats
      final updatedStats = UserStats(
        totalCardsStudied: newTotalCards,
        cardsStudiedToday: cardsStudiedToday,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        overallAccuracy: newAccuracy,
        lastStudyDate: now,
        totalSessions: currentStats.totalSessions + 1,
        totalStudyTime: currentStats.totalStudyTime + duration,
      );

      // Save to Firestore
      await statsRef.set(updatedStats.toMap());

      if (kDebugMode) {
        print('✅ User stats updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user stats: $e');
      }
    }
  }

  // ==================== DECK PROGRESS ====================

  /// Get deck progress for a user
  Future<DeckProgress?> getDeckProgress(String userId, String deckId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('deck_progress')
          .doc(deckId)
          .get();

      if (doc.exists) {
        return DeckProgress.fromMap(doc.data()!, deckId);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching deck progress: $e');
      }
      return null;
    }
  }

  /// Get all deck progress for a user
  Future<Map<String, DeckProgress>> getAllDeckProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('deck_progress')
          .get();

      final Map<String, DeckProgress> progressMap = {};
      for (var doc in snapshot.docs) {
        progressMap[doc.id] = DeckProgress.fromMap(doc.data(), doc.id);
      }

      return progressMap;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching all deck progress: $e');
      }
      return {};
    }
  }

  /// Update deck progress
  Future<void> _updateDeckProgress({
    required String userId,
    required String deckId,
    required int cardsStudied,
  }) async {
    try {
      final progressRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('deck_progress')
          .doc(deckId);

      final doc = await progressRef.get();

      if (doc.exists) {
        final current = DeckProgress.fromMap(doc.data()!, deckId);
        final newCardsStudied = current.cardsStudied + cardsStudied;
        final newProgress = current.totalCards > 0
            ? (newCardsStudied / current.totalCards * 100)
            : 0.0;

        await progressRef.update({
          'cardsStudied': newCardsStudied,
          'progressPercentage': newProgress,
          'lastStudied': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new progress document
        final newProgress = DeckProgress(
          deckId: deckId,
          totalCards: cardsStudied, // We'll update this properly later
          cardsStudied: cardsStudied,
          progressPercentage: 0.0,
          lastStudied: DateTime.now(),
        );

        await progressRef.set(newProgress.toMap());
      }

      if (kDebugMode) {
        print('✅ Deck progress updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating deck progress: $e');
      }
    }
  }

  // ==================== ANALYTICS ====================

  /// Get cards studied per day for the last N days
  Future<Map<DateTime, int>> getCardsStudiedPerDay(
    String userId, {
    int days = 7,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('study_progress')
          .where('userId', isEqualTo: userId)
          .where('sessionDate', isGreaterThan: startDate.toIso8601String())
          .get();

      final Map<DateTime, int> dailyCards = {};

      for (var doc in snapshot.docs) {
        final progress = StudyProgress.fromMap(doc.data(), doc.id);
        final date = DateTime(
          progress.sessionDate.year,
          progress.sessionDate.month,
          progress.sessionDate.day,
        );

        dailyCards[date] = (dailyCards[date] ?? 0) + progress.cardsStudied;
      }

      return dailyCards;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching daily cards: $e');
      }
      return {};
    }
  }

  /// Get accuracy trend for the last N sessions
  Future<List<double>> getAccuracyTrend(
    String userId, {
    int sessions = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('study_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('sessionDate', descending: true)
          .limit(sessions)
          .get();

      return snapshot.docs
          .map((doc) => StudyProgress.fromMap(doc.data(), doc.id).accuracy)
          .toList()
          .reversed
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching accuracy trend: $e');
      }
      return [];
    }
  }
}
