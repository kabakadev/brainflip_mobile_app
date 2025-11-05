import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/study/models/deck_model.dart';
import '../features/study/models/flashcard_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== DECK OPERATIONS ====================

  // Get all public decks
  Future<List<DeckModel>> getAllDecks() async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching decks: $e');
      }
      return [];
    }
  }

  // Get deck by ID
  Future<DeckModel?> getDeckById(String deckId) async {
    try {
      final doc = await _firestore.collection('decks').doc(deckId).get();

      if (doc.exists) {
        return DeckModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching deck: $e');
      }
      return null;
    }
  }

  // Get decks by category
  Future<List<DeckModel>> getDecksByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('category', isEqualTo: category)
          .where('isPublic', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching decks by category: $e');
      }
      return [];
    }
  }

  // Create deck (for admin/seeding)
  Future<String?> createDeck(DeckModel deck) async {
    try {
      final docRef = await _firestore.collection('decks').add(deck.toMap());

      if (kDebugMode) {
        print('✅ Deck created: ${deck.name}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating deck: $e');
      }
      return null;
    }
  }

  // ==================== FLASHCARD OPERATIONS ====================

  // Get all flashcards for a deck
  Future<List<FlashcardModel>> getFlashcardsByDeck(String deckId) async {
    try {
      final snapshot = await _firestore
          .collection('flashcards')
          .where('deckId', isEqualTo: deckId)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => FlashcardModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching flashcards: $e');
      }
      return [];
    }
  }

  // Create flashcard (for admin/seeding)
  Future<String?> createFlashcard(FlashcardModel flashcard) async {
    try {
      final docRef = await _firestore
          .collection('flashcards')
          .add(flashcard.toMap());

      if (kDebugMode) {
        print('✅ Flashcard created: ${flashcard.correctAnswer}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating flashcard: $e');
      }
      return null;
    }
  }

  // Update flashcard (for spaced repetition)
  Future<void> updateFlashcard(FlashcardModel flashcard) async {
    try {
      await _firestore
          .collection('flashcards')
          .doc(flashcard.id)
          .update(flashcard.toMap());

      if (kDebugMode) {
        print('✅ Flashcard updated: ${flashcard.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating flashcard: $e');
      }
    }
  }

  // ==================== USER DECK OPERATIONS ====================

  // Update user's selected decks
  Future<void> updateUserDecks(String userId, List<String> deckIds) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'selectedDecks': deckIds,
      });

      if (kDebugMode) {
        print('✅ User decks updated: ${deckIds.length} decks');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user decks: $e');
      }
      rethrow;
    }
  }

  // Get user's selected decks
  Future<List<String>> getUserSelectedDecks(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        return List<String>.from(data?['selectedDecks'] ?? []);
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user decks: $e');
      }
      return [];
    }
  }

  // ==================== BATCH OPERATIONS ====================

  // Create multiple decks at once (for seeding)
  Future<void> createDecksInBatch(List<DeckModel> decks) async {
    try {
      final batch = _firestore.batch();

      for (final deck in decks) {
        final docRef = _firestore.collection('decks').doc();
        batch.set(docRef, deck.toMap());
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ ${decks.length} decks created in batch');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating decks in batch: $e');
      }
      rethrow;
    }
  }

  // Create multiple flashcards at once (for seeding)
  Future<void> createFlashcardsInBatch(List<FlashcardModel> flashcards) async {
    try {
      final batch = _firestore.batch();

      for (final flashcard in flashcards) {
        final docRef = _firestore.collection('flashcards').doc();
        batch.set(docRef, flashcard.toMap());
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ ${flashcards.length} flashcards created in batch');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating flashcards in batch: $e');
      }
      rethrow;
    }
  }
}
