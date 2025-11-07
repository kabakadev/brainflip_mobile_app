class UserFlashcard {
  final String id;
  final String userId;
  final String flashcardId;
  final String deckId;

  // Spaced repetition fields
  final double easeFactor;
  final int interval; // Days until next review
  final int repetitions;
  final DateTime? lastReviewed;
  final DateTime? nextReview;
  final int quality; // Last quality rating (0-5)

  // Stats
  final int timesReviewed;
  final int timesCorrect;
  final int timesIncorrect;

  UserFlashcard({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.deckId,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.lastReviewed,
    this.nextReview,
    this.quality = 0,
    this.timesReviewed = 0,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
  });

  factory UserFlashcard.fromMap(Map<String, dynamic> map, String id) {
    return UserFlashcard(
      id: id,
      userId: map['userId'] ?? '',
      flashcardId: map['flashcardId'] ?? '',
      deckId: map['deckId'] ?? '',
      easeFactor: (map['easeFactor'] ?? 2.5).toDouble(),
      interval: map['interval'] ?? 0,
      repetitions: map['repetitions'] ?? 0,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'])
          : null,
      nextReview: map['nextReview'] != null
          ? DateTime.parse(map['nextReview'])
          : null,
      quality: map['quality'] ?? 0,
      timesReviewed: map['timesReviewed'] ?? 0,
      timesCorrect: map['timesCorrect'] ?? 0,
      timesIncorrect: map['timesIncorrect'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'flashcardId': flashcardId,
      'deckId': deckId,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReview': nextReview?.toIso8601String(),
      'quality': quality,
      'timesReviewed': timesReviewed,
      'timesCorrect': timesCorrect,
      'timesIncorrect': timesIncorrect,
    };
  }

  UserFlashcard copyWith({
    String? id,
    String? userId,
    String? flashcardId,
    String? deckId,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? lastReviewed,
    DateTime? nextReview,
    int? quality,
    int? timesReviewed,
    int? timesCorrect,
    int? timesIncorrect,
  }) {
    return UserFlashcard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flashcardId: flashcardId ?? this.flashcardId,
      deckId: deckId ?? this.deckId,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      quality: quality ?? this.quality,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
    );
  }

  /// Check if card is due for review
  bool get isDue {
    if (nextReview == null) return true; // New card
    return DateTime.now().isAfter(nextReview!);
  }

  /// Get accuracy percentage
  double get accuracy {
    if (timesReviewed == 0) return 0.0;
    return (timesCorrect / timesReviewed * 100);
  }
}
