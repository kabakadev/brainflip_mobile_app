import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../models/user_flashcard.dart';
import '../../../core/constants/spaced_repetition_constants.dart';

class SpacedRepetitionService {
  /// Calculate next review schedule using improved two-phase algorithm
  ///
  /// Phase 1: Learning (short intervals in minutes)
  /// Phase 2: Review (long intervals in days)
  ///
  /// quality: 0-3 rating
  /// - 0: Wrong answer (Again)
  /// - 1: Correct but hard
  /// - 2: Correct, normal (Good)
  /// - 3: Correct, very easy (Easy)
  UserFlashcard calculateNextReview({
    required UserFlashcard userCard,
    required int quality,
  }) {
    // Clamp quality to valid range
    quality = quality.clamp(0, 3);

    if (kDebugMode) {
      print('📊 SR Calculation START:');
      print('   Status: ${userCard.status}');
      print('   Quality: $quality');
      print('   Learning Step: ${userCard.learningStep}');
      print('   Consecutive Correct: ${userCard.consecutiveCorrect}');
    }

    // Route to appropriate handler
    if (userCard.isLearning) {
      return _handleLearningPhase(userCard, quality);
    } else {
      return _handleReviewPhase(userCard, quality);
    }
  }

  /// Handle cards in learning phase (short intervals)
  UserFlashcard _handleLearningPhase(UserFlashcard userCard, int quality) {
    final now = DateTime.now();
    DateTime nextReview;
    int newLearningStep = userCard.learningStep;
    int newConsecutiveCorrect = userCard.consecutiveCorrect;
    bool stillLearning = true;
    int newInterval = userCard.interval;

    if (quality == SpacedRepetitionConstants.qualityAgain) {
      // Wrong answer - restart learning
      newLearningStep = 0;
      newConsecutiveCorrect = 0;
      nextReview = now.add(
        Duration(minutes: SpacedRepetitionConstants.learningSteps[0]),
      );

      if (kDebugMode) {
        print('   ❌ Wrong - Restarting learning');
        print(
          '   Next review in: ${SpacedRepetitionConstants.learningSteps[0]} min',
        );
      }
    } else {
      // Correct answer - advance learning
      newConsecutiveCorrect++;

      if (newConsecutiveCorrect >=
          SpacedRepetitionConstants.graduationThreshold) {
        // Graduate to review phase!
        stillLearning = false;
        newInterval = SpacedRepetitionConstants.graduatingInterval;
        nextReview = now.add(Duration(days: newInterval));

        if (kDebugMode) {
          print('   🎓 GRADUATED! Moving to review phase');
          print('   Next review in: $newInterval day(s)');
        }
      } else {
        // Move to next learning step
        newLearningStep++;
        if (newLearningStep >= SpacedRepetitionConstants.learningSteps.length) {
          newLearningStep = SpacedRepetitionConstants.learningSteps.length - 1;
        }

        final minutesUntilNext =
            SpacedRepetitionConstants.learningSteps[newLearningStep];
        nextReview = now.add(Duration(minutes: minutesUntilNext));

        if (kDebugMode) {
          print('   ✅ Correct - Advancing learning');
          print(
            '   Consecutive: $newConsecutiveCorrect/${SpacedRepetitionConstants.graduationThreshold}',
          );
          print('   Next review in: $minutesUntilNext min');
        }
      }
    }

    // Update statistics
    final newTimesReviewed = userCard.timesReviewed + 1;
    final newTimesCorrect = quality > 0
        ? userCard.timesCorrect + 1
        : userCard.timesCorrect;
    final newTimesIncorrect = quality == 0
        ? userCard.timesIncorrect + 1
        : userCard.timesIncorrect;

    return userCard.copyWith(
      isLearning: stillLearning,
      learningStep: newLearningStep,
      consecutiveCorrect: newConsecutiveCorrect,
      interval: newInterval,
      lastReviewed: now,
      nextReview: nextReview,
      quality: quality,
      timesReviewed: newTimesReviewed,
      timesCorrect: newTimesCorrect,
      timesIncorrect: newTimesIncorrect,
      repetitions: stillLearning ? 0 : 1,
    );
  }

  /// Handle cards in review phase (long intervals)
  UserFlashcard _handleReviewPhase(UserFlashcard userCard, int quality) {
    final now = DateTime.now();
    double newEaseFactor = userCard.easeFactor;
    int newInterval;
    int newRepetitions = userCard.repetitions;
    bool backToLearning = false;

    if (quality == SpacedRepetitionConstants.qualityAgain) {
      // Failed review - back to learning phase!
      backToLearning = true;
      newRepetitions = 0;

      final minutesUntilNext = SpacedRepetitionConstants.relearnSteps[0];
      final nextReview = now.add(Duration(minutes: minutesUntilNext));

      if (kDebugMode) {
        print('   ❌ Failed review - Back to learning');
        print('   Next review in: $minutesUntilNext min');
      }

      // Update statistics
      final newTimesReviewed = userCard.timesReviewed + 1;
      final newTimesIncorrect = userCard.timesIncorrect + 1;

      return userCard.copyWith(
        isLearning: true,
        learningStep: 0,
        consecutiveCorrect: 0,
        lastReviewed: now,
        nextReview: nextReview,
        quality: quality,
        repetitions: newRepetitions,
        timesReviewed: newTimesReviewed,
        timesIncorrect: newTimesIncorrect,
      );
    }

    // Successful review - calculate new interval
    newRepetitions++;

    // Adjust ease factor based on quality
    if (quality == SpacedRepetitionConstants.qualityHard) {
      newEaseFactor -= 0.15;
    } else if (quality == SpacedRepetitionConstants.qualityEasy) {
      newEaseFactor += SpacedRepetitionConstants.easyBonus;
    }

    // Ensure ease factor stays within bounds
    newEaseFactor = newEaseFactor.clamp(
      SpacedRepetitionConstants.minimumEaseFactor,
      double.infinity,
    );

    // Calculate new interval using SM-2 algorithm
    if (newRepetitions == 1) {
      newInterval = 1;
    } else if (newRepetitions == 2) {
      newInterval = 6;
    } else {
      newInterval = (userCard.interval * newEaseFactor).ceil();
    }

    // Apply easy bonus
    if (quality == SpacedRepetitionConstants.qualityEasy) {
      newInterval =
          (newInterval * SpacedRepetitionConstants.easyIntervalMultiplier)
              .ceil();
    }

    final nextReview = now.add(Duration(days: newInterval));

    if (kDebugMode) {
      print('   ✅ Review successful');
      print('   Quality: $quality');
      print('   New ease: ${newEaseFactor.toStringAsFixed(2)}');
      print('   Repetitions: $newRepetitions');
      print('   Next review in: $newInterval day(s)');
    }

    // Update statistics
    final newTimesReviewed = userCard.timesReviewed + 1;
    final newTimesCorrect = userCard.timesCorrect + 1;

    return userCard.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      lastReviewed: now,
      nextReview: nextReview,
      quality: quality,
      timesReviewed: newTimesReviewed,
      timesCorrect: newTimesCorrect,
    );
  }

  /// Convert boolean answer and time to quality rating
  int convertAnswerToQuality({required bool isCorrect, int? timeSpentSeconds}) {
    if (!isCorrect) {
      return SpacedRepetitionConstants.qualityAgain; // 0
    }

    // Determine quality based on response time
    if (timeSpentSeconds != null) {
      if (timeSpentSeconds <= SpacedRepetitionConstants.perfectResponseTime) {
        return SpacedRepetitionConstants.qualityEasy; // 3 - Perfect!
      } else if (timeSpentSeconds <=
          SpacedRepetitionConstants.goodResponseTime) {
        return SpacedRepetitionConstants.qualityGood; // 2 - Good
      } else {
        return SpacedRepetitionConstants.qualityHard; // 1 - Correct but slow
      }
    }

    // Default: correct with normal difficulty
    return SpacedRepetitionConstants.qualityGood; // 2
  }

  /// Get priority score for card (higher = should review sooner)
  double getCardPriority(UserFlashcard userCard) {
    // New cards get high priority
    if (userCard.isNew) {
      return 1000.0;
    }

    // Learning cards get very high priority (should appear in session)
    if (userCard.isLearning) {
      // If due now, maximum priority
      if (userCard.isDue) {
        return 900.0 + (100.0 - userCard.accuracy);
      }
      // If not due yet but in learning, still relatively high
      return 800.0;
    }

    // Review cards that are overdue
    if (userCard.nextReview != null) {
      final now = DateTime.now();
      if (now.isAfter(userCard.nextReview!)) {
        final daysOverdue = now.difference(userCard.nextReview!).inDays;
        return 500.0 + (daysOverdue * 10.0);
      }
    }

    // Cards with low accuracy get priority
    final accuracyFactor = 100.0 - userCard.accuracy;

    // Cards with low ease factor (difficult) get slight priority
    final difficultyFactor = (3.0 - userCard.easeFactor) * 10;

    return accuracyFactor + difficultyFactor;
  }

  /// Sort cards by priority (highest first)
  List<UserFlashcard> sortCardsByPriority(List<UserFlashcard> cards) {
    final cardsCopy = List<UserFlashcard>.from(cards);
    cardsCopy.sort((a, b) {
      final priorityA = getCardPriority(a);
      final priorityB = getCardPriority(b);
      return priorityB.compareTo(priorityA);
    });
    return cardsCopy;
  }

  /// Get recommended number of new cards to introduce per session
  int getRecommendedNewCards({
    required int totalNewCards,
    required int dueCards,
  }) {
    // If there are many due cards, limit new cards
    if (dueCards >= SpacedRepetitionConstants.reviewCardThresholdForNewCards) {
      return 0;
    }
    if (dueCards > 20) return 5;
    if (dueCards > 10) return 10;

    // Otherwise, introduce up to max
    return math.min(
      totalNewCards,
      SpacedRepetitionConstants.maxNewCardsPerSession,
    );
  }

  /// Calculate optimal study session length
  Duration getRecommendedSessionLength({
    required int dueCards,
    required int newCards,
  }) {
    // Estimate ~15 seconds per card (conservative)
    final totalCards = math.min(
      dueCards + newCards,
      SpacedRepetitionConstants.maxCardsPerSession,
    );
    final estimatedSeconds = totalCards * 15;

    return Duration(seconds: estimatedSeconds);
  }
}
