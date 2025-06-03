import 'package:equatable/equatable.dart';

abstract class TopicEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTopics extends TopicEvent {
  final String relationshipId;
  LoadTopics(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

class CreateTopic extends TopicEvent {
  final String relationshipId;
  final String title;
  final String description;
  CreateTopic({required this.relationshipId, required this.title, required this.description});

  @override
  List<Object?> get props => [relationshipId, title, description];
}

class DeleteTopic extends TopicEvent {
  final String topicId;
  DeleteTopic(this.topicId);

  @override
  List<Object?> get props => [topicId];
}