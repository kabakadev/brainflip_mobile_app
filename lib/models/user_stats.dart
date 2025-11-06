class UserStats {
  final int totalCardsStudied;
  final int cardsStudiedToday;
  final int currentStreak;
  final int longestStreak;
  final double overallAccuracy;
  final DateTime? lastStudyDate;
  final int totalSessions;
  final Duration totalStudyTime;

  UserStats({
    this.totalCardsStudied = 0,
    this.cardsStudiedToday = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.overallAccuracy = 0.0,
    this.lastStudyDate,
    this.totalSessions = 0,
    this.totalStudyTime = Duration.zero,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalCardsStudied: map['totalCardsStudied'] ?? 0,
      cardsStudiedToday: map['cardsStudiedToday'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      overallAccuracy: (map['overallAccuracy'] ?? 0.0).toDouble(),
      lastStudyDate: map['lastStudyDate'] != null
          ? DateTime.parse(map['lastStudyDate'])
          : null,
      totalSessions: map['totalSessions'] ?? 0,
      totalStudyTime: Duration(seconds: map['totalStudyTimeSeconds'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalCardsStudied': totalCardsStudied,
      'cardsStudiedToday': cardsStudiedToday,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'overallAccuracy': overallAccuracy,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'totalSessions': totalSessions,
      'totalStudyTimeSeconds': totalStudyTime.inSeconds,
    };
  }

  UserStats copyWith({
    int? totalCardsStudied,
    int? cardsStudiedToday,
    int? currentStreak,
    int? longestStreak,
    double? overallAccuracy,
    DateTime? lastStudyDate,
    int? totalSessions,
    Duration? totalStudyTime,
  }) {
    return UserStats(
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      cardsStudiedToday: cardsStudiedToday ?? this.cardsStudiedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalSessions: totalSessions ?? this.totalSessions,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
    );
  }
}
