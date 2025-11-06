class StudyProgress {
  final String id;
  final String userId;
  final String deckId;
  final int cardsStudied;
  final int correctAnswers;
  final int incorrectAnswers;
  final DateTime sessionDate;
  final Duration duration;
  final double accuracy;

  StudyProgress({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.cardsStudied,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.sessionDate,
    required this.duration,
    required this.accuracy,
  });

  factory StudyProgress.fromMap(Map<String, dynamic> map, String id) {
    return StudyProgress(
      id: id,
      userId: map['userId'] ?? '',
      deckId: map['deckId'] ?? '',
      cardsStudied: map['cardsStudied'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      incorrectAnswers: map['incorrectAnswers'] ?? 0,
      sessionDate: DateTime.parse(map['sessionDate']),
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deckId': deckId,
      'cardsStudied': cardsStudied,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'sessionDate': sessionDate.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'accuracy': accuracy,
    };
  }
}
