import 'package:equatable/equatable.dart';
import 'package:relate/features/relationship/bloc/topic_model.dart';


abstract class TopicState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TopicsInitial extends TopicState {}

class TopicsLoading extends TopicState {}

class TopicsLoaded extends TopicState {
  final List<Topic> topics;
  TopicsLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

class TopicsError extends TopicState {
  final String error;
  TopicsError(this.error);

  @override
  List<Object?> get props => [error];
}