import 'package:image_picker/image_picker.dart';

import '../models/relationship_model.dart';

class RelationshipFormStates {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String frequency;
  final double rating;
  final String relationshipType;
  final List<String> tags; // <-- Added
  final String nickName;
  final XFile? profilePicture;

  const RelationshipFormStates(
      {this.firstName = "",
      this.lastName = "",
      this.frequency = "Weekly",
      this.phoneNumber = "",
      this.rating = 3.0,
      this.nickName = "",
      this.relationshipType = "",
      this.tags = const [], // <-- Added
      this.profilePicture});

  RelationshipFormStates copyWith(
      {String? firstName,
      String? lastName,
      String? phoneNumber,
      String? frequency,
      double? rating,
      String? nickName,
      String? relationshipType,
      List<String>? tags, // <-- Added
      XFile? profilePicture}) {
    return RelationshipFormStates(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      frequency: frequency ?? this.frequency,
      nickName: nickName ?? this.nickName,
      rating: rating ?? this.rating,
      profilePicture: profilePicture ?? this.profilePicture,
      relationshipType: relationshipType ?? this.relationshipType,
      tags: tags ?? this.tags, // <-- Added
    );
  }

  @override
  String toString() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
      "frequency": frequency,
      "rating": rating,
      "relationshipType": relationshipType,
      "tags": tags,
    }.toString();
  }
}

abstract class RelationshipListState {
  final List<Relationship> relationships;
  final bool isLoading;
  final String? error;

  RelationshipListState({
    this.relationships = const [],
    this.isLoading = false,
    this.error,
  });
}

class RelationshipListInitial extends RelationshipListState {}

class RelationshipListLoading extends RelationshipListState {
  RelationshipListLoading() : super(isLoading: true);
}

class RelationshipListLoaded extends RelationshipListState {
  RelationshipListLoaded({required super.relationships})
      : super(isLoading: false);
}

class RelationshipListError extends RelationshipListState {
  RelationshipListError({required String error})
      : super(isLoading: false, error: error);
}
