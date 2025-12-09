import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_controller.dart';
import 'package:relate/features/relationship/bloc/birthday_log_model.dart';
import 'package:relate/features/relationship/bloc/birthday_log_state.dart';
import 'birthday_log_events.dart';
import 'package:relate/global.dart';

class BirthdayLogsBloc extends Bloc<BirthdayLogEvent, BirthdayLogState> {
  BirthdayLogsBloc() : super(BirthdayLogsInitial()) {
    on<LoadBirthdayLogs>(_onLoadBirthdayLogs);
    on<CreateBirthdayLog>(_onCreateBirthdayLog);
    on<DeleteBirthdayLog>(_onDeleteBirthdayLog);
  }

  Future<void> _onLoadBirthdayLogs(LoadBirthdayLogs event, Emitter<BirthdayLogState> emit) async {
    emit(BirthdayLogsLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(BirthdayLogsError('User not signed in.'));
        return;
      }
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f153200079f3f5d8b';

      final appwrite_models.DocumentList docs = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('relationshipId', event.relationshipId),
          Query.equal('userId', user.uid),
          Query.orderDesc('createdAt'),
        ],
      );

      final logs = docs.documents.map((doc) => BirthdayLog.fromMap(doc.data)).toList();
      emit(BirthdayLogsLoaded(logs));
    } catch (e) {
      emit(BirthdayLogsError('Failed to load birthday logs: $e'));
    }
  }

  Future<void> _onCreateBirthdayLog(CreateBirthdayLog event, Emitter<BirthdayLogState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(BirthdayLogsError('User not signed in.'));
        return;
      }
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f153200079f3f5d8b';
      /// upload each attachment and then return the url of the uploaded file from appwrite to then store in the database
      final summaryController = InteractionSummaryController();
      List<Map<String,dynamic>> attachmentsRecords = [];
      for(var file in event.attachments) {
        final fileMeta = await summaryController.uploadFileToAppwrite(
          file['path'],
          '683fec1e0035f3b0514f', /// need to find a way to generate this collection id dynamically
        );
        attachmentsRecords.add(fileMeta);
      }
      final log = BirthdayLog(
        id: '',
        relationshipId: event.relationshipId,
        userId: user.uid,
        date: event.date,
        reflection: event.reflection,
        attachments: attachmentsRecords,
        createdAt: DateTime.now(),
      );

      await database.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: log.toMap(),
      );

      add(LoadBirthdayLogs(event.relationshipId));
    } catch (e) {
      emit(BirthdayLogsError('Failed to create birthday log: $e'));
    }
  }

  Future<void> _onDeleteBirthdayLog(DeleteBirthdayLog event, Emitter<BirthdayLogState> emit) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f153200079f3f5d8b';

      await database.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: event.logId,
      );
      // Optionally reload logs after deletion
    } catch (e) {
      emit(BirthdayLogsError('Failed to delete birthday log: $e'));
    }
  }
}