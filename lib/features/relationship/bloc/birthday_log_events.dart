import 'package:equatable/equatable.dart';

abstract class BirthdayLogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBirthdayLogs extends BirthdayLogEvent {
  final String relationshipId;
  LoadBirthdayLogs(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

class CreateBirthdayLog extends BirthdayLogEvent {
  final String relationshipId;
  final String date;
  final String reflection;
  final List<Map<String, dynamic>> attachments;
  CreateBirthdayLog({
    required this.relationshipId,
    required this.date,
    required this.reflection,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [relationshipId, date, reflection, attachments];
}

class DeleteBirthdayLog extends BirthdayLogEvent {
  final String logId;
  DeleteBirthdayLog(this.logId);

  @override
  List<Object?> get props => [logId];
}