class DeckModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String thumbnailUrl;
  final int cardCount;
  final DateTime createdAt;
  final bool isPublic;
  final String? creatorId;

  DeckModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.cardCount,
    required this.createdAt,
    this.isPublic = true,
    this.creatorId,
  });

  // Convert from Firestore document
  factory DeckModel.fromMap(Map<String, dynamic> map, String id) {
    return DeckModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      cardCount: map['cardCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      isPublic: map['isPublic'] ?? true,
      creatorId: map['creatorId'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'cardCount': cardCount,
      'createdAt': createdAt.toIso8601String(),
      'isPublic': isPublic,
      'creatorId': creatorId,
    };
  }

  // Copy with method
  DeckModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? thumbnailUrl,
    int? cardCount,
    DateTime? createdAt,
    bool? isPublic,
    String? creatorId,
  }) {
    return DeckModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}
