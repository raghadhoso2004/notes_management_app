import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note_model.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();

  List<Note> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
    _syncService.syncNotes();
  }

  Future<void> loadNotes() async {
    final data = await _databaseHelper.getAllNotes();
    if (!mounted) return;
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  Future<void> deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    await loadNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted successfully')),
    );
  }

  Future<void> syncNow() async {
    await _syncService.syncNotes();
    await loadNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync completed')),
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> goToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
    );

    if (result == true) {
      await loadNotes();
      await _syncService.syncNotes();
      await loadNotes();
    }
  }

  Future<void> goToEditNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
    );

    if (result == true) {
      await loadNotes();
      await _syncService.syncNotes();
      await loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ⭐ APP BAR MODERN
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: syncNow,
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // ⭐ BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(
        child: Text(
          'No notes yet ✨\nTap + to add your first note',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),

            // ⭐ MODERN CARD DESIGN
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(15),

              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  note.title.isNotEmpty
                      ? note.title[0].toUpperCase()
                      : "N",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              title: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteNote(note.id!),
              ),

              onTap: () => goToEditNote(note),
            ),
          );
        },
      ),

      // ⭐ FLOATING BUTTON MODERN
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: goToAddNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}