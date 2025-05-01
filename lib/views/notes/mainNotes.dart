import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/Heading3.dart';
import 'package:todo_today/Component/Text/MyTextStyle.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:todo_today/views/notes/addNotePage.dart';
import 'package:todo_today/views/notes/folderPage.dart';

class NotesPage extends StatefulWidget {
  final String user;
  const NotesPage({super.key, required this.user});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
    var kategori = FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.user)
        .collection('kategori');

    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        centerTitle: true,
        title: Heading1(
          text: 'Catatan',
          color: PRIMARY_COLOR,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: PRIMARY_COLOR,
              controller: _searchController,
              style: MyTextStyle(
                  fontSize: 16, color: PRIMARY_COLOR), // <-- warna text user
              decoration: InputDecoration(
                hintText: 'Nyari folder apa?',
                hintStyle:
                    MyTextStyle(fontSize: 14, color: Colors.grey), // warna hint
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white70,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  kategori.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var list = snapshot.data!.docs;
                if (searchQuery.isNotEmpty) {
                  list = list.where((doc) {
                    var name = doc['name'].toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) => SizedBox(
                    height: 12,
                  ),
                  itemBuilder: (context, index) {
                    var doc = list[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        title: Text(
                          doc['name'],
                          style: MyTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: PRIMARY_COLOR,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.white70,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FolderPage(
                                user: widget.user,
                                folderId: doc.id,
                                folderName: doc['name'],
                              ),
                            ),
                          );
                        },
                        onLongPress: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Folder?'),
                              content: const Text(
                                  'Semua catatan dalam folder ini juga akan terhapus.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await kategori.doc(doc.id).delete();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white70,
        onPressed: () async {
          TextEditingController folderNameController = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  'Tambah Folder Baru',
                  style: MyTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PRIMARY_COLOR,
                  ),
                ),
              ),
              content: TextField(
                cursorColor: PRIMARY_COLOR,
                controller: folderNameController,
                autofocus: true,
                style: MyTextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Nama Folder',
                  hintStyle: MyTextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: PRIMARY_COLOR,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: PRIMARY_COLOR,
                      width: 2,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: MyTextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    String folderName = folderNameController.text.trim();
                    if (folderName.isNotEmpty) {
                      var kategori = FirebaseFirestore.instance
                          .collection('notes')
                          .doc(widget.user)
                          .collection('kategori');

                      await kategori.add({
                        'name': folderName,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: MyTextStyle(
                      fontSize: 14,
                      color: PRIMARY_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: Icon(
          Icons.create_new_folder,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}

class NotesCard extends StatelessWidget {
  const NotesCard({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Text(
        title,
        style: myTextStyle(size: 12),
      ),
    );
  }
}
