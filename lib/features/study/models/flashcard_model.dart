class FlashcardModel {
  final String id;
  final String deckId;
  final String imageUrl;
  final String correctAnswer;
  final List<String> alternateAnswers;
  final String? hint;
  final String difficulty; // 'easy', 'medium', 'hard'
  final int order;

  // Spaced repetition fields
  final double easeFactor;
  final int interval; // Days until next review
  final int repetitions;
  final DateTime? lastReviewed;
  final DateTime? nextReview;

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.imageUrl,
    required this.correctAnswer,
    this.alternateAnswers = const [],
    this.hint,
    this.difficulty = 'medium',
    required this.order,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.lastReviewed,
    this.nextReview,
  });

  // Convert from Firestore document
  factory FlashcardModel.fromMap(Map<String, dynamic> map, String id) {
    return FlashcardModel(
      id: id,
      deckId: map['deckId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      alternateAnswers: List<String>.from(map['alternateAnswers'] ?? []),
      hint: map['hint'],
      difficulty: map['difficulty'] ?? 'medium',
      order: map['order'] ?? 0,
      easeFactor: (map['easeFactor'] ?? 2.5).toDouble(),
      interval: map['interval'] ?? 0,
      repetitions: map['repetitions'] ?? 0,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'])
          : null,
      nextReview: map['nextReview'] != null
          ? DateTime.parse(map['nextReview'])
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'imageUrl': imageUrl,
      'correctAnswer': correctAnswer,
      'alternateAnswers': alternateAnswers,
      'hint': hint,
      'difficulty': difficulty,
      'order': order,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReview': nextReview?.toIso8601String(),
    };
  }

  // Copy with method
  FlashcardModel copyWith({
    String? id,
    String? deckId,
    String? imageUrl,
    String? correctAnswer,
    List<String>? alternateAnswers,
    String? hint,
    String? difficulty,
    int? order,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? lastReviewed,
    DateTime? nextReview,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      imageUrl: imageUrl ?? this.imageUrl,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      alternateAnswers: alternateAnswers ?? this.alternateAnswers,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
      order: order ?? this.order,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
    );
  }

  // Check if card is due for review
  bool get isDue {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!);
  }
}
