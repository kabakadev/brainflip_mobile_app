class DailyGoal {
  final String id;
  final String userId;
  final DateTime date;
  final int targetCards;
  final int completedCards;
  final bool isCompleted;

  DailyGoal({
    required this.id,
    required this.userId,
    required this.date,
    this.targetCards = 20,
    this.completedCards = 0,
    this.isCompleted = false,
  });

  factory DailyGoal.fromMap(Map<String, dynamic> map, String id) {
    return DailyGoal(
      id: id,
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      targetCards: map['targetCards'] ?? 20,
      completedCards: map['completedCards'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'targetCards': targetCards,
      'completedCards': completedCards,
      'isCompleted': isCompleted,
    };
  }

  double get progress => targetCards > 0 ? completedCards / targetCards : 0.0;

  DailyGoal copyWith({int? completedCards, bool? isCompleted}) {
    return DailyGoal(
      id: id,
      userId: userId,
      date: date,
      targetCards: targetCards,
      completedCards: completedCards ?? this.completedCards,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
