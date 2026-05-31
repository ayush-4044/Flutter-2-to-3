import 'package:flutter/material.dart';
import 'database/db_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  // Fetch all notes from SQLite database
  void _refreshNotes() async {
    final data = await DatabaseHelper.instance.getNotes();
    setState(() => _notes = data);
  }

  // Dialog box to Add or Edit a note
  void _showNoteDialog({Map<String, dynamic>? note}) {
    TextEditingController titleController = TextEditingController(text: note?['title'] ?? '');
    TextEditingController contentController = TextEditingController(text: note?['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? "New Note" : "Edit Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title"),
              autofocus: note == null, // Autofocus only for new notes
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: "Content"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                if (note == null) {
                  // Insert new note
                  await DatabaseHelper.instance.insertNote({
                    'title': titleController.text,
                    'content': contentController.text
                  });
                } else {
                  // Update existing note
                  await DatabaseHelper.instance.updateNote({
                    'id': note['id'],
                    'title': titleController.text,
                    'content': contentController.text
                  });
                }
                _refreshNotes();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _notes.isEmpty
          ? const Center(child: Text("No notes yet. Add one!"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];

          return Card(
            child: ListTile(
              title: Text(
                  note['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text(
                  note['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
              ),
              // Tapping the card itself will also open the edit dialog
              onTap: () => _showNoteDialog(note: note),

              // Added a Row to hold both Edit and Delete icons
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showNoteDialog(note: note), // Triggers the edit function
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteNote(note['id']);
                      _refreshNotes();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}