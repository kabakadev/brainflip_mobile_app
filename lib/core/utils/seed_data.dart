import '../../features/study/models/deck_model.dart';
import '../../features/study/models/flashcard_model.dart';

class SeedData {
  // Placeholder image URL (you can replace with real images later)
  static const String placeholderImage =
      'https://via.placeholder.com/400x300.png?text=';

  // ==================== DECKS ====================

  static List<DeckModel> getStarterDecks() {
    return [
      // 1. Human Skeleton (Biology)
      DeckModel(
        id: 'skeleton_bones',
        name: 'Human Skeleton',
        description: 'Learn the major bones of the human body',
        category: 'biology',
        thumbnailUrl: '${placeholderImage}Skeleton',
        cardCount: 20,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 2. Periodic Table (Chemistry)
      DeckModel(
        id: 'periodic_table',
        name: 'Periodic Table',
        description: 'Master chemical elements and their symbols',
        category: 'chemistry',
        thumbnailUrl: '${placeholderImage}Periodic',
        cardCount: 30,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 3. Circuit Symbols (Physics)
      DeckModel(
        id: 'circuit_symbols',
        name: 'Circuit Symbols',
        description: 'Identify common electrical circuit symbols',
        category: 'physics',
        thumbnailUrl: '${placeholderImage}Circuit',
        cardCount: 25,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 4. Computer Hardware (Computers)
      DeckModel(
        id: 'computer_hardware',
        name: 'Computer Hardware',
        description: 'Recognize computer components and parts',
        category: 'computers',
        thumbnailUrl: '${placeholderImage}Hardware',
        cardCount: 22,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 5. Cell Organelles (Biology)
      DeckModel(
        id: 'cell_organelles',
        name: 'Cell Organelles',
        description: 'Explore the parts of plant and animal cells',
        category: 'biology',
        thumbnailUrl: '${placeholderImage}Cell',
        cardCount: 15,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 6. Physics Formulas (Physics)
      DeckModel(
        id: 'physics_formulas',
        name: 'Physics Formulas',
        description: 'Memorize essential physics equations',
        category: 'physics',
        thumbnailUrl: '${placeholderImage}Physics',
        cardCount: 28,
        createdAt: DateTime.now(),
        isPublic: true,
      ),

      // 7. Network Protocols (Computers)
      DeckModel(
        id: 'network_protocols',
        name: 'Network Protocols',
        description: 'Learn common networking protocols and ports',
        category: 'computers',
        thumbnailUrl: '${placeholderImage}Network',
        cardCount: 18,
        createdAt: DateTime.now(),
        isPublic: true,
      ),
    ];
  }

  // ==================== FLASHCARDS ====================

  // Sample flashcards for Human Skeleton deck
  static List<FlashcardModel> getSkeletonFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: '${placeholderImage}Femur',
        correctAnswer: 'femur',
        alternateAnswers: ['thigh bone', 'femoral bone'],
        hint: 'Longest bone in the human body',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: '${placeholderImage}Skull',
        correctAnswer: 'skull',
        alternateAnswers: ['cranium'],
        hint: 'Protects the brain',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: '${placeholderImage}Humerus',
        correctAnswer: 'humerus',
        alternateAnswers: ['upper arm bone'],
        hint: 'Bone in the upper arm',
        difficulty: 'medium',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: '${placeholderImage}Tibia',
        correctAnswer: 'tibia',
        alternateAnswers: ['shin bone'],
        hint: 'Larger bone in the lower leg',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: '${placeholderImage}Radius',
        correctAnswer: 'radius',
        alternateAnswers: ['forearm bone'],
        hint: 'Lateral bone of the forearm',
        difficulty: 'hard',
        order: 5,
      ),
    ];
  }

  // Sample flashcards for Periodic Table deck
  static List<FlashcardModel> getPeriodicTableFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: '${placeholderImage}H',
        correctAnswer: 'hydrogen',
        alternateAnswers: ['h'],
        hint: 'Atomic number 1',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: '${placeholderImage}He',
        correctAnswer: 'helium',
        alternateAnswers: ['he'],
        hint: 'Noble gas, atomic number 2',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: '${placeholderImage}O',
        correctAnswer: 'oxygen',
        alternateAnswers: ['o'],
        hint: 'Essential for breathing',
        difficulty: 'easy',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: '${placeholderImage}Au',
        correctAnswer: 'gold',
        alternateAnswers: ['au'],
        hint: 'Precious metal with symbol Au',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: '${placeholderImage}Fe',
        correctAnswer: 'iron',
        alternateAnswers: ['fe'],
        hint: 'Symbol Fe, used in steel',
        difficulty: 'medium',
        order: 5,
      ),
    ];
  }

  // Sample flashcards for Circuit Symbols deck
  static List<FlashcardModel> getCircuitSymbolsFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: '${placeholderImage}Resistor',
        correctAnswer: 'resistor',
        alternateAnswers: ['resistance'],
        hint: 'Opposes current flow',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: '${placeholderImage}Capacitor',
        correctAnswer: 'capacitor',
        alternateAnswers: ['condenser'],
        hint: 'Stores electrical charge',
        difficulty: 'medium',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: '${placeholderImage}Battery',
        correctAnswer: 'battery',
        alternateAnswers: ['cell', 'power source'],
        hint: 'Provides voltage',
        difficulty: 'easy',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: '${placeholderImage}LED',
        correctAnswer: 'led',
        alternateAnswers: ['light emitting diode', 'diode'],
        hint: 'Emits light when current flows',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: '${placeholderImage}Switch',
        correctAnswer: 'switch',
        alternateAnswers: ['circuit breaker'],
        hint: 'Opens or closes a circuit',
        difficulty: 'easy',
        order: 5,
      ),
    ];
  }

  // Sample flashcards for Computer Hardware deck
  static List<FlashcardModel> getComputerHardwareFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: '${placeholderImage}CPU',
        correctAnswer: 'cpu',
        alternateAnswers: ['processor', 'central processing unit'],
        hint: 'Brain of the computer',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: '${placeholderImage}RAM',
        correctAnswer: 'ram',
        alternateAnswers: ['memory', 'random access memory'],
        hint: 'Temporary storage for running programs',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: '${placeholderImage}GPU',
        correctAnswer: 'gpu',
        alternateAnswers: ['graphics card', 'video card'],
        hint: 'Handles graphics processing',
        difficulty: 'medium',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: '${placeholderImage}SSD',
        correctAnswer: 'ssd',
        alternateAnswers: ['solid state drive', 'storage'],
        hint: 'Fast storage with no moving parts',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: '${placeholderImage}Motherboard',
        correctAnswer: 'motherboard',
        alternateAnswers: ['mainboard', 'mobo'],
        hint: 'Connects all computer components',
        difficulty: 'easy',
        order: 5,
      ),
    ];
  }

  // Get all sample flashcards
  static Map<String, List<FlashcardModel>> getAllFlashcards() {
    return {
      'skeleton_bones': getSkeletonFlashcards(),
      'periodic_table': getPeriodicTableFlashcards(),
      'circuit_symbols': getCircuitSymbolsFlashcards(),
      'computer_hardware': getComputerHardwareFlashcards(),
    };
  }
}
