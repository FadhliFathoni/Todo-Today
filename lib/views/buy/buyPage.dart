// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/MoneyText.dart';
import 'package:todo_today/Component/Text/ParagraphText.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/Component/FirebasePicture.dart';
import 'package:todo_today/Component/OkButton.dart';
import 'package:todo_today/views/buy/MyBottomBar.dart';
import 'package:todo_today/views/buy/MyBottomSheet.dart';
import 'package:todo_today/views/buy/Dialog.dart';

class buyPage extends StatefulWidget {
  String user;
  buyPage({super.key, required this.user});

  @override
  State<buyPage> createState() => _buyPageState();
}

class _buyPageState extends State<buyPage> {
  @override
  Widget build(BuildContext context) {
    double height(BuildContext context) => MediaQuery.of(context).size.height;
    double width(BuildContext context) => MediaQuery.of(context).size.width;

    TextEditingController title = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController link = TextEditingController();

    PlatformFile? pickedFile;
    String fileName = "File Name";

    UploadTask? uploadTask;

    bool isOnline = false;
    bool isMonthly = false;

    String name = widget.user;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(name + " Spend");

    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SOMETHING TO SPEND",
          style: TextStyle(
              color: Colors.black,
              fontFamily: PRIMARY_FONT,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(
        color: BG_COLOR,
        height: height(context),
        width: width(context),
        child: Stack(
          children: [
            StreamBuilder(
              stream: user.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var listData = [];
                  for (int x = 0; x < snapshot.data!.size; x++) {
                    var dataId =
                        snapshot.data?.docs[x].data() as Map<String, dynamic>;
                    listData.add(dataId);
                  }
                  return ListView.builder(
                    itemCount: listData.length,
                    itemBuilder: (context, x) {
                      return Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          left: 25,
                          right: 25,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        width: width(context) * 8.5 / 10,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: FirebasePicture(
                                      listData: listData,
                                      index: x,
                                      boxFit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Heading1(
                                            text: listData[x]['title'],
                                            color: PRIMARY_COLOR),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: ParagraphText(
                                            text:
                                                MoneyText(listData[x]['price']),
                                            color:
                                                PRIMARY_COLOR.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: OkButton(
                                  onPressed: () {
                                    MyBottomSheet().SpendBottomSheet(context,
                                        height, width, listData, x, MoneyText);
                                  },
                                  text: "Detail"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("There's an error"),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            dialog().dialogAdd(context, name, pickedFile, fileName, user,
                uploadTask, title, price, isOnline, link, isMonthly),
            MyBottomBar(user: user)
          ],
        ),
      ),
    );
  }
}


