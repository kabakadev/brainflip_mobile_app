enum BadgeType {
  firstStudy,
  streak7,
  streak30,
  cards100,
  cards500,
  cards1000,
  accuracy90,
  speedDemon,
  perfectWeek,
  earlyBird,
  nightOwl,
  decksCompleted5,
}

class Badge {
  final BadgeType type;
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requirement;
  final DateTime? unlockedAt;

  Badge({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${map['type']}',
      ),
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      requirement: map['requirement'] ?? 0,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'requirement': requirement,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Badge copyWith({DateTime? unlockedAt}) {
    return Badge(
      type: type,
      id: id,
      name: name,
      description: description,
      icon: icon,
      requirement: requirement,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  // Predefined badges
  static List<Badge> getAllBadges() {
    return [
      Badge(
        type: BadgeType.firstStudy,
        id: 'first_study',
        name: 'First Steps',
        description: 'Complete your first study session',
        icon: '🎯',
        requirement: 1,
      ),
      Badge(
        type: BadgeType.streak7,
        id: 'streak_7',
        name: 'Week Warrior',
        description: 'Study for 7 days in a row',
        icon: '🔥',
        requirement: 7,
      ),
      Badge(
        type: BadgeType.streak30,
        id: 'streak_30',
        name: 'Month Master',
        description: 'Study for 30 days in a row',
        icon: '💪',
        requirement: 30,
      ),
      Badge(
        type: BadgeType.cards100,
        id: 'cards_100',
        name: 'Century Club',
        description: 'Study 100 cards',
        icon: '💯',
        requirement: 100,
      ),
      Badge(
        type: BadgeType.cards500,
        id: 'cards_500',
        name: 'Knowledge Seeker',
        description: 'Study 500 cards',
        icon: '📚',
        requirement: 500,
      ),
      Badge(
        type: BadgeType.cards1000,
        id: 'cards_1000',
        name: 'Brain Champion',
        description: 'Study 1000 cards',
        icon: '🧠',
        requirement: 1000,
      ),
      Badge(
        type: BadgeType.accuracy90,
        id: 'accuracy_90',
        name: 'Perfectionist',
        description: 'Achieve 90% accuracy',
        icon: '⭐',
        requirement: 90,
      ),
      Badge(
        type: BadgeType.speedDemon,
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Average under 5 seconds per card',
        icon: '⚡',
        requirement: 5,
      ),
      Badge(
        type: BadgeType.perfectWeek,
        id: 'perfect_week',
        name: 'Perfect Week',
        description: '100% accuracy for 7 days',
        icon: '🏆',
        requirement: 7,
      ),
      Badge(
        type: BadgeType.earlyBird,
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Study before 8 AM',
        icon: '🌅',
        requirement: 1,
      ),
      Badge(
        type: BadgeType.nightOwl,
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Study after 10 PM',
        icon: '🦉',
        requirement: 1,
      ),
      Badge(
        type: BadgeType.decksCompleted5,
        id: 'decks_completed_5',
        name: 'Deck Collector',
        description: 'Complete 5 different decks',
        icon: '🎴',
        requirement: 5,
      ),
    ];
  }
}
