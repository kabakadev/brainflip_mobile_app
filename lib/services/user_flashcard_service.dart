import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_flashcard.dart';
import '../features/study/models/flashcard_model.dart';

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

  /// Get due cards for a deck (cards ready for review)
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

      // Filter cards that are due
      final dueCards = snapshot.docs
          .map((doc) => UserFlashcard.fromMap(doc.data(), doc.id))
          .where((card) => card.isDue)
          .toList();

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
      return allFlashcardIds
          .where((id) => !reviewedCardIds.contains(id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting new cards: $e');
      }
      return allFlashcardIds;
    }
  }

  /// Get study queue for a deck (due cards + new cards)
  Future<StudyQueue> getStudyQueue({
    required String userId,
    required String deckId,
    required List<FlashcardModel> allFlashcards,
    int maxNewCards = 10,
  }) async {
    try {
      // Get due cards
      final dueUserCards = await getDueCards(userId: userId, deckId: deckId);

      // Get new card IDs
      final allFlashcardIds = allFlashcards.map((f) => f.id).toList();
      final newCardIds = await getNewCardIds(
        userId: userId,
        deckId: deckId,
        allFlashcardIds: allFlashcardIds,
      );

      // Limit new cards based on due cards
      final recommendedNewCount = dueUserCards.length > 20
          ? 0
          : (dueUserCards.length > 10 ? 5 : maxNewCards);

      final limitedNewCardIds = newCardIds.take(recommendedNewCount).toList();

      // Combine flashcards
      final dueFlashcards = allFlashcards
          .where((f) => dueUserCards.any((uc) => uc.flashcardId == f.id))
          .toList();

      final newFlashcards = allFlashcards
          .where((f) => limitedNewCardIds.contains(f.id))
          .toList();

      return StudyQueue(
        dueCards: dueFlashcards,
        newCards: newFlashcards,
        dueUserCards: dueUserCards,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting study queue: $e');
      }
      return StudyQueue(dueCards: [], newCards: [], dueUserCards: []);
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
}

/// Helper class for organizing study session cards
class StudyQueue {
  final List<FlashcardModel> dueCards;
  final List<FlashcardModel> newCards;
  final List<UserFlashcard> dueUserCards;

  StudyQueue({
    required this.dueCards,
    required this.newCards,
    required this.dueUserCards,
  });

  int get totalCards => dueCards.length + newCards.length;

  List<FlashcardModel> get allCards => [...dueCards, ...newCards];
}
