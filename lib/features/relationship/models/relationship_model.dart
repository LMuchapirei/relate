import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class Relationship {
  final String? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final double frequency;
  final double rating;
  final String relationshipType;
  final String? createdAt;

  Relationship({
    this.id,
    this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.frequency,
    required this.rating,
    required this.relationshipType,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'frequency': frequency,
      'rating': rating,
      'relationshipType': relationshipType,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Relationship.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
    String? createdAtString;
    if (createdAtTimestamp != null) {
      DateTime createdAtDateTime = createdAtTimestamp.toDate();
      createdAtString = DateFormat('d MMM yyyy').format(createdAtDateTime);
    }
    return Relationship(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      frequency: data['frequency'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      relationshipType: data['relationshipType'] ?? '',
      createdAt: createdAtString ?? ''
    );
  }

  @override
  String toString() {
    return {
       'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'frequency': frequency,
      'rating': rating,
      'relationshipType': relationshipType,
      'createdAt': createdAt
    }.toString();
  }
}
