import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    originalText = widget.description;
    descController = TextEditingController(text: originalText);
    descController.addListener(_autoSaveNote);
  }

  @override
  void dispose() {
    descController.removeListener(_autoSaveNote);
    descController.dispose();
    super.dispose();
  }

  void _autoSaveNote() async {
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

      originalText = descController.text;
    }
  }

  void _undoChanges() {
    setState(() {
      descController.text = originalText;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perubahan dibatalkan')));
  }

  Widget _buildFormattedText(String text) {
    final regex = RegExp(r'==(.+?)==', multiLine: true);
    final spans = <InlineSpan>[];

    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final highlightedText = match.group(1)!;

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: highlightedText));
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              highlightedText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 16),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: PRIMARY_COLOR),
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: 18, color: PRIMARY_COLOR, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.undo, color: PRIMARY_COLOR),
            onPressed: _undoChanges,
          ),
          IconButton(
            icon: Icon(Icons.copy, color: PRIMARY_COLOR),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: descController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disalin ke clipboard')),
              );
            },
          ),
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit,
                color: PRIMARY_COLOR),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 245, 245, 245),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isEditMode
            ? TextField(
                cursorColor: Color.fromARGB(255, 164, 83, 56),
                controller: descController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 60, 60, 60),
                ),
                decoration: InputDecoration(
                  hintText: 'Tulis catatan di sini...',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 75, 50, 35),
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              )
            : SingleChildScrollView(
                child: _buildFormattedText(descController.text),
              ),
      ),
    );
  }
}
