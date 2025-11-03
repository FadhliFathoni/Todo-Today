import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/MyTextStyle.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Heading1(
          text: 'Catatan',
          color: PRIMARY_COLOR,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: kategori.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child: MyCircularProgressIndicator(),);
          var list = snapshot.data!.docs;
          if (searchQuery.isNotEmpty) {
            list = list.where((doc) {
              var name = doc['name'].toLowerCase();
              return name.contains(searchQuery);
            }).toList();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    cursorColor: PRIMARY_COLOR,
                    controller: _searchController,
                    style: MyTextStyle(fontSize: 16, color: PRIMARY_COLOR),
                    decoration: InputDecoration(
                      hintText: 'Nyari folder apa?',
                      hintStyle: MyTextStyle(fontSize: 14, color: Colors.grey),
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

              var doc = list[index - 1];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  title: Text(
                    doc['name'],
                    style:
                        MyTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: PRIMARY_COLOR),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white70,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    String folderId = doc.id;
                    String folderName = doc['name'];

                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit, color: PRIMARY_COLOR),
                            title:
                                Text('Edit Nama Folder', style: myTextStyle()),
                            onTap: () async {
                              Navigator.pop(context);
                              TextEditingController nameController =
                                  TextEditingController(text: folderName);

                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Nama Folder',
                                      style: myTextStyle(size: 18)),
                                  content: TextField(
                                    controller: nameController,
                                    cursorColor: PRIMARY_COLOR,
                                    style: myTextStyle(),
                                    decoration: InputDecoration(
                                      hintText: 'Nama folder baru',
                                      hintStyle: myTextStyle(
                                          size: 14, color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                            BorderSide(color: PRIMARY_COLOR),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: PRIMARY_COLOR, width: 2),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Batal',
                                          style:
                                              myTextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        String newName =
                                            nameController.text.trim();
                                        if (newName.isNotEmpty) {
                                          await kategori
                                              .doc(folderId)
                                              .update({'name': newName});
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                        'Simpan',
                                        style: myTextStyle(
                                            color: PRIMARY_COLOR,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Hapus Folder',
                                style: myTextStyle(color: Colors.red)),
                            onTap: () async {
                              Navigator.pop(context);
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Hapus Folder?',
                                      style: myTextStyle(size: 18)),
                                  content: Text(
                                    'Semua catatan dalam folder ini juga akan terhapus.',
                                    style: myTextStyle(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Batal',
                                          style:
                                              myTextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Hapus',
                                          style:
                                              myTextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await kategori.doc(folderId).delete();
                              }
                            },
                          ),
                        ],
                      ),
                    );
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
