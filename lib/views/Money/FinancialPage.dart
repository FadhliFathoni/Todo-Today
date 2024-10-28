import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';

class Financialpage extends StatefulWidget {
  Financialpage({super.key, required this.user});
  final String user;
  @override
  State<Financialpage> createState() => _FinancialpageState();
}

class _FinancialpageState extends State<Financialpage> {
  String? selectedKategori; // Variabel state untuk kategori yang dipilih
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    checkIsExist(widget.user);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var instance = FirebaseFirestore.instance;
    var collection = instance.collection("finance").doc(widget.user);
    var record = collection.collection("record");
    var wallet = collection.collection("wallet");
    var kategori = collection.collection("kategori");

    return Scaffold(
      backgroundColor: BG_COLOR,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedKategori = "Jajan";
          var titleController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Expanded(
                      child: Center(
                    child: Text(
                      "Pengeluaran",
                      style: TextStyle(fontSize: 14),
                    ),
                  )),
                  Expanded(
                      child: Center(
                    child: Text(
                      "Pendapatan",
                      style: TextStyle(fontSize: 14),
                    ),
                  )),
                ],
              ),
              content: StatefulBuilder(builder: (context, dialogSetState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryTextField(
                      controller: titleController,
                      hintText: "Buat apa?",
                      onChanged: (var data) {},
                    ),
                    StreamBuilder(
                      stream: kategori.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        var items = [
                          DropdownMenuItem<String>(
                            value: "tambah_kategori",
                            child: Text("Tambah Kategori"),
                          ),
                          ...snapshot.data!.docs
                              .map<DropdownMenuItem<String>>((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['name'],
                              child: Text(doc['name']),
                            );
                          }).toList()
                        ];
                        return DropdownButton<String>(
                          items: items,
                          value: selectedKategori,
                          onChanged: (value) {
                            dialogSetState(() {
                              selectedKategori = value;
                            });
                            if (selectedKategori == "tambah_kategori") {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Tambah Kategori bro"),
                                ),
                              );
                            }
                          },
                          hint: Text("Pilih Kategori"),
                        );
                      },
                    ),
                    Text(
                      "Pilih Waktu: ${selectedTime != null ? selectedTime!.format(context) : 'Belum Dipilih'}",
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          // Lakukan sesuatu dengan waktu yang dipilih
                          print("Waktu terpilih: ${time.format(context)}");
                        }
                      },
                      child: Text("Pilih Waktu"),
                    ),
                  ],
                );
              }),
            ),
          );
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
                DocumentSnapshot? tabunganDoc;
                DocumentSnapshot? danaDaruratDoc;
                try {
                  for (var doc in snapshot.data!.docs) {
                    if (doc.id == "tabungan") {
                      print("EXIST");
                      tabunganDoc = doc;
                      break;
                    }
                  }
                  for (var doc in snapshot.data!.docs) {
                    if (doc.id == "dana_darurat") {
                      print("EXIST");
                      danaDaruratDoc = doc;
                      break;
                    }
                  }
                } catch (e) {
                  print("Error: $e");
                }
                if (tabunganDoc == null || danaDaruratDoc == null) {
                  return Center(child: Text("Data not found"));
                }
                var dataTabungan = tabunganDoc.data() as Map<String, dynamic>;
                var dataDanaDarurat =
                    danaDaruratDoc.data() as Map<String, dynamic>;
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
                                  Text(formatToRupiah(dataTabungan["amount"])),
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
                                children: [
                                  Text("Dana Darurat"),
                                  Text(
                                      formatToRupiah(dataDanaDarurat["amount"]))
                                ],
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
              margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: StreamBuilder(
                  stream: wallet.snapshots(),
                  builder: (context, snapshot) {
                    DocumentSnapshot? kebutuhanDoc;
                    try {
                      for (var doc in snapshot.data!.docs) {
                        if (doc.id == "kebutuhan") {
                          kebutuhanDoc = doc;
                        }
                      }
                    } catch (e) {}
                    if (kebutuhanDoc == null) {
                      return Container();
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Kebutuhan"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(formatToRupiah(kebutuhanDoc["amount"])),
                            Text("/"),
                            Text(formatToRupiah(kebutuhanDoc["max_amount"]))
                          ],
                        )
                      ],
                    );
                  }),
            ),
            StreamBuilder(
                stream: record.orderBy("time", descending: true).snapshots(),
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
                  Map<String, List<DocumentSnapshot>> groupedData = {};

                  for (var doc in docs) {
                    var date = (doc["time"] as Timestamp).toDate();
                    var monthYear = DateFormat("MMMM yyyy").format(date);
                    if (!groupedData.containsKey(monthYear)) {
                      groupedData[monthYear] = [];
                    }
                    groupedData[monthYear]!.add(doc);
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                      height: 12,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: groupedData.keys.length,
                    itemBuilder: (context, index) {
                      var monthYear = groupedData.keys.elementAt(index);
                      var monthDocs = groupedData[monthYear]!;
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Riwayat"),
                                Text(monthYear),
                              ],
                            ),
                          ),
                          ...monthDocs
                              .map((doc) => FinancialTile(
                                    data: doc,
                                  ))
                              .toList(),
                        ],
                      );
                    },
                  );
                })
          ],
        ),
      ),
    );
  }
}

class FinancialTile extends StatelessWidget {
  FinancialTile({
    required this.data,
    super.key,
  });

  DocumentSnapshot<Object?> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatToRupiah(data["total"])),
                  Text(data["title"])
                ],
              )
            ],
          ),
          Text(convertTimestampToIndonesianDate(data["time"])!)
        ],
      ),
    );
  }
}

void checkIsExist(String user) async {
  var doc = FirebaseFirestore.instance.collection("finance").doc(user);
  var wallet = doc.collection("wallet");
  var kategori = doc.collection("kategori");

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

  var kategoriDoc = await kategori.get();
  if (kategoriDoc.size == 0) {
    kategori.add({
      "name": "Jajan",
      "time": DateTime.now(),
    });
    kategori.add({
      "name": "Belanja Online",
      "time": DateTime.now(),
    });
  }
}

String formatToRupiah(int amount) {
  final formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(amount);
}
