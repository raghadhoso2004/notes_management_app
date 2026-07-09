import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import 'firestore_service.dart';

class SyncService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> syncNotes() async {
    final online = await hasInternet();
    if (!online) return;

    final unsyncedNotes = await _databaseHelper.getUnsyncedNotes();

    for (final note in unsyncedNotes) {
      final firebaseId = await _firestoreService.uploadNote(note);

      if (note.id != null) {
        await _databaseHelper.markAsSynced(note.id!, firebaseId);
      }
    }
  }
}