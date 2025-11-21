class Relationship {
  final String? id;
  final String firstName;
  final String lastName;
  final String? nickName;
  final String? phoneNumber;
  final int? rating;
  final String? frequency;
  final String? relationshipType;
  final List<String> tags; // <-- Added
  final String? profileImageUrl;
  final String? userId;
  final bool? bookMarked;
  final DateTime? createdAt;
  final DateTime? bookMarkDate;

  Relationship({
    this.id,
    required this.firstName,
    required this.lastName,
    this.nickName,
    this.phoneNumber,
    this.rating,
    this.frequency,
    this.relationshipType,
    this.tags = const [], // <-- Added
    this.profileImageUrl,
    this.userId,
    this.bookMarked,
    this.bookMarkDate,
    this.createdAt,
  });

  factory Relationship.fromMap(Map<String, dynamic> map) {
    // Handle backward compatibility: if tags is null/empty, use relationshipType
    List<String> parsedTags = [];
    if (map['tags'] != null) {
      parsedTags = List<String>.from(map['tags']);
    } else if (map['relationshipType'] != null) {
      parsedTags = [map['relationshipType']];
    }

    return Relationship(
      id: map['\$id'] ?? map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      nickName: map['nickName'],
      phoneNumber: map['phoneNumber'],
      rating: map['rating'] is int
          ? map['rating']
          : (map['rating'] is String ? int.tryParse(map['rating']) : null),
      frequency: map['frequency'],
      relationshipType: map['relationshipType'],
      tags: parsedTags, // <-- Added
      profileImageUrl: map['profileImageUrl'],
      bookMarkDate: map['bookMarkDate'] != null
          ? DateTime.tryParse(map['bookMarkDate'])
          : null,
      userId: map['userId'],
      bookMarked: map['bookMarked'] ?? false,
      createdAt: map['\$createdAt'] != null
          ? DateTime.tryParse(map['\$createdAt'])
          : (map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'nickName': nickName,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'frequency': frequency,
      'relationshipType': relationshipType,
      'tags': tags, // <-- Added
      'profileImageUrl': profileImageUrl,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'nickName': nickName,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'frequency': frequency,
      'relationshipType': relationshipType,
      'tags': tags,
      'profileImageUrl': profileImageUrl,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
    }.toString();
  }
}
