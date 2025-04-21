import 'package:image_picker/image_picker.dart';

import '../models/relationship_model.dart';

class RelationshipFormStates {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final double frequency;
  final double rating;
  final String relationshipType;
  final String nickName;
  final XFile? profilePicture;

  const RelationshipFormStates({
    this.firstName = "",
    this.lastName = "",
    this.frequency = 0.0,
    this.phoneNumber = "",
    this.rating = 0.0,
    this.nickName= "",
    this.relationshipType = "",
    this.profilePicture
  });

  RelationshipFormStates copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    double? frequency,
    double? rating,
    String? nickName,
    String? relationshipType,
    XFile? profilePicture
  }) {
    return RelationshipFormStates(
     firstName: firstName ?? this.firstName,
     lastName: lastName ?? this.lastName,
     phoneNumber: phoneNumber ?? this.phoneNumber,
     frequency: frequency ?? this.frequency,
     nickName: nickName ?? this.nickName,
     rating: rating ?? this.rating,
     profilePicture: profilePicture ?? this.profilePicture,
     relationshipType: relationshipType ?? this.relationshipType
     );
  }

  @override
  String toString() {
    return {
      "firstName":firstName,
      "lastName":lastName,
      "phoneNumber": phoneNumber,
      "frequency":frequency,
      "rating":rating,
      "relationshipType":relationshipType
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
