import 'package:flutter/foundation.dart';
import '../../services/firestore_service.dart';
import '../../features/study/models/flashcard_model.dart';
import 'seed_data.dart'; // Make sure this import is correct

class DatabaseSeeder {
  static final FirestoreService _firestoreService = FirestoreService();

  // Seed starter decks (call this once manually)
  static Future<void> seedStarterDecks() async {
    try {
      if (kDebugMode) {
        print('🌱 Starting database seeding...');
      }

      // Get starter decks and flashcards from seed data
      final decks = SeedData.getStarterDecks(); // List<DeckModel>
      final flashcardsMap =
          SeedData.getAllFlashcards(); // Map<String, List<FlashcardModel>>

      int totalDecks = 0;
      int totalFlashcards = 0;

      // Loop through each deck
      for (final deck in decks) {
        // 1. CREATE THE DECK AND GET ITS NEW FIRESTORE ID
        final newDeckId = await _firestoreService.createDeck(deck);

        if (kDebugMode) {
          print('✅ Deck created: ${deck.name} (ID: $newDeckId)');
        }
        totalDecks++;

        // 2. FIND THE FLASHCARDS FOR THIS DECK
        //
        // ===== THIS IS THE FIX =====
        // We now look up flashcards by the hardcoded deck.id
        //
        final flashcards = flashcardsMap[deck.id];

        if (flashcards != null && flashcards.isNotEmpty) {
          // 3. UPDATE ALL FLASHCARDS WITH THE NEW, CORRECT DECK ID
          final List<FlashcardModel> updatedFlashcards = [];
          for (var card in flashcards) {
            // Use copyWith to create a new card with the correct deckId
            updatedFlashcards.add(card.copyWith(deckId: newDeckId));
          }

          // 4. CREATE THE BATCH OF FLASHCARDS
          await _firestoreService.createFlashcardsInBatch(updatedFlashcards);
          if (kDebugMode) {
            print(
              '   ✅ ${updatedFlashcards.length} flashcards created for ${deck.name}',
            );
          }
          totalFlashcards += updatedFlashcards.length;
        } else {
          if (kDebugMode) {
            print(
              '   ⚠️ No flashcards found for deck: ${deck.name} (Key: ${deck.id})',
            );
          }
        }
      }

      if (kDebugMode) {
        print('✅ Database seeding completed!');
        print('   - $totalDecks decks created');
        print('   - $totalFlashcards flashcards created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Database seeding failed: $e');
      }
      rethrow;
    }
  }
}
