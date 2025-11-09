import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_flashcard.dart';
import '../features/study/models/flashcard_model.dart';
import '../core/constants/spaced_repetition_constants.dart';

class UserFlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get or create user flashcard record
  Future<UserFlashcard> getUserFlashcard({
    required String userId,
    required String flashcardId,
    required String deckId,
  }) async {
    try {
      final docId = '${userId}_$flashcardId';
      final doc = await _firestore
          .collection('user_flashcards')
          .doc(docId)
          .get();

      if (doc.exists) {
        return UserFlashcard.fromMap(doc.data()!, doc.id);
      } else {
        // Create new user flashcard record
        final newUserCard = UserFlashcard(
          id: docId,
          userId: userId,
          flashcardId: flashcardId,
          deckId: deckId,
          isLearning: true, // Start in learning phase
        );

        await _firestore
            .collection('user_flashcards')
            .doc(docId)
            .set(newUserCard.toMap());

        return newUserCard;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user flashcard: $e');
      }
      rethrow;
    }
  }

  /// Update user flashcard after review
  Future<void> updateUserFlashcard(UserFlashcard userCard) async {
    try {
      await _firestore
          .collection('user_flashcards')
          .doc(userCard.id)
          .set(userCard.toMap());

      if (kDebugMode) {
        print('✅ User flashcard updated: ${userCard.flashcardId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user flashcard: $e');
      }
      rethrow;
    }
  }

  /// Get all user flashcards for a deck
  Future<List<UserFlashcard>> getUserFlashcardsForDeck({
    required String userId,
    required String deckId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('user_flashcards')
          .where('userId', isEqualTo: userId)
          .where('deckId', isEqualTo: deckId)
          .get();

      return snapshot.docs
          .map((doc) => UserFlashcard.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user flashcards for deck: $e');
      }
      return [];
    }
  }

  /// Get due cards for a deck (cards ready for review NOW)
  /// This includes both learning cards and review cards
  Future<List<UserFlashcard>> getDueCards({
    required String userId,
    required String deckId,
  }) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('user_flashcards')
          .where('userId', isEqualTo: userId)
          .where('deckId', isEqualTo: deckId)
          .get();

      // Filter cards that are due (includes learning cards with short intervals)
      final dueCards = snapshot.docs
          .map((doc) => UserFlashcard.fromMap(doc.data(), doc.id))
          .where((card) => card.isDue)
          .toList();

      if (kDebugMode) {
        print('📋 Due Cards Breakdown:');
        final learningDue = dueCards.where((c) => c.isLearning).length;
        final reviewDue = dueCards.where((c) => !c.isLearning).length;
        print('   Learning: $learningDue');
        print('   Review: $reviewDue');
        print('   Total: ${dueCards.length}');
      }

      return dueCards;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching due cards: $e');
      }
      return [];
    }
  }

  /// Get new cards (never reviewed) for a deck
  Future<List<String>> getNewCardIds({
    required String userId,
    required String deckId,
    required List<String> allFlashcardIds,
  }) async {
    try {
      // Get all user flashcard IDs for this deck
      final userCards = await getUserFlashcardsForDeck(
        userId: userId,
        deckId: deckId,
      );

      final reviewedCardIds = userCards.map((uc) => uc.flashcardId).toSet();

      // Return cards that haven't been reviewed
      final newCards = allFlashcardIds
          .where((id) => !reviewedCardIds.contains(id))
          .toList();

      if (kDebugMode) {
        print('🆕 New cards available: ${newCards.length}');
      }

      return newCards;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting new cards: $e');
      }
      return allFlashcardIds;
    }
  }

  /// Get study queue for a deck (due cards + new cards)
  /// This is the main method called when starting a study session
  Future<StudyQueue> getStudyQueue({
    required String userId,
    required String deckId,
    required List<FlashcardModel> allFlashcards,
    int maxNewCards = 10,
  }) async {
    try {
      // Get due cards (both learning and review)
      final dueUserCards = await getDueCards(userId: userId, deckId: deckId);

      // Get new card IDs
      final allFlashcardIds = allFlashcards.map((f) => f.id).toList();
      final newCardIds = await getNewCardIds(
        userId: userId,
        deckId: deckId,
        allFlashcardIds: allFlashcardIds,
      );

      // Calculate how many new cards to introduce
      // Limit based on current due cards
      int recommendedNewCount;
      if (dueUserCards.length >=
          SpacedRepetitionConstants.reviewCardThresholdForNewCards) {
        recommendedNewCount = 0;
      } else if (dueUserCards.length > 20) {
        recommendedNewCount = 5;
      } else {
        recommendedNewCount = maxNewCards;
      }

      final limitedNewCardIds = newCardIds.take(recommendedNewCount).toList();

      // Map to flashcard models
      final dueFlashcards = allFlashcards
          .where((f) => dueUserCards.any((uc) => uc.flashcardId == f.id))
          .toList();

      final newFlashcards = allFlashcards
          .where((f) => limitedNewCardIds.contains(f.id))
          .toList();

      if (kDebugMode) {
        print('📚 Study Queue Summary:');
        print('   Due cards: ${dueFlashcards.length}');
        print('   New cards: ${newFlashcards.length}');
        print('   Total: ${dueFlashcards.length + newFlashcards.length}');
      }

      return StudyQueue(
        dueCards: dueFlashcards,
        newCards: newFlashcards,
        dueUserCards: dueUserCards,
        allCards: allFlashcards,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting study queue: $e');
      }
      return StudyQueue(
        dueCards: [],
        newCards: [],
        dueUserCards: [],
        allCards: allFlashcards,
      );
    }
  }

  /// Batch create user flashcards for new cards
  Future<void> createUserFlashcardsBatch({
    required String userId,
    required String deckId,
    required List<String> flashcardIds,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final flashcardId in flashcardIds) {
        final docId = '${userId}_$flashcardId';
        final userCard = UserFlashcard(
          id: docId,
          userId: userId,
          flashcardId: flashcardId,
          deckId: deckId,
          isLearning: true,
        );

        batch.set(
          _firestore.collection('user_flashcards').doc(docId),
          userCard.toMap(),
        );
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ ${flashcardIds.length} user flashcards created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating user flashcards batch: $e');
      }
      rethrow;
    }
  }

  /// Get deck statistics
  Future<DeckStatistics> getDeckStatistics({
    required String userId,
    required String deckId,
    required List<FlashcardModel> allFlashcards,
  }) async {
    try {
      final userCards = await getUserFlashcardsForDeck(
        userId: userId,
        deckId: deckId,
      );

      final dueCards = await getDueCards(userId: userId, deckId: deckId);
      final newCardIds = await getNewCardIds(
        userId: userId,
        deckId: deckId,
        allFlashcardIds: allFlashcards.map((f) => f.id).toList(),
      );

      // Count cards by status
      final learningCount = userCards.where((c) => c.isLearning).length;
      final reviewCount = userCards.where((c) => !c.isLearning).length;
      final dueCount = dueCards.length;
      final newCount = newCardIds.length;

      if (kDebugMode) {
        print('📊 Deck Statistics:');
        print('   Total cards: ${allFlashcards.length}');
        print('   New: $newCount');
        print('   Learning: $learningCount');
        print('   Review: $reviewCount');
        print('   Due now: $dueCount');
      }

      return DeckStatistics(
        totalCards: allFlashcards.length,
        newCards: newCount,
        learningCards: learningCount,
        reviewCards: reviewCount,
        dueCards: dueCount,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting deck statistics: $e');
      }
      return DeckStatistics(
        totalCards: allFlashcards.length,
        newCards: 0,
        learningCards: 0,
        reviewCards: 0,
        dueCards: 0,
      );
    }
  }
}

/// Helper class for organizing study session cards
class StudyQueue {
  final List<FlashcardModel> dueCards;
  final List<FlashcardModel> newCards;
  final List<UserFlashcard> dueUserCards;
  final List<FlashcardModel> allCards;

  StudyQueue({
    required this.dueCards,
    required this.newCards,
    required this.dueUserCards,
    required this.allCards,
  });

  int get totalCards => dueCards.length + newCards.length;
}

/// Statistics for a deck
class DeckStatistics {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int dueCards;

  DeckStatistics({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.dueCards,
  });
}
