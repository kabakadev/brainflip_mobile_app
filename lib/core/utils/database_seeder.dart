import 'package:flutter/foundation.dart';
import '../../services/firestore_service.dart';
import 'seed_data.dart';

class DatabaseSeeder {
  static final FirestoreService _firestoreService = FirestoreService();

  // Seed starter decks (call this once manually)
  static Future<void> seedStarterDecks() async {
    try {
      if (kDebugMode) {
        print('🌱 Starting database seeding...');
      }

      // Get starter decks
      final decks = SeedData.getStarterDecks();

      // Create decks in Firestore
      for (final deck in decks) {
        await _firestoreService.createDeck(deck);
      }

      // Get all flashcards
      final flashcardsMap = SeedData.getAllFlashcards();

      // Create flashcards for each deck
      for (final entry in flashcardsMap.entries) {
        final flashcards = entry.value;
        await _firestoreService.createFlashcardsInBatch(flashcards);
      }

      if (kDebugMode) {
        print('✅ Database seeding completed!');
        print('   - ${decks.length} decks created');
        print(
          '   - ${flashcardsMap.values.fold(0, (sum, list) => sum + list.length)} flashcards created',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Database seeding failed: $e');
      }
      rethrow;
    }
  }
}
