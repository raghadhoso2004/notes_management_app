import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // ⭐ رفعنا النسخة بسبب تعديل الجدول
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ⭐ TABLE UPDATED (IMPORTANT)
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseId TEXT,
        userId TEXT, -- ⭐ مهم لكل مستخدم
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL
      )
    ''');
  }

  // ⭐ MIGRATION
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN firebaseId TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN updatedAt TEXT DEFAULT ""');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE notes ADD COLUMN userId TEXT');
    }
  }

  // ⭐ INSERT NOTE (linked to user)
  Future<int> insertNote(Note note) async {
    final db = await database;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    return await db.insert('notes', {
      ...note.toMap(),
      'userId': userId,
    });
  }

  // ⭐ GET ONLY CURRENT USER NOTES
  Future<List<Note>> getAllNotes() async {
    final db = await database;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final result = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return result.map((e) => Note.fromMap(e)).toList();
  }

  // ⭐ UNSYNCED ONLY FOR CURRENT USER
  Future<List<Note>> getUnsyncedNotes() async {
    final db = await database;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final result = await db.query(
      'notes',
      where: 'isSynced = ? AND userId = ?',
      whereArgs: [0, userId],
    );

    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;

    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsSynced(int id, String firebaseId) async {
    final db = await database;

    await db.update(
      'notes',
      {
        'isSynced': 1,
        'firebaseId': firebaseId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}