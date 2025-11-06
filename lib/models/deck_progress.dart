class DeckProgress {
  final String deckId;
  final int totalCards;
  final int cardsStudied;
  final int masteredCards;
  final double progressPercentage;
  final DateTime? lastStudied;

  DeckProgress({
    required this.deckId,
    required this.totalCards,
    this.cardsStudied = 0,
    this.masteredCards = 0,
    this.progressPercentage = 0.0,
    this.lastStudied,
  });

  factory DeckProgress.fromMap(Map<String, dynamic> map, String deckId) {
    return DeckProgress(
      deckId: deckId,
      totalCards: map['totalCards'] ?? 0,
      cardsStudied: map['cardsStudied'] ?? 0,
      masteredCards: map['masteredCards'] ?? 0,
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
      lastStudied: map['lastStudied'] != null
          ? DateTime.parse(map['lastStudied'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalCards': totalCards,
      'cardsStudied': cardsStudied,
      'masteredCards': masteredCards,
      'progressPercentage': progressPercentage,
      'lastStudied': lastStudied?.toIso8601String(),
    };
  }
}
