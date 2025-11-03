import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:todo_today/views/notes/addNotePage.dart';
import 'package:todo_today/views/notes/noteDetailPage.dart';

class FolderPage extends StatefulWidget {
  final String user;
  final String folderId;
  final String folderName;

  const FolderPage({
    super.key,
    required this.user,
    required this.folderId,
    required this.folderName,
  });

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  late TextEditingController _searchController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var folderRef = FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.user)
        .collection('kategori')
        .doc(widget.folderId);

    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.folderName,
          style: myTextStyle(size: 24),
        ),
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: folderRef
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: MyCircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi error, coba lagi nanti'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Icon(
                      Icons.cloud_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                  Container(
                    child: Text(
                      'Belum ada catatan nihhh',
                      style: myTextStyle(
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          var notes = snapshot.data!.docs;
          if (searchQuery.isNotEmpty) {
            notes = notes.where((doc) {
              var title = doc['title'].toLowerCase();
              return title.contains(searchQuery);
            }).toList();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notes.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    cursorColor: PRIMARY_COLOR,
                    controller: _searchController,
                    style: myTextStyle(size: 16, color: PRIMARY_COLOR),
                    decoration: InputDecoration(
                      hintText: 'Cari catatan',
                      hintStyle: myTextStyle(size: 14, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                );
              }

              var doc = notes[index - 1];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  title: Text(
                    doc['title'],
                    style: myTextStyle(
                      size: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: PRIMARY_COLOR,
                  ),
                  tileColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(
                          user: widget.user,
                          folderId: widget.folderId,
                          noteId: doc.id,
                          title: doc['title'],
                          description: doc['description'],
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text(
                          'Hapus Catatan?',
                          style: myTextStyle(size: 18),
                        ),
                        content: Text(
                          doc['title'],
                          textAlign: TextAlign.center,
                          style: myTextStyle(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Batal',
                              style: myTextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Hapus',
                              style: myTextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await folderRef.collection('notes').doc(doc.id).delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white70,
        onPressed: () async {
          final newDoc = FirebaseFirestore.instance
              .collection('notes')
              .doc(widget.user)
              .collection('kategori')
              .doc(widget.folderId)
              .collection('notes')
              .doc();

          await newDoc.set({
            'title': 'ini judul default',
            'description': 'tulis sesuatu plis',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(
                user: widget.user,
                folderId: widget.folderId,
                noteId: newDoc.id,
                title: 'ini judul default',
                description: 'tulis sesuatu plis',
              ),
            ),
          );
        },
        child: Icon(
          Icons.note_add,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}
