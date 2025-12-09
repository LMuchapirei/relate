import 'package:equatable/equatable.dart';
import 'package:relate/features/relationship/bloc/birthday_log_model.dart';

abstract class BirthdayLogState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BirthdayLogsInitial extends BirthdayLogState {}

class BirthdayLogsLoading extends BirthdayLogState {}

class BirthdayLogsLoaded extends BirthdayLogState {
  final List<BirthdayLog> logs;
  BirthdayLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class BirthdayLogsError extends BirthdayLogState {
  final String error;
  BirthdayLogsError(this.error);

  @override
  List<Object?> get props => [error];
}