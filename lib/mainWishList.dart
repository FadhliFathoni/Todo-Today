import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/Component/FirebasePicture.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/main.dart';

class Mainwishlist extends StatefulWidget {
  const Mainwishlist({super.key});

  @override
  State<Mainwishlist> createState() => _MainwishlistState();
}

class _MainwishlistState extends State<Mainwishlist>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    super.dispose();
  }

  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return WishList();
      case 1:
        return WishListDone();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        title: GestureDetector(
          onTap: () {},
          child: Text(
            "Wish List Kita",
            style: TextStyle(fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR),
          ),
        ),
        centerTitle: true,
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(size: 30),
        unselectedIconTheme: IconThemeData(size: 25),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Syudah"),
        ],
      ),
    );
  }
}

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference wishlist =
      FirebaseFirestore.instance.collection("wishlist");
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference wishlist = firestore.collection("wishlist");
    PlatformFile? pickedFile;
    String fileName = "File Name";

    UploadTask? uploadTask;
    return Scaffold(
        backgroundColor: BG_COLOR,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  content: Container(
                    padding: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Heading1(
                            color: PRIMARY_COLOR,
                            text: "Create",
                          ),
                        ),
                        SizedBox(height: 10),
                        PrimaryTextField(
                          controller: titleController,
                          hintText: "Title",
                          maxLength: 30,
                          onChanged: (value) {},
                        ),
                        PrimaryTextField(
                          controller: descriptionController,
                          maxLength: 50,
                          hintText: "Description",
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          await wishlist.add({
                            "title": titleController.text,
                            "description": descriptionController.text,
                            "status": "belum",
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(
                          fontFamily: PRIMARY_FONT,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: PRIMARY_COLOR,
          shape: CircleBorder(),
          elevation: 5,
        ),
        body: StreamBuilder(
          stream: wishlist.where("status", isEqualTo: "belum").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 50, color: Colors.black.withOpacity(0.15)),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada jadwal nihhh",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.15),
                          fontFamily: PRIMARY_FONT,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var reference = docs[index].reference;
                  var data = docs[index].data() as Map<String, dynamic>;
                  var titleController =
                      TextEditingController(text: data['title']);
                  var descriptionController =
                      TextEditingController(text: data['description']);
                  var status = data['status'];

                  if (status == "belum") {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              content: Container(
                                padding: EdgeInsets.all(16),
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Heading1(
                                        color: PRIMARY_COLOR,
                                        text: "Update",
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    PrimaryTextField(
                                      controller: titleController,
                                      hintText: "Title",
                                      maxLength: 30,
                                      onChanged: (value) {},
                                    ),
                                    PrimaryTextField(
                                      controller: descriptionController,
                                      maxLength: 50,
                                      hintText: "Description",
                                      onChanged: (value) {},
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await reference.delete();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Apus",
                                    style: TextStyle(
                                      fontFamily: PRIMARY_FONT,
                                      color: PRIMARY_COLOR,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await reference.update({
                                      "title": titleController.text,
                                      "description": descriptionController.text,
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Udehh",
                                    style: TextStyle(
                                      fontFamily: PRIMARY_FONT,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PRIMARY_COLOR,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading:
                              Icon(Icons.favorite_border, color: PRIMARY_COLOR),
                          title: Text(
                            titleController.text.isNotEmpty
                                ? titleController.text
                                : 'No Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: PRIMARY_FONT,
                            ),
                          ),
                          subtitle: descriptionController.text.isNotEmpty
                              ? Text(
                                  descriptionController.text,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: PRIMARY_FONT,
                                  ),
                                )
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.check, color: PRIMARY_COLOR),
                            onPressed: () {
                              TextEditingController ceritaController =
                                  TextEditingController();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      Future<void> selectFile() async {
                                        final result = await FilePicker.platform
                                            .pickFiles();

                                        // Check if result is not null and contains files
                                        if (result != null &&
                                            result.files.isNotEmpty) {
                                          // Use safe access operators to avoid null-related issues
                                          final file = result.files.first;
                                          print("INI RESULT ${file.name}");

                                          if (file.name != "null") {
                                            setState(() {
                                              pickedFile = file;
                                              fileName = pickedFile!.name;
                                            });
                                          }
                                        } else {
                                          print(
                                              "No file selected or result is null");
                                        }
                                      }

                                      Future uploadFile() async {
                                        if (pickedFile != null) {
                                          final path =
                                              'wishlist/${pickedFile!.name}';
                                          final file = File(pickedFile!.path!);

                                          final ref = FirebaseStorage.instance
                                              .ref()
                                              .child(path);
                                          uploadTask = ref.putFile(file);

                                          final snapshot = await uploadTask!
                                              .whenComplete(() {});
                                          final urlDownload = await snapshot.ref
                                              .getDownloadURL();
                                          print("Download link ${urlDownload}");
                                        } else {
                                          return;
                                        }
                                      }

                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        title: Text(
                                          "Bukti Nyata",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: PRIMARY_COLOR,
                                            fontFamily: PRIMARY_FONT,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: selectFile,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      offset: Offset(0, 4),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                width: 160,
                                                height: 160,
                                                margin: EdgeInsets.all(10),
                                                child: Center(
                                                  child: (pickedFile == null)
                                                      ? Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          color: PRIMARY_COLOR,
                                                          size: 40)
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          child: Image.file(
                                                            File(pickedFile!
                                                                .path!),
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            PrimaryTextField(
                                              controller: ceritaController,
                                              hintText:
                                                  "Ada cerita apa hari ini",
                                              maxLine: null,
                                              onChanged: (value) {},
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                uploadFile();
                                                if (pickedFile?.name
                                                            .toString() !=
                                                        "null" &&
                                                    ceritaController
                                                        .text.isNotEmpty) {
                                                  reference.update({
                                                    "status": "syudah",
                                                    "time": Timestamp.now(),
                                                    "picture": pickedFile!.name,
                                                    "cerita":
                                                        ceritaController.text,
                                                  });
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Syudah",
                                                style: TextStyle(
                                                  fontFamily: PRIMARY_FONT,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: PRIMARY_COLOR,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    );
                  } else {
                    return Container(); // This should not be reached since we are filtering by status
                  }
                },
              );
            } else {
              return Container(); // This case should not be reached due to previous checks
            }
          },
        ));
  }
}

class WishListDone extends StatefulWidget {
  const WishListDone({
    Key? key,
  }) : super(key: key);

  @override
  _WishListDoneState createState() => _WishListDoneState();
}

class _WishListDoneState extends State<WishListDone> {
  Map<String, dynamic>? dataWishList;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference wishlist = firestore.collection("wishlist");

    return StreamBuilder(
      stream: wishlist.where("status", isEqualTo: "syudah").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today,
                    size: 50, color: Colors.black.withOpacity(0.15)),
                SizedBox(height: 16),
                Text(
                  "Belum ada jadwal nihhh",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.15),
                    fontFamily: PRIMARY_FONT,
                  ),
                ),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            var reference = docs[index].reference;
            var title = data["title"] ?? 'No Title';
            var description = data["description"] ?? 'No Description';
            var time = data["time"] as Timestamp?;
            var timeString = convertTimestampToIndonesianDate(time);
            return GestureDetector(
              // onLongPress: () {
              //   showDialog(
              //       context: context,
              //       builder: (context) {
              //         return AlertDialog(
              //             backgroundColor: Colors.white,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(20),
              //             ),
              //             title: Text(
              //               "Kepencet?",
              //               style: TextStyle(
              //                   color: PRIMARY_COLOR, fontFamily: PRIMARY_FONT),
              //             ),
              //             actions: [
              //               ElevatedButton(
              //                 onPressed: () {
              //                   Navigator.pop(context);
              //                 },
              //                 child: Text(
              //                   "Tidak",
              //                   style: TextStyle(
              //                     fontFamily: PRIMARY_FONT,
              //                     color: PRIMARY_COLOR,
              //                   ),
              //                 ),
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: Colors.white,
              //                 ),
              //               ),
              //               ElevatedButton(
              //                 onPressed: () async {
              //                   await reference.update({
              //                     "status": "belum",
              //                     "time": "",
              //                   });
              //                   Navigator.pop(context);
              //                 },
              //                 child: Text(
              //                   "Iya",
              //                   style: TextStyle(
              //                     fontFamily: PRIMARY_FONT,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: PRIMARY_COLOR,
              //                 ),
              //               )
              //             ]);
              //       });
              // },
              onTap: () {
                setState(() {
                  dataWishList = data;
                });
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.3,
                      maxChildSize: 1.0, // Allow full screen
                      expand: true,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _StickyHeaderDelegate(),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    GestureDetector(
                                      onTap: () {
                                        getImage(dataWishList!['picture'])
                                            .then((imageUrl) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImage(
                                                imageUrl: imageUrl,
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Hero(
                                            tag: "buktinyata",
                                            child: FirebasePicture(
                                              image: dataWishList!["picture"],
                                              boxFit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        dataWishList!["cerita"] ?? "",
                                        style:
                                            TextStyle(fontFamily: PRIMARY_FONT),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.favorite, color: PRIMARY_COLOR),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: PRIMARY_FONT,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: (description.isNotEmpty)
                      ? Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: PRIMARY_FONT,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: Text(
                    timeString ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: PRIMARY_FONT,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
        title: Text(
          "Bukti Nyata",
          style: TextStyle(fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String? convertTimestampToIndonesianDate(Timestamp? timestamp) {
  if (timestamp == null) return null;
  DateTime date = timestamp.toDate();
  return DateFormat('dd MMMM yyyy').format(date);
}

String imageUrl = 'gs://todo-today-74b74.appspot.com/wishlist/';

Future<String> getImage(String image) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(imageUrl + image);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    return image;
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: Colors.white),
      child: Center(
        child: Text(
          "Bukti Nyata",
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontFamily: PRIMARY_FONT,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60; // Height of the sticky header
  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
