import 'package:cloud_firestore/cloud_firestore.dart';

class InteractionSummaryItem {
  final String relationshipId;
  final String userId;
  final List<String> notes;
  final String summary;
  final String feeling;
  final int mood;
  final List<String> files;
  final DateTime? timestamp;

  InteractionSummaryItem({
    required this.relationshipId,
    required this.userId,
    required this.notes,
    required this.summary,
    required this.feeling,
    required this.mood,
    required this.files,
    this.timestamp,
  });

  factory InteractionSummaryItem.fromMap(Map<String, dynamic> map) {
    return InteractionSummaryItem(
      relationshipId: map['relationship_id'] ?? '',
      userId: map['user_id'] ?? '',
      notes: List<String>.from(map['notes'] ?? []),
      summary: map['summary'] ?? '',
      feeling: map['feeling'] ?? '',
      mood: map['mood'] is int ? map['mood'] : (map['mood'] as num?)?.toInt() ?? 0,
      files: List<String>.from(map['files'] ?? []),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'relationship_id': relationshipId,
      'user_id': userId,
      'notes': notes,
      'summary': summary,
      'feeling': feeling,
      'mood': mood,
      'files': files,
      'timestamp': timestamp,
    };
  }
}