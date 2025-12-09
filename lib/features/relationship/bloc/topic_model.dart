class Topic {
  final String id;
  final String relationshipId;
  final String userId; // <-- Added
  final String title;
  final String description;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.relationshipId,
    required this.userId, // <-- Added
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Topic.fromMap(Map<String, dynamic> map) => Topic(
    id: map['\$id'] ?? '',
    relationshipId: map['relationshipId'] ?? '',
    userId: map['userId'] ?? '', // <-- Added
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? map['\$createdAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'relationshipId': relationshipId,
    'userId': userId, // <-- Added
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}