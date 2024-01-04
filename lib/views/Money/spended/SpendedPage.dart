import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:todo_today/Component/OkButton.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/Heading3.dart';
import 'package:todo_today/Component/Text/MoneyText.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/spended/CardSpended.dart';
import 'package:todo_today/views/Money/spended/SpendedFAB.dart';

class SpendedPage extends StatefulWidget {
  const SpendedPage({super.key, required this.user});
  final String user;
  @override
  State<SpendedPage> createState() => _SpendedPageState();
}

class _SpendedPageState extends State<SpendedPage> {
  DateTime? dateSelected;
  DateTime date = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting();
    super.initState();
  }

  String formatDateTime(DateTime dateTime) {
    final formattedDate =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    var title = TextEditingController();
    var price = TextEditingController();
    String name = widget.user;
    var listData = [];
    List<QueryDocumentSnapshot> listDataNow = [];

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(name + " Spended");
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Heading1(
          text: "Spended Money",
          color: PRIMARY_COLOR,
        ),
      ),
      body: Container(
        color: BG_COLOR,
        width: width(context),
        height: height(context),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(20),
                    height: 100,
                    width: width(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            decrementDate(listData, listDataNow);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: PRIMARY_COLOR,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked == null) {
                                  return;
                                } else if (picked.year >= DateTime.now().year &&
                                    picked.month >= DateTime.now().month &&
                                    picked.day > DateTime.now().day) {
                                  return;
                                } else {
                                  setState(() {
                                    date = picked;
                                  });
                                }
                              },
                              child: Heading1(
                                text: formatDateTime(date),
                                color: PRIMARY_COLOR,
                              ),
                            ),
                            StreamBuilder(
                              stream: user.snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  num total = 0;
                                  for (int x = 0;
                                      x < snapshot.data!.size;
                                      x++) {
                                    Timestamp timestamp =
                                        snapshot.data!.docs[x]['date'];
                                    DateTime dateTime = timestamp.toDate();

                                    if (formatDateTime(dateTime).toString() ==
                                        formatDateTime(date).toString()) {
                                      total += snapshot.data!.docs[x]['price'];
                                    }
                                  }
                                  return Heading3(
                                    text: "-" + MoneyText(total),
                                    color: (total == 0)
                                        ? Colors.green
                                        : Colors.red,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("There's an error");
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            )
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            incrementDate(listData, listDataNow);
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: PRIMARY_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: user.orderBy('date', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        listDataNow.clear();
                        for (int x = 0; x < snapshot.data!.size; x++) {
                          Timestamp timestamp = snapshot.data!.docs[x]['date'];
                          DateTime dateTime = timestamp.toDate();

                          if (formatDateTime(dateTime).toString() ==
                              formatDateTime(date).toString()) {
                            listDataNow.add(snapshot.data!.docs[x]);
                          }
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: listDataNow.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                var title = listDataNow[index]['title'];
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        title: Center(
                                          child:
                                              Heading1(text: "Delete $title?"),
                                        ),
                                        actions: [
                                          OkButton(
                                              onPressed: () {
                                                user
                                                    .doc(listDataNow[index].id)
                                                    .delete();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Heading3(
                                                      text:
                                                          "$title successfully deleted",
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                                Navigator.pop(context);
                                              },
                                              text: "Delete"),
                                        ],
                                      );
                                    });
                              },
                              child: CardSpended(
                                title: listDataNow[index]['title'],
                                price: listDataNow[index]['price'],
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text("There's an error");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
            SpendedFAB(title: title, price: price, user: user, date: date),
          ],
        ),
      ),
    );
  }

  void decrementDate(List<dynamic> listData,
      List<QueryDocumentSnapshot<Object?>> listDataNow) {
    return setState(() {
      listData.clear();
      listDataNow.clear();
      date = date.subtract(Duration(days: 1));
      dateSelected = date;
    });
  }

  void incrementDate(List<dynamic> listData,
      List<QueryDocumentSnapshot<Object?>> listDataNow) {
    if (date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day >= DateTime.now().day) {
      return;
    } else {
      setState(() {
        listData.clear();
        listDataNow.clear();
        date = date.subtract(Duration(days: -1));
        dateSelected = date;
      });
    }
  }
}
