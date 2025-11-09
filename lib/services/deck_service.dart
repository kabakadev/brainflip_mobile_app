import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/study/models/deck_model.dart';
import '../features/study/models/flashcard_model.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== DECK CREATION ====================

  /// Create a custom deck
  Future<String?> createDeck({
    required String userId,
    required String userName,
    required String name,
    required String description,
    required String category,
    bool isPublic = false,
    List<String> tags = const [],
  }) async {
    try {
      final deck = DeckModel(
        id: '',
        name: name,
        description: description,
        category: category,
        thumbnailUrl: 'https://via.placeholder.com/400x300.png?text=$name',
        cardCount: 0,
        createdAt: DateTime.now(),
        isPublic: isPublic,
        creatorId: userId,
        creatorName: userName,
        tags: tags,
      );

      final docRef = await _firestore.collection('decks').add(deck.toMap());

      if (kDebugMode) {
        print('✅ Custom deck created: $name');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating deck: $e');
      }
      return null;
    }
  }

  /// Update deck
  Future<void> updateDeck(String deckId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('decks').doc(deckId).update(updates);

      if (kDebugMode) {
        print('✅ Deck updated: $deckId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating deck: $e');
      }
      rethrow;
    }
  }

  /// Delete deck
  Future<void> deleteDeck(String deckId) async {
    try {
      // Delete all flashcards in the deck
      final flashcards = await _firestore
          .collection('flashcards')
          .where('deckId', isEqualTo: deckId)
          .get();

      final batch = _firestore.batch();
      for (final doc in flashcards.docs) {
        batch.delete(doc.reference);
      }

      // Delete the deck
      batch.delete(_firestore.collection('decks').doc(deckId));

      await batch.commit();

      if (kDebugMode) {
        print('✅ Deck deleted: $deckId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting deck: $e');
      }
      rethrow;
    }
  }

  // ==================== FLASHCARD MANAGEMENT ====================

  /// Add flashcard to deck
  Future<String?> addFlashcard({
    required String deckId,
    required String correctAnswer,
    List<String> alternateAnswers = const [],
    String? hint,
    String difficulty = 'medium',
  }) async {
    try {
      // Get current card count
      final deckDoc = await _firestore.collection('decks').doc(deckId).get();
      final currentCount = deckDoc.data()?['cardCount'] ?? 0;

      final flashcard = FlashcardModel(
        id: '',
        deckId: deckId,
        imageUrl: 'https://via.placeholder.com/400x300.png?text=$correctAnswer',
        correctAnswer: correctAnswer,
        alternateAnswers: alternateAnswers,
        hint: hint,
        difficulty: difficulty,
        order: currentCount,
      );

      final docRef = await _firestore
          .collection('flashcards')
          .add(flashcard.toMap());

      // Update deck card count
      await _firestore.collection('decks').doc(deckId).update({
        'cardCount': FieldValue.increment(1),
      });

      if (kDebugMode) {
        print('✅ Flashcard added to deck');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding flashcard: $e');
      }
      return null;
    }
  }

  /// Update flashcard
  Future<void> updateFlashcard(
    String flashcardId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('flashcards')
          .doc(flashcardId)
          .update(updates);

      if (kDebugMode) {
        print('✅ Flashcard updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating flashcard: $e');
      }
      rethrow;
    }
  }

  /// Delete flashcard
  Future<void> deleteFlashcard(String flashcardId, String deckId) async {
    try {
      await _firestore.collection('flashcards').doc(flashcardId).delete();

      // Update deck card count
      await _firestore.collection('decks').doc(deckId).update({
        'cardCount': FieldValue.increment(-1),
      });

      if (kDebugMode) {
        print('✅ Flashcard deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting flashcard: $e');
      }
      rethrow;
    }
  }

  // ==================== COMMUNITY FEATURES ====================

  /// Get public decks for discovery
  Future<List<DeckModel>> getPublicDecks({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .orderBy('downloads', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching public decks: $e');
      }
      return [];
    }
  }

  /// Search decks
  Future<List<DeckModel>> searchDecks(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple contains search on name
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .where(
            (deck) =>
                deck.name.toLowerCase().contains(query.toLowerCase()) ||
                deck.description.toLowerCase().contains(query.toLowerCase()) ||
                deck.tags.any(
                  (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                ),
          )
          .toList();

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching decks: $e');
      }
      return [];
    }
  }

  /// Get decks by category
  Future<List<DeckModel>> getDecksByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .limit(20)
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

  /// Get user's created decks
  Future<List<DeckModel>> getUserCreatedDecks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user decks: $e');
      }
      return [];
    }
  }

  /// Increment deck downloads
  Future<void> incrementDownloads(String deckId) async {
    try {
      await _firestore.collection('decks').doc(deckId).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error incrementing downloads: $e');
      }
    }
  }

  /// Rate a deck
  Future<void> rateDeck({
    required String deckId,
    required double rating,
  }) async {
    try {
      final deckDoc = await _firestore.collection('decks').doc(deckId).get();
      final data = deckDoc.data();

      if (data != null) {
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final currentCount = data['ratingCount'] ?? 0;

        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + rating) / newCount;

        await _firestore.collection('decks').doc(deckId).update({
          'rating': newRating,
          'ratingCount': newCount,
        });

        if (kDebugMode) {
          print('✅ Deck rated: $newRating ($newCount reviews)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error rating deck: $e');
      }
      rethrow;
    }
  }

  // ==================== SHARING ====================

  /// Generate shareable link for deck
  String generateShareableLink(String deckId) {
    // In production, use Firebase Dynamic Links
    // For now, use a simple deep link format
    return 'https://brainflip.app/deck/$deckId';
  }

  /// Copy deck to user's collection
  Future<void> copyDeckToUser({
    required String userId,
    required String deckId,
  }) async {
    try {
      // Add deck ID to user's selected decks
      await _firestore.collection('users').doc(userId).update({
        'selectedDecks': FieldValue.arrayUnion([deckId]),
      });

      // Increment downloads
      await incrementDownloads(deckId);

      if (kDebugMode) {
        print('✅ Deck copied to user collection');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error copying deck: $e');
      }
      rethrow;
    }
  }
}
