import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:todo_today/Component/Text/MyTextStyle.dart';
import 'package:todo_today/main.dart';

class NoteDetailPage extends StatefulWidget {
  final String user;
  final String folderId;
  final String noteId;
  final String title;
  final String description;

  const NoteDetailPage({
    super.key,
    required this.user,
    required this.folderId,
    required this.noteId,
    required this.title,
    required this.description,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController descController;
  late String originalText;

  @override
  void initState() {
    super.initState();
    originalText = widget.description;
    descController = TextEditingController(text: originalText);

    // Autosave on text change
    descController.addListener(_autoSaveNote);
  }

  @override
  void dispose() {
    descController.removeListener(_autoSaveNote);
    descController.dispose();
    super.dispose();
  }

  void _autoSaveNote() async {
    // Save only when the text has changed
    if (descController.text != originalText) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.user)
          .collection('kategori')
          .doc(widget.folderId)
          .collection('notes')
          .doc(widget.noteId)
          .update({
        'description': descController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      originalText = descController.text; // Update originalText after saving
    }
  }

  void _undoChanges() {
    setState(() {
      descController.text = originalText;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perubahan dibatalkan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
          255, 245, 245, 245), // Light grey background for neutral look
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 164, 83, 56), // PRIMARY_COLOR for AppBar
        elevation: 0, // Removes shadow for clean look
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.undo, color: Colors.white),
            onPressed: _undoChanges,
          ),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: descController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disalin ke clipboard')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deskripsi Catatan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 75, 50, 35), // Deep brown color
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Expanded(
                // Wrap the TextField inside an Expanded widget to avoid infinite size
                child: TextField(
                  cursorColor:
                      Color.fromARGB(255, 164, 83, 56), // PRIMARY_COLOR
                  controller: descController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(
                        255, 60, 60, 60), // Soft Charcoal text color
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan di sini...',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 75, 50, 35), // Deep Brown for hint
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
