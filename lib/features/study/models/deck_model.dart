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
  final String? creatorName;
  final int downloads;
  final double rating;
  final int ratingCount;
  final List<String> tags;

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
    this.creatorName,
    this.downloads = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.tags = const [],
  });

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
      creatorName: map['creatorName'],
      downloads: map['downloads'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

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
      'creatorName': creatorName,
      'downloads': downloads,
      'rating': rating,
      'ratingCount': ratingCount,
      'tags': tags,
    };
  }

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
    String? creatorName,
    int? downloads,
    double? rating,
    int? ratingCount,
    List<String>? tags,
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
      creatorName: creatorName ?? this.creatorName,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      tags: tags ?? this.tags,
    );
  }

  bool get isCustom => creatorId != null;
}
