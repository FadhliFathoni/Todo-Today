import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotePage extends StatefulWidget {
  final String user;
  final String? folderId;
  final bool isFolder;

  const AddNotePage(
      {super.key, required this.user, this.folderId, this.isFolder = false});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: widget.isFolder ? 'Nama Folder' : 'Judul Catatan',
            border: InputBorder.none, // Optional, to remove border
          ),
          style: TextStyle(color: Colors.white), // Optional, to style the text
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              var ref = FirebaseFirestore.instance
                  .collection('notes')
                  .doc(widget.user);

              if (widget.isFolder) {
                await ref.collection('kategori').add({
                  'name': titleController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              } else {
                await ref
                    .collection('kategori')
                    .doc(widget.folderId)
                    .collection('notes')
                    .add({
                  'title': titleController.text,
                  'description': descController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!widget.isFolder) ...[
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 10,
                decoration: const InputDecoration(hintText: 'Deskripsi / Kode'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
