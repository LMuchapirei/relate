
import 'package:image_picker/image_picker.dart';

abstract class RelationShipEvent {
  const RelationShipEvent();
}

class FirstNameEvent extends RelationShipEvent {
  final String firstName;
  const FirstNameEvent(this.firstName);
}

class LastNameEvent extends RelationShipEvent {
  final String lastName;
  const LastNameEvent(this.lastName);
}

class NickNameEvent extends RelationShipEvent {
  final String nickName;
  const NickNameEvent(this.nickName);
}

class FrequencyEvent extends RelationShipEvent {
  final double frequency;
  const FrequencyEvent(this.frequency);
}

class PhoneNumberEvent extends RelationShipEvent {
  final String phoneNumber;
  const PhoneNumberEvent(this.phoneNumber);
}

class RatingEvent extends RelationShipEvent {
  final double rating;
  const RatingEvent(this.rating);
}

class ProfilePictureEvent extends RelationShipEvent {
  final XFile file;
  const ProfilePictureEvent(this.file);
}


class RelationshipTypeEvent extends RelationShipEvent {
  final String relationShipType;
  const RelationshipTypeEvent(this.relationShipType);
}


class LoadRelationships extends RelationShipEvent {}