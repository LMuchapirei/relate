import 'dart:convert';


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
  final String id;
  final String relationshipId;
  final String userId;
  final List<String> notes;
  final String summary;
  final String feeling;
  final double mood;
  final List<AttachmentItem> files;
  final DateTime? createdAt;

  InteractionSummaryItem({
    required this.id,
    required this.relationshipId,
    required this.userId,
    required this.notes,
    required this.summary,
    required this.feeling,
    required this.mood,
    required this.files,
    this.createdAt,
  });

  factory InteractionSummaryItem.fromMap(Map<String, dynamic> map) {
    return InteractionSummaryItem(
      id: map['\$id'] ?? map['id'] ?? '',
      relationshipId: map['relationshipId'] ?? '',
      userId: map['userId'] ?? '',
      notes: (map['notes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      summary: map['summary'] ?? '',
      feeling: map['feeling'] ?? '',
      mood: (map['mood'] is int)
          ? (map['mood'] as int).toDouble()
          : (map['mood'] is double)
              ? map['mood']
              : (map['mood'] is String)
                  ? double.tryParse(map['mood']) ?? 0.0
                  : 0.0,
      files: (map['files'] as List?)
              ?.map((e) => AttachmentItem.fromMap(jsonDecode(e as String)))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : (map['\$createdAt'] != null
              ? DateTime.tryParse(map['\$createdAt'])
              : null),
    );
  }

  Map<String, dynamic> toMap() => {
        'relationshipId': relationshipId,
        'userId': userId,
        'notes': notes,
        'summary': summary,
        'feeling': feeling,
        'mood': mood,
        'files': files.map((e) => e.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };
}