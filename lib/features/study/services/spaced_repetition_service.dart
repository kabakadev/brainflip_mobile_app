import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../models/user_flashcard.dart';
import '../../../core/constants/app_constants.dart';

class SpacedRepetitionService {
  /// Calculate next review schedule based on SM-2 algorithm
  ///
  /// quality: 0-5 rating
  /// - 0-2: Complete blackout, incorrect response, or correct with serious difficulty
  /// - 3: Correct response, but with serious difficulty
  /// - 4: Correct response, after some hesitation
  /// - 5: Perfect response, no hesitation
  UserFlashcard calculateNextReview({
    required UserFlashcard userCard,
    required int quality,
  }) {
    // Clamp quality to valid range
    quality = quality.clamp(0, 5);

    double newEaseFactor = userCard.easeFactor;
    int newInterval = userCard.interval;
    int newRepetitions = userCard.repetitions;

    // Update ease factor (SM-2 formula)
    newEaseFactor =
        userCard.easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ensure ease factor stays within bounds
    if (newEaseFactor < AppConstants.minEaseFactor) {
      newEaseFactor = AppConstants.minEaseFactor.toDouble();
    }

    // Calculate new interval based on quality
    if (quality < 3) {
      // Failed recall - reset
      newRepetitions = 0;
      newInterval = 1;
    } else {
      // Successful recall
      if (userCard.repetitions == 0) {
        newInterval = 1;
      } else if (userCard.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (userCard.interval * newEaseFactor).ceil();
      }
      newRepetitions = userCard.repetitions + 1;
    }

    // Calculate next review date
    final nextReview = DateTime.now().add(Duration(days: newInterval));

    // Update statistics
    final newTimesReviewed = userCard.timesReviewed + 1;
    final newTimesCorrect = quality >= 3
        ? userCard.timesCorrect + 1
        : userCard.timesCorrect;
    final newTimesIncorrect = quality < 3
        ? userCard.timesIncorrect + 1
        : userCard.timesIncorrect;

    if (kDebugMode) {
      print('📅 SM-2 Calculation:');
      print('   Quality: $quality');
      print('   New Ease Factor: ${newEaseFactor.toStringAsFixed(2)}');
      print('   New Interval: $newInterval days');
      print('   Next Review: ${nextReview.toLocal()}');
    }

    return userCard.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      lastReviewed: DateTime.now(),
      nextReview: nextReview,
      quality: quality,
      timesReviewed: newTimesReviewed,
      timesCorrect: newTimesCorrect,
      timesIncorrect: newTimesIncorrect,
    );
  }

  /// Convert boolean answer (correct/incorrect) to quality rating
  /// This is a simplified version - you can make it more sophisticated later
  int convertAnswerToQuality({required bool isCorrect, int? timeSpentSeconds}) {
    if (!isCorrect) {
      return 0; // Failed
    }

    // If correct, determine quality based on time spent (optional)
    if (timeSpentSeconds != null) {
      if (timeSpentSeconds <= 5) {
        return 5; // Perfect, very fast
      } else if (timeSpentSeconds <= 10) {
        return 4; // Good, reasonably fast
      } else {
        return 3; // Correct but slow
      }
    }

    // Default: correct but no time data
    return 4;
  }

  /// Get priority score for card (higher = should review sooner)
  /// Used for sorting cards in review queue
  double getCardPriority(UserFlashcard userCard) {
    // New cards (never reviewed) get high priority
    if (userCard.lastReviewed == null) {
      return 1000.0;
    }

    // Cards that are overdue get higher priority
    if (userCard.nextReview != null) {
      final now = DateTime.now();
      if (now.isAfter(userCard.nextReview!)) {
        final daysOverdue = now.difference(userCard.nextReview!).inDays;
        return 100.0 + daysOverdue.toDouble();
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
    if (dueCards > 20) return 0;
    if (dueCards > 10) return 5;

    // Otherwise, introduce up to 10 new cards
    return math.min(totalNewCards, 10);
  }

  /// Calculate optimal study session length
  Duration getRecommendedSessionLength({
    required int dueCards,
    required int newCards,
  }) {
    // Estimate ~20 seconds per card (conservative)
    final totalCards = dueCards + newCards;
    final estimatedSeconds = totalCards * 20;

    return Duration(seconds: estimatedSeconds);
  }
}
