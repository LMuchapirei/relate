import 'dart:convert';

class BirthdayLog {
  final String id;
  final String relationshipId;
  final String userId;
  final String date; // ISO8601 string or formatted date
  final String reflection;
  final List<Map<String, dynamic>> attachments;
  final DateTime createdAt;

  BirthdayLog({
    required this.id,
    required this.relationshipId,
    required this.userId,
    required this.date,
    required this.reflection,
    required this.attachments,
    required this.createdAt,
  });

  factory BirthdayLog.fromMap(Map<String, dynamic> map) => BirthdayLog(
    id: map['\$id'] ?? '',
    relationshipId: map['relationshipId'] ?? '',
    userId: map['userId'] ?? '',
    date: map['date'] ?? '',
    reflection: map['reflection'] ?? '',
    attachments: (map['attachments'] as List?)
        ?.map((e) => Map<String, dynamic>.from(jsonDecode(e as String)))
        .toList() ?? [],
    createdAt: DateTime.tryParse(map['createdAt'] ?? map['\$createdAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'relationshipId': relationshipId,
    'userId': userId,
    'date': date,
    'reflection': reflection,
    'attachments': attachments.map((e) => jsonEncode(e)).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}