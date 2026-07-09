import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<String> uploadNote(Note note) async {
    final doc = await _firestore.collection('notes').add(
      note.toFirestore(userId),
    );
    return doc.id;
  }

  Future<void> updateNote(Note note) async {
    if (note.firebaseId == null) return;

    await _firestore.collection('notes').doc(note.firebaseId).update(
      note.toFirestore(userId),
    );
  }

  Future<void> deleteNote(String firebaseId) async {
    await _firestore.collection('notes').doc(firebaseId).delete();
  }
}