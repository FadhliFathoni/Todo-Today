import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

class ListCategoryPage extends StatefulWidget {
  const ListCategoryPage(
      {super.key, required this.kategori, required this.user});
  final CollectionReference<Map<String, dynamic>> kategori;
  final String user;

  @override
  State<ListCategoryPage> createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
        centerTitle: true,
        title: Text(
          "List Kategori",
          style: myTextStyle(color: PRIMARY_COLOR, size: 18),
        ),
      ),
      body: StreamBuilder(
        stream: widget.kategori.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "Belum ada kategori",
                style: myTextStyle(),
              ),
            );
          }
          var data = snapshot.data!.docs;
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.black.withOpacity(0.15),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada kategori",
                    style: myTextStyle(
                      size: 18,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            margin: EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var dataCategory = data[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text(
                      dataCategory["name"],
                      style: myTextStyle(),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded),
                      onSelected: (value) {
                        if (value == "edit") {
                          var nameController =
                              TextEditingController(text: dataCategory["name"]);

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Center(
                                child: Text(
                                  "Edit Kategori",
                                  style: myTextStyle(
                                    color: PRIMARY_COLOR,
                                    size: 18,
                                  ),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PrimaryTextField(
                                    controller: nameController,
                                    hintText: dataCategory["name"],
                                    onChanged: (data) {},
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Batal",
                                    style: myTextStyle(color: PRIMARY_COLOR),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PRIMARY_COLOR,
                                  ),
                                  onPressed: () {
                                    if (nameController.value.text.isNotEmpty) {
                                      String oldName = dataCategory["name"];
                                      String newName =
                                          nameController.value.text.trim();

                                      // Update category name
                                      widget.kategori
                                          .doc(dataCategory.id)
                                          .update({
                                        "name": newName,
                                        "time": DateTime.now(),
                                      });

                                      // Update all records that reference this category
                                      _updateRecordsWithCategory(
                                          oldName, newName);

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    "Syudah",
                                    style: myTextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (value == "delete") {
                          var nameController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Center(
                                child: Text(
                                  "Yakin mau dihapus?",
                                  style: myTextStyle(
                                    size: 18,
                                    color: Colors.red.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Ketik dulu : " + dataCategory["name"],
                                    style: myTextStyle(),
                                  ),
                                  SizedBox(height: 12),
                                  PrimaryTextField(
                                    controller: nameController,
                                    hintText: dataCategory["name"],
                                    onChanged: (data) {},
                                  ),
                                ],
                              ),
                              actions: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: PRIMARY_COLOR,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Batal",
                                      style: myTextStyle(color: PRIMARY_COLOR),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (nameController.value.text ==
                                          dataCategory["name"]) {
                                        widget.kategori
                                            .doc(dataCategory.id)
                                            .delete();
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(
                                      "Hapus ajah",
                                      style: myTextStyle(
                                          color: Colors.red.withOpacity(0.7)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      color: Colors.white,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Edit",
                                style: myTextStyle(color: Colors.blueGrey),
                              ),
                              Icon(Icons.edit, color: Colors.blueGrey),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Delete",
                                style: myTextStyle(
                                    color: Colors.red.withOpacity(0.7)),
                              ),
                              Icon(Icons.delete,
                                  color: Colors.red.withOpacity(0.7)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: PRIMARY_COLOR,
        ),
        backgroundColor: Colors.white,
        onPressed: () {
          var kategoriController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  "Tambah Kategori",
                  style: myTextStyle(size: 16, color: PRIMARY_COLOR),
                ),
              ),
              content: PrimaryTextField(
                controller: kategoriController,
                hintText: "Kategori apah?",
                onChanged: (data) {},
              ),
              actions: [
                ElevatedButton(
                  style: myElevatedButtonStyle(),
                  onPressed: () {
                    if (kategoriController.value.text.trim().isNotEmpty) {
                      widget.kategori.add({
                        "name": kategoriController.value.text.trim(),
                        "time": DateTime.now(),
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Syudah",
                    style: myTextStyle(color: PRIMARY_COLOR),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateRecordsWithCategory(
      String oldName, String newName) async {
    try {
      var instance = FirebaseFirestore.instance;
      var collection = instance.collection("finance").doc(widget.user);
      var record = collection.collection("record");

      // Get all records
      var recordsSnapshot =
          await record.where("kategori", isEqualTo: oldName).get();

      // Update each record
      for (var doc in recordsSnapshot.docs) {
        await record.doc(doc.id).update({
          "kategori": newName,
        });
      }
    } catch (e) {
      print("Error updating records: $e");
    }
  }
}
