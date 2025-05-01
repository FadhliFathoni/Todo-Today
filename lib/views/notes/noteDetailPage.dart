import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

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
  late TextEditingController titleController;
  late String originalText;
  late String originalTitle;
  late String noteTitle;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    originalText = widget.description;
    originalTitle = widget.title;
    noteTitle = widget.title;

    descController = TextEditingController(text: originalText);
    titleController = TextEditingController(text: noteTitle);

    descController.addListener(_autoSaveNote);
    titleController.addListener(_autoSaveNote);
  }

  @override
  void dispose() {
    descController.removeListener(_autoSaveNote);
    titleController.removeListener(_autoSaveNote);
    descController.dispose();
    titleController.dispose();
    super.dispose();
  }

  void _autoSaveNote() async {
    if (descController.text != originalText ||
        titleController.text != originalTitle) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.user)
          .collection('kategori')
          .doc(widget.folderId)
          .collection('notes')
          .doc(widget.noteId)
          .update({
        'title': titleController.text,
        'description': descController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      originalText = descController.text;
      originalTitle = titleController.text;
    }
  }

  void _toggleBold() {
    final selection = descController.selection;
    final text = descController.text;

    if (selection.start >= 0 && selection.end > selection.start) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
          selection.start, selection.end, '**$selectedText**');

      descController.text = newText;
      descController.selection = TextSelection.collapsed(
          offset: selection.start + selectedText.length + 4);
    }
  }

  Widget _buildFormattedText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'==(.+?)==|\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      if (match.group(1) != null) {
        // Highlighted text
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
              child: Text(highlightedText),
            ),
          ),
        ));
      } else if (match.group(2) != null) {
        // Bold text
        final boldText = match.group(2)!;
        spans.add(TextSpan(
            text: boldText, style: TextStyle(fontWeight: FontWeight.bold)));
      }

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
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: PRIMARY_COLOR),
        title: isEditMode
            ? SizedBox(
                width: 200,
                child: TextField(
                  cursorColor: PRIMARY_COLOR,
                  controller: titleController,
                  style: myTextStyle(
                      size: 18,
                      color: PRIMARY_COLOR,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Judul catatan di sini...",
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintStyle: myTextStyle()),
                  onChanged: (value) {
                    setState(() {
                      noteTitle = value;
                    });
                  },
                ),
              )
            : Text(
                noteTitle,
                style: myTextStyle(
                  size: 18,
                  color: PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.format_bold, color: PRIMARY_COLOR),
              onPressed: _toggleBold,
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
                  fontSize: 14,
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
