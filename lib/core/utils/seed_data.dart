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
        cardCount: 5, // Updated card count
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
        cardCount: 5, // Updated card count
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
        cardCount: 5, // Updated card count
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
        cardCount: 5, // Updated card count
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
        cardCount: 3, // Updated card count
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
        cardCount: 3, // Updated card count
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
        cardCount: 3, // Updated card count
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
        imageUrl: 'assets/images/flashcards/skeleton_bones/femur.jpg',
        correctAnswer: 'femur',
        alternateAnswers: ['thigh bone', 'femoral bone'],
        hint: 'Longest bone in the human body',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: 'assets/images/flashcards/skeleton_bones/skull.jpg',
        correctAnswer: 'skull',
        alternateAnswers: ['cranium'],
        hint: 'Protects the brain',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: 'assets/images/flashcards/skeleton_bones/humerus.jpg',
        correctAnswer: 'humerus',
        alternateAnswers: ['upper arm bone'],
        hint: 'Bone in the upper arm',
        difficulty: 'medium',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: 'assets/images/flashcards/skeleton_bones/tibia.jpg',
        correctAnswer: 'tibia',
        alternateAnswers: ['shin bone'],
        hint: 'Larger bone in the lower leg',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'skeleton_bones',
        imageUrl: 'assets/images/flashcards/skeleton_bones/radius.jpg',
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
        imageUrl: 'assets/images/flashcards/periodic_table/hydrogen.jpg',
        correctAnswer: 'hydrogen',
        alternateAnswers: ['h'],
        hint: 'Atomic number 1',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: 'assets/images/flashcards/periodic_table/helium.jpg',
        correctAnswer: 'helium',
        alternateAnswers: ['he'],
        hint: 'Noble gas, atomic number 2',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNd8SHg0M40eNzgs4VlrpPLjg6AWlA7pHLag&s',
        correctAnswer: 'oxygen',
        alternateAnswers: ['o'],
        hint: 'Essential for breathing',
        difficulty: 'easy',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: 'assets/images/flashcards/periodic_table/gold.jpg',
        correctAnswer: 'gold',
        alternateAnswers: ['au'],
        hint: 'Precious metal with symbol Au',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'periodic_table',
        imageUrl: 'assets/images/flashcards/periodic_table/iron.jpg',
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
        imageUrl: 'assets/images/flashcards/circuit_symbols/resistor.jpg',
        correctAnswer: 'resistor',
        alternateAnswers: ['resistance'],
        hint: 'Opposes current flow',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: 'assets/images/flashcards/circuit_symbols/capacitor.jpg',
        correctAnswer: 'capacitor',
        alternateAnswers: ['condenser'],
        hint: 'Stores electrical charge',
        difficulty: 'medium',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: 'assets/images/flashcards/circuit_symbols/battery.jpg',
        correctAnswer: 'battery',
        alternateAnswers: ['cell', 'power source'],
        hint: 'Provides voltage',
        difficulty: 'easy',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: 'assets/images/flashcards/circuit_symbols/led.jpg',
        correctAnswer: 'led',
        alternateAnswers: ['light emitting diode', 'diode'],
        hint: 'Emits light when current flows',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'circuit_symbols',
        imageUrl: 'assets/images/flashcards/circuit_symbols/switch.jpg',
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
        imageUrl: 'assets/images/flashcards/computer_hardware/cpu.jpg',
        correctAnswer: 'cpu',
        alternateAnswers: ['processor', 'central processing unit'],
        hint: 'Brain of the computer',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: 'assets/images/flashcards/computer_hardware/ram.jpg',
        correctAnswer: 'ram',
        alternateAnswers: ['memory', 'random access memory'],
        hint: 'Temporary storage for running programs',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: 'assets/images/flashcards/computer_hardware/gpu.jpg',
        correctAnswer: 'gpu',
        alternateAnswers: ['graphics card', 'video card'],
        hint: 'Handles graphics processing',
        difficulty: 'medium',
        order: 3,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: 'assets/images/flashcards/computer_hardware/ssd.jpg',
        correctAnswer: 'ssd',
        alternateAnswers: ['solid state drive', 'storage'],
        hint: 'Fast storage with no moving parts',
        difficulty: 'medium',
        order: 4,
      ),
      FlashcardModel(
        id: '',
        deckId: 'computer_hardware',
        imageUrl: 'assets/images/flashcards/computer_hardware/motherboard.jpg',
        correctAnswer: 'motherboard',
        alternateAnswers: ['mainboard', 'mobo'],
        hint: 'Connects all computer components',
        difficulty: 'easy',
        order: 5,
      ),
    ];
  }

  //
  // ===== NEWLY ADDED FLASHCARD LISTS =====
  //
  static List<FlashcardModel> getCellOrganellesFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'cell_organelles',
        imageUrl: 'assets/images/flashcards/cell_organelles/nucleus.jpg',
        correctAnswer: 'nucleus',
        hint: 'Contains the cell\'s genetic material',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'cell_organelles',
        imageUrl: 'assets/images/flashcards/cell_organelles/mitochondria.jpg',
        correctAnswer: 'mitochondria',
        alternateAnswers: ['powerhouse of the cell'],
        hint: 'Generates most of the cell\'s ATP',
        difficulty: 'easy',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'cell_organelles',
        imageUrl: 'assets/images/flashcards/cell_organelles/ribosome.jpg',
        correctAnswer: 'ribosome',
        hint: 'Synthesizes proteins',
        difficulty: 'medium',
        order: 3,
      ),
    ];
  }

  static List<FlashcardModel> getPhysicsFormulasFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'physics_formulas',
        imageUrl: 'assets/images/flashcards/physics_formulas/f_equals_ma',
        correctAnswer: 'f=ma',
        alternateAnswers: [
          'force = mass * acceleration',
          'newton\'s second law',
        ],
        hint: 'Newton\'s Second Law',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'physics_formulas',
        imageUrl:
            'https://study.com/cimages/multimages/16/energy-and-mass-relationship.jpg',
        correctAnswer: 'e=mc^2',
        alternateAnswers: ['energy = mass * speed of light squared'],
        hint: 'Mass–energy equivalence',
        difficulty: 'medium',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'physics_formulas',
        imageUrl:
            'https://www.electronics-tutorials.ws/wp-content/uploads/2018/05/dccircuits-dcp3.gif',
        correctAnswer: 'v=ir',
        alternateAnswers: ['voltage = current * resistance', 'ohm\'s law'],
        hint: 'Ohm\'s Law',
        difficulty: 'easy',
        order: 3,
      ),
    ];
  }

  static List<FlashcardModel> getNetworkProtocolsFlashcards() {
    return [
      FlashcardModel(
        id: '',
        deckId: 'network_protocols',
        imageUrl:
            'https://kinsta.com/wp-content/uploads/2022/06/what-is-an-http-request.jpg',
        correctAnswer: 'http',
        alternateAnswers: ['hypertext transfer protocol'],
        hint: 'The foundation of data communication for the World Wide Web',
        difficulty: 'easy',
        order: 1,
      ),
      FlashcardModel(
        id: '',
        deckId: 'network_protocols',
        imageUrl:
            'https://www.avast.com/hs-fs/hubfs/New_Avast_Academy/%20What%20Is%20TCP_IP/What_is_TCP-IP.png?width=660&name=What_is_TCP-IP.png',
        correctAnswer: 'tcp',
        alternateAnswers: ['transmission control protocol'],
        hint: 'Provides reliable, ordered, and error-checked delivery',
        difficulty: 'medium',
        order: 2,
      ),
      FlashcardModel(
        id: '',
        deckId: 'network_protocols',
        imageUrl: 'assets/images/flashcards/network_protocols/ip',
        correctAnswer: 'ip',
        alternateAnswers: ['internet protocol'],
        hint: 'Principal communications protocol for relaying datagrams',
        difficulty: 'easy',
        order: 3,
      ),
    ];
  }

  // Get all sample flashcards
  //
  // ===== UPDATED MAP TO INCLUDE ALL 7 DECKS =====
  //
  static Map<String, List<FlashcardModel>> getAllFlashcards() {
    return {
      'skeleton_bones': getSkeletonFlashcards(),
      'periodic_table': getPeriodicTableFlashcards(),
      'circuit_symbols': getCircuitSymbolsFlashcards(),
      'computer_hardware': getComputerHardwareFlashcards(),
      'cell_organelles': getCellOrganellesFlashcards(),
      'physics_formulas': getPhysicsFormulasFlashcards(),
      'network_protocols': getNetworkProtocolsFlashcards(),
    };
  }
}
