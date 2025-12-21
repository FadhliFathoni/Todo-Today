import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:todo_today/Component/FirebaseMedia.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:url_launcher/url_launcher.dart';

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
        surfaceTintColor: Colors.white,
        elevation: 5,
        title: Text(
          "Wish List Kita",
          style: TextStyle(fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR),
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
        selectedLabelStyle: myTextStyle(),
        unselectedLabelStyle: myTextStyle(),
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
  TextEditingController ceritaController = TextEditingController();
  TextEditingController linkController = TextEditingController();

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

    return Scaffold(
        backgroundColor: BG_COLOR,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
              return Center(child: MyCircularProgressIndicator());
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
                        var linkController = TextEditingController(
                          text: data['link'] ?? '',
                        );
                        DateTime selectedDate =
                            (data['time'] as Timestamp?)?.toDate() ??
                                DateTime.now();

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter dialogSetState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Heading1(
                                              color: PRIMARY_COLOR,
                                              text: "Edit Wishlist",
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          PrimaryTextField(
                                            controller: titleController,
                                            hintText: "Title",
                                            maxLength: 30,
                                            onChanged: (value) {},
                                          ),
                                          SizedBox(height: 10),
                                          PrimaryTextField(
                                            controller: descriptionController,
                                            maxLength: 50,
                                            hintText: "Description",
                                            onChanged: (value) {},
                                          ),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: selectedDate,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: PRIMARY_COLOR,
                                                        onPrimary: Colors.white,
                                                        onSurface: Colors.black,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                dialogSetState(() {
                                                  selectedDate = picked;
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: PRIMARY_COLOR),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    DateFormat('dd MMMM yyyy')
                                                        .format(selectedDate),
                                                    style: TextStyle(
                                                      fontFamily: PRIMARY_FONT,
                                                      color: PRIMARY_COLOR,
                                                    ),
                                                  ),
                                                  Icon(Icons.calendar_today,
                                                      color: PRIMARY_COLOR),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          PrimaryTextField(
                                            controller: linkController,
                                            hintText:
                                                "Link dokumentasi - Opsional",
                                            maxLine: null,
                                            onChanged: (value) {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Map<String, dynamic> updateData = {
                                          "title": titleController.text,
                                          "description":
                                              descriptionController.text,
                                          "time":
                                              Timestamp.fromDate(selectedDate),
                                        };
                                        if (linkController.text
                                            .trim()
                                            .isNotEmpty) {
                                          updateData["link"] =
                                              linkController.text.trim();
                                        } else {
                                          updateData["link"] =
                                              FieldValue.delete();
                                        }
                                        await reference.update(updateData);
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
                        );
                      },
                      child: Card(
                        color: Colors.white,
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
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      Future<void> selectFile() async {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: [
                                            // Image formats only
                                            'jpg',
                                            'jpeg',
                                            'png',
                                            'gif',
                                            'webp',
                                            'bmp',
                                          ],
                                        );

                                        // Check if result is not null and contains files
                                        if (result != null &&
                                            result.files.isNotEmpty) {
                                          // Use safe access operators to avoid null-related issues
                                          final file = result.files.first;

                                          if (file.name != "null") {
                                            setState(() {
                                              pickedFile = file;
                                            });
                                          }
                                        } else {
                                          print(
                                              "No file selected or result is null");
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
                                        content: SingleChildScrollView(
                                          child: Column(
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
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  width: 160,
                                                  height: 160,
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 0,
                                                      left: 10,
                                                      right: 10),
                                                  child: Center(
                                                    child: (pickedFile == null)
                                                        ? Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            color:
                                                                PRIMARY_COLOR,
                                                            size: 40)
                                                        : _buildFilePreview(
                                                            pickedFile!),
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
                                              SizedBox(height: 12),
                                              PrimaryTextField(
                                                controller: linkController,
                                                hintText:
                                                    "Ingpo link dokumentasi - Opsional",
                                                maxLine: null,
                                                onChanged: (value) {},
                                              ),
                                              SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (pickedFile?.name
                                                              .toString() !=
                                                          "null" &&
                                                      ceritaController
                                                          .text.isNotEmpty) {
                                                    String? pictureData;

                                                    // Convert image to base64 with compression
                                                    Uint8List? bytes =
                                                        pickedFile!.bytes;
                                                    if (bytes == null &&
                                                        pickedFile!.path !=
                                                            null) {
                                                      bytes = await File(
                                                              pickedFile!.path!)
                                                          .readAsBytes();
                                                    }

                                                    if (bytes != null) {
                                                      // Compress if needed
                                                      const maxSize = 500 * 1024;
                                                      if (bytes.length >
                                                          100 * 1024) {
                                                        bytes =
                                                            await _compressImage(
                                                                bytes, maxSize);
                                                      }

                                                      // Detect MIME type
                                                      final ext = pickedFile!
                                                          .name
                                                          .toLowerCase()
                                                          .split('.')
                                                          .last;
                                                      String mimeType =
                                                          'image/jpeg';
                                                      if (ext == 'png') {
                                                        mimeType = 'image/png';
                                                      } else if (ext == 'gif') {
                                                        mimeType = 'image/gif';
                                                      } else if (ext ==
                                                          'webp') {
                                                        mimeType = 'image/webp';
                                                      }

                                                      // If compressed, always JPEG
                                                      if (bytes.length !=
                                                          pickedFile!
                                                              .bytes?.length) {
                                                        mimeType = 'image/jpeg';
                                                      }

                                                      pictureData =
                                                          'data:$mimeType;base64,${base64Encode(bytes)}';
                                                    }

                                                    if (pictureData != null) {
                                                      Map<String, dynamic>
                                                          updateData = {
                                                        "status": "syudah",
                                                        "time": Timestamp.now(),
                                                        "picture": pictureData,
                                                        "cerita":
                                                            ceritaController
                                                                .text,
                                                      };
                                                      // Add link if provided
                                                      if (linkController.text
                                                          .trim()
                                                          .isNotEmpty) {
                                                        updateData["link"] =
                                                            linkController.text
                                                                .trim();
                                                      }
                                                      await reference
                                                          .update(updateData);
                                                      Navigator.pop(context);
                                                    }
                                                  } else {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text(
                                                  "Syudah",
                                                  style: TextStyle(
                                                    fontFamily: PRIMARY_FONT,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      PRIMARY_COLOR,
                                                ),
                                              ),
                                            ],
                                          ),
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
                    return Container();
                  }
                },
              );
            } else {
              return Container();
            }
          },
        ));
  }
}

class MyCircularProgressIndicator extends StatelessWidget {
  const MyCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: PRIMARY_COLOR,
    );
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
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference wishlist = firestore.collection("wishlist");

    return StreamBuilder(
      stream: wishlist
          .where("status", isEqualTo: "syudah")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: MyCircularProgressIndicator());
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
            var docId = docs[index].id;
            var data = docs[index].data() as Map<String, dynamic>;
            var title = data["title"] ?? 'No Title';
            var description = data["description"] ?? 'No Description';
            var time = data["time"] as Timestamp?;
            var timeString = convertTimestampToIndonesianDate(time);
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.3,
                      maxChildSize: 1.0,
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
                                        // Open FullScreenImage if it's a photo (image or gif)
                                        if (_isPhotoFormat(data['picture'])) {
                                          getImage(data['picture'])
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
                                        }
                                        // Open FullScreenVideo if it's a video
                                        else if (_isVideoFormat(
                                            data['picture'])) {
                                          getImage(data['picture'])
                                              .then((videoUrl) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FullScreenVideo(
                                                  videoUrl: videoUrl,
                                                ),
                                              ),
                                            );
                                          });
                                        }
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
                                            child: data["picture"]
                                                        ?.startsWith(
                                                            "data:image") ==
                                                    true
                                                ? Image.memory(
                                                    base64Decode(
                                                      data["picture"]
                                                          .split(",")
                                                          .last,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Builder(
                                                    builder: (context) {
                                                      // Trigger conversion to base64 in background
                                                      if (data["picture"] !=
                                                              null &&
                                                          _isPhotoFormat(
                                                              data["picture"])) {
                                                        _convertImageToBase64AndUpdate(
                                                            docId,
                                                            data["picture"]);
                                                      }
                                                      return FirebaseMedia(
                                                        mediaUrl:
                                                            data["picture"],
                                                        boxFit: BoxFit.cover,
                                                        autoPlay: false,
                                                        showControls: true,
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        data["cerita"] ?? "",
                                        style:
                                            TextStyle(fontFamily: PRIMARY_FONT),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                    if (data["link"] != null &&
                                        data["link"]
                                            .toString()
                                            .trim()
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              final url = data["link"]
                                                  .toString()
                                                  .trim();
                                              final uri = Uri.parse(url);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Tidak dapat membuka link: $url',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                PRIMARY_FONT),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${e.toString()}',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              PRIMARY_FONT),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.link,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            "Dokumentasi hari ini",
                                            style: TextStyle(
                                              fontFamily: PRIMARY_FONT,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: PRIMARY_COLOR,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                          ),
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
              onLongPress: () {
                var reference = docs[index].reference;
                var titleController = TextEditingController(
                  text: data["title"] ?? '',
                );
                var descriptionController = TextEditingController(
                  text: data["description"] ?? '',
                );
                var linkController = TextEditingController(
                  text: data["link"] ?? '',
                );
                DateTime selectedDate =
                    (data["time"] as Timestamp?)?.toDate() ?? DateTime.now();

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter dialogSetState) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          content: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Heading1(
                                      color: PRIMARY_COLOR,
                                      text: "Edit Wishlist",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  PrimaryTextField(
                                    controller: titleController,
                                    hintText: "Title",
                                    maxLength: 30,
                                    onChanged: (value) {},
                                  ),
                                  SizedBox(height: 10),
                                  PrimaryTextField(
                                    controller: descriptionController,
                                    maxLength: 50,
                                    hintText: "Description",
                                    onChanged: (value) {},
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: PRIMARY_COLOR,
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        dialogSetState(() {
                                          selectedDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: PRIMARY_COLOR),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('dd MMMM yyyy')
                                                .format(selectedDate),
                                            style: TextStyle(
                                              fontFamily: PRIMARY_FONT,
                                              color: PRIMARY_COLOR,
                                            ),
                                          ),
                                          Icon(Icons.calendar_today,
                                              color: PRIMARY_COLOR),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  PrimaryTextField(
                                    controller: linkController,
                                    hintText: "Link dokumentasi - Opsional",
                                    maxLine: null,
                                    onChanged: (value) {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                Map<String, dynamic> updateData = {
                                  "title": titleController.text,
                                  "description": descriptionController.text,
                                  "time": Timestamp.fromDate(selectedDate),
                                };
                                if (linkController.text.trim().isNotEmpty) {
                                  updateData["link"] =
                                      linkController.text.trim();
                                } else {
                                  updateData["link"] = FieldValue.delete();
                                }
                                await reference.update(updateData);
                                Navigator.pop(context);
                                Navigator.pop(
                                    context); // Close bottom sheet too
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
                );
              },
              child: Card(
                color: Colors.white,
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
        child: Hero(
          tag: "buktinyata",
          child: PhotoView(
            imageProvider: imageUrl.startsWith("data:image")
                ? MemoryImage(base64Decode(imageUrl.split(",").last))
                : NetworkImage(imageUrl),
            loadingBuilder: (context, event) => MyCircularProgressIndicator(),
            backgroundDecoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenVideo extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideo({required this.videoUrl, super.key});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
            _isBuffering = _controller!.value.isBuffering;
          });
        }
      });
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {
      _isPlaying = _controller!.value.isPlaying;
    });
  }

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
        child: _isInitialized && _controller != null
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    if (_showControls)
                      Container(
                        color: Colors.white.withOpacity(0.9),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isBuffering)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                PRIMARY_COLOR),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Buffering...',
                                      style: TextStyle(
                                        color: PRIMARY_COLOR,
                                        fontSize: 12,
                                        fontFamily: PRIMARY_FONT,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: PRIMARY_COLOR,
                                size: 64,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: VideoProgressIndicator(
                                    _controller!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: PRIMARY_COLOR,
                                      bufferedColor: Colors.grey,
                                      backgroundColor: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                              style: TextStyle(
                                color: PRIMARY_COLOR,
                                fontSize: 14,
                                fontFamily: PRIMARY_FONT,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isBuffering && !_showControls)
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      PRIMARY_COLOR),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Buffering...',
                                style: TextStyle(
                                  color: PRIMARY_COLOR,
                                  fontSize: 12,
                                  fontFamily: PRIMARY_FONT,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Container(
                color: Colors.white,
                child: Center(
                  child: MyCircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
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

bool _isPhotoFormat(String url) {
  final extension = url.toLowerCase().split('.').last;

  // List of video formats
  const videoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];

  // Return true if it's NOT a video format (i.e., it's a photo)
  return !videoFormats.contains(extension);
}

/// Track which documents are being converted to prevent duplicate conversions
final Set<String> _convertingDocs = {};

/// Convert Firebase image to base64 and update Firestore
/// Compresses image if size exceeds 1MB
Future<void> _convertImageToBase64AndUpdate(
    String docId, String imagePath) async {
  // Validate inputs
  if (docId.isEmpty || imagePath.isEmpty) return;

  // Skip if already base64
  if (imagePath.startsWith("data:image")) return;

  // Prevent duplicate conversions
  if (_convertingDocs.contains(docId)) return;
  _convertingDocs.add(docId);

  try {
    // Get download URL
    final ref = FirebaseStorage.instance.refFromURL(imageUrl + imagePath);
    final url = await ref.getDownloadURL();

    // Download image bytes using HttpClient
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await _consolidateHttpResponse(response);

    // Detect MIME type from extension
    final extension = imagePath.toLowerCase().split('.').last;
    String mimeType = 'image/jpeg';
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }

    Uint8List finalBytes = bytes;

    // Always compress to ensure it fits in Firestore (max ~1MB doc)
    // Target 500KB to leave room for base64 overhead and other fields
    const maxSize = 500 * 1024; // 500KB
    if (bytes.length > maxSize || bytes.length > 100 * 1024) {
      // Compress if > 100KB
      finalBytes = await _compressImage(bytes, maxSize);
      mimeType = 'image/jpeg'; // Compressed images are always JPEG
    }

    // Convert to base64
    final base64String = 'data:$mimeType;base64,${base64Encode(finalBytes)}';

    // Final size check (Firestore max document size is ~1MB)
    if (base64String.length > 1000000) {
      print('Image still too large after compression: ${base64String.length}');
      _convertingDocs.remove(docId);
      return;
    }

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('wishlist')
        .doc(docId)
        .update({'picture': base64String});

    print('Successfully converted image to base64 for doc: $docId');
  } catch (e) {
    print('Error converting image to base64: $e');
  } finally {
    _convertingDocs.remove(docId);
  }
}

/// Compress image to fit within maxSize bytes
/// Target size accounts for base64 overhead (~33% increase)
Future<Uint8List> _compressImage(Uint8List bytes, int maxSize) async {
  // Decode the image
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return bytes;

  // Target raw bytes size (base64 adds ~33% overhead)
  // So for 700KB base64, we need ~525KB raw bytes
  int targetSize = (maxSize * 0.7).toInt();

  // First, resize if image is very large (max 1200px on longest side)
  const int maxDimension = 1200;
  if (image.width > maxDimension || image.height > maxDimension) {
    if (image.width > image.height) {
      image = img.copyResize(image, width: maxDimension);
    } else {
      image = img.copyResize(image, height: maxDimension);
    }
  }

  int quality = 80;
  Uint8List compressed =
      Uint8List.fromList(img.encodeJpg(image, quality: quality));

  // Progressively reduce quality until size is acceptable
  while (compressed.length > targetSize && quality > 20) {
    quality -= 5;
    compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  // If still too large, resize the image further
  if (compressed.length > targetSize) {
    int maxDim = 1000;
    while (compressed.length > targetSize && maxDim >= 300) {
      img.Image resized;
      if (image.width > image.height) {
        resized = img.copyResize(image, width: maxDim);
      } else {
        resized = img.copyResize(image, height: maxDim);
      }
      // Try with current quality first
      compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

      // If still too large, reduce quality for this size
      int q = quality;
      while (compressed.length > targetSize && q > 20) {
        q -= 10;
        compressed = Uint8List.fromList(img.encodeJpg(resized, quality: q));
      }

      maxDim -= 200;
    }
  }

  print(
      'Compressed image: ${compressed.length} bytes (target: $targetSize bytes)');
  return compressed;
}

/// Consolidate HTTP response bytes
Future<Uint8List> _consolidateHttpResponse(HttpClientResponse response) async {
  final List<List<int>> chunks = [];
  await for (var chunk in response) {
    chunks.add(chunk);
  }
  final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
  final result = Uint8List(totalLength);
  int offset = 0;
  for (var chunk in chunks) {
    result.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }
  return result;
}

bool _isVideoFormat(String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  const videoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];
  return videoFormats.contains(extension);
}

Widget _buildFilePreview(PlatformFile file) {
  if (file.path == null) {
    return Icon(Icons.error, color: Colors.red);
  }

  final filePath = File(file.path!);

  if (_isVideoFormat(file.name)) {
    return _VideoPreviewWidget(filePath: filePath);
  } else {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        filePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class _VideoPreviewWidget extends StatefulWidget {
  final File filePath;

  const _VideoPreviewWidget({required this.filePath});

  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.filePath);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video preview: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: MyCircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
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
  double get maxExtent => 60;
  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
