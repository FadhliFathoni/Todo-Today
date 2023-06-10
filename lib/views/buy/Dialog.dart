import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/OfflineOnlineSwitch.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/ParagraphText.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/Component/CircularButton.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/views/homepage/Home.dart';

class dialog {
  Positioned dialogAdd(
      BuildContext context,
      String? name,
      PlatformFile? pickedFile,
      String fileName,
      CollectionReference<Object?>? user,
      UploadTask? uploadTask,
      TextEditingController title,
      TextEditingController price,
      bool isOnline,
      TextEditingController link,
      bool isMonthly) {
    return Positioned(
      bottom: 60,
      right: 30,
      child: CircularButton(
        color: PRIMARY_COLOR,
        icon: Icons.add,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setstate) {
                  Future<void> selectFile() async {
                    final result = await FilePicker.platform.pickFiles();
                    setstate(
                      () {
                        pickedFile = result?.files.first;
                        fileName = pickedFile!.name;
                      },
                    );
                  }

                  Future uploadFile() async {
                    final path = '$name/${pickedFile!.name}';
                    final file = File(pickedFile!.path!);

                    final ref = FirebaseStorage.instance.ref().child(path);
                    uploadTask = ref.putFile(file);

                    final snapshot = await uploadTask!.whenComplete(() {});

                    final urlDownload = await snapshot.ref.getDownloadURL();
                    print("Download link ${urlDownload}");
                  }

                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content: SingleChildScrollView(
                      child: Container(
                        color: Colors.white,
                        // height: height(context) * 5 / 10,
                        // width: width(context) * 8 / 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Heading1(
                                text: "Add",
                                color: PRIMARY_COLOR,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    selectFile();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              offset: Offset(3, 3),
                                              blurRadius: 10),
                                        ],
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    width: 64,
                                    height: 64,
                                    margin: EdgeInsets.all(12),
                                    child: Center(
                                      child: (pickedFile == null)
                                          ? Icon(
                                              Icons.camera_alt_outlined,
                                              color: PRIMARY_COLOR,
                                              size: 32,
                                            )
                                          : Image.file(
                                              File(pickedFile!.path!),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: ParagraphText(
                                    text: fileName,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            PrimaryTextField(
                              controller: title,
                              maxLength: 50,
                              hintText: "Title",
                              onChanged: (value) {},
                            ),
                            PrimaryTextField(
                              controller: price,
                              maxLength: 50,
                              hintText: "Price",
                              onChanged: (value) {},
                            ),
                            Visibility(
                              visible: isOnline,
                              child: PrimaryTextField(
                                controller: link,
                                maxLength: 1000,
                                hintText: "Link",
                                onChanged: (value) {},
                              ),
                            ),
                            Row(
                              children: [
                                MyCheckBox(
                                  value: isMonthly,
                                  onChanged: (value) {
                                    setstate(
                                      () {
                                        isMonthly = !isMonthly;
                                      },
                                    );
                                  },
                                ),
                                ParagraphText(
                                  text: "Monthly",
                                  color: (isMonthly == false)
                                      ? Colors.grey
                                      : PRIMARY_COLOR,
                                )
                              ],
                            ),
                            OfflineOnlineSwitch(
                              isOnline: isOnline,
                              onChanged: (value) {
                                setstate(
                                  () {
                                    isOnline = !isOnline;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        height: 30,
                        width: 81,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: ParagraphText(
                            text: "Cancel",
                            color: PRIMARY_COLOR,
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 81,
                        child: ElevatedButton(
                          onPressed: () {
                            uploadFile();
                            user!.add(
                              {
                                "title": title.text,
                                "price": int.parse(price.text),
                                "monthly": isMonthly,
                                "online": isOnline,
                                "link": link.text,
                                "picture": pickedFile!.name
                              },
                            );
                            Navigator.pop(context);
                          },
                          child: ParagraphText(
                            text: "Add",
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_COLOR,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
