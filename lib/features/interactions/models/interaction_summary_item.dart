import 'package:cloud_firestore/cloud_firestore.dart';


class AttachmentItem {
  final String url;
  final String name;
  final String mime;

  AttachmentItem({
    required this.url,
    required this.name,
    required this.mime,
  });

  factory AttachmentItem.fromMap(Map<String, dynamic> map) =>
      AttachmentItem(
        url: map['url'] ?? '',
        name: map['name'] ?? '',
        mime: map['mime'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'url': url,
        'name': name,
        'mime': mime,
      };
}


class InteractionSummaryItem {
  final String id; // Firestore document ID
  final String relationshipId;
  final String userId;
  final List<String> notes;
  final String summary;
  final String feeling;
  final int mood;
  final List<AttachmentItem> files;
  final DateTime? timestamp;

  InteractionSummaryItem({
    required this.id,
    required this.relationshipId,
    required this.userId,
    required this.notes,
    required this.summary,
    required this.feeling,
    required this.mood,
    required this.files,
    this.timestamp,
  });

  factory InteractionSummaryItem.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return InteractionSummaryItem(
      id: doc.id,
      relationshipId: map['relationship_id'] ?? '',
      userId: map['user_id'] ?? '',
      notes: List<String>.from(map['notes'] ?? []),
      summary: map['summary'] ?? '',
      feeling: map['feeling'] ?? '',
      mood: map['mood'] is int ? map['mood'] : (map['mood'] as num?)?.toInt() ?? 0,
      files: (map['files'] as List<dynamic>? ?? [])
          .map((e) => AttachmentItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
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