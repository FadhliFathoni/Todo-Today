import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class Financialpage extends StatefulWidget {
  Financialpage({super.key, required this.user});
  final String user;
  @override
  State<Financialpage> createState() => _FinancialpageState();
}

class _FinancialpageState extends State<Financialpage> {
  @override
  void initState() {
    super.initState();
    checkIsExist(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    var instance = FirebaseFirestore.instance;
    var collection = instance.collection("finance").doc(widget.user);
    var record = collection.collection("record");
    var wallet = collection.collection("wallet");

    return Scaffold(
      backgroundColor: BG_COLOR,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          record.add({
            "type": "pemasukan",
            "kategori": "jajan",
            "total": 10000,
            "time": DateTime.now(),
          });
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: Column(
          children: [
            StreamBuilder(
              stream: wallet.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                DocumentSnapshot? kebutuhanDoc;
                try {
                  for (var doc in snapshot.data!.docs) {
                    if (doc.id == "kebutuhan") {
                      print("EXIST");
                      kebutuhanDoc = doc;
                      break;
                    }
                  }
                } catch (e) {
                  print("Error: $e");
                }
                if (kebutuhanDoc == null) {
                  return Center(child: Text("Data not found"));
                }
                var data = kebutuhanDoc.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Kebutuhan"),
                                  Text(data["amount"].toString()),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text("Dana Darurat")],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Kebutuhan"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Terpakai"), Text("/"), Text("Batas")],
                  )
                ],
              ),
            ),
            StreamBuilder(
                stream: record.snapshots(),
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
                            "Belum ada catatan nihhh",
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
                  return Container();
                })
          ],
        ),
      ),
    );
  }
}

void checkIsExist(String user) async {
  var wallet = FirebaseFirestore.instance
      .collection("finance")
      .doc(user)
      .collection("wallet");

  var tabunganDoc = await wallet.doc("tabungan").get();
  if (!tabunganDoc.exists) {
    wallet.doc("tabungan").set({
      "name": "Tabungan",
      "amount": 0,
    });
  }

  var danaDaruratDoc = await wallet.doc("dana_darurat").get();
  if (!danaDaruratDoc.exists) {
    wallet.doc("dana_darurat").set({
      "name": "Tabungan",
      "amount": 0,
    });
  }

  var kebutuhanDoc = await wallet.doc("kebutuhan").get();
  if (!kebutuhanDoc.exists) {
    wallet.doc("kebutuhan").set({
      "name": "Tabungan",
      "amount": 0,
    });
  }
}
