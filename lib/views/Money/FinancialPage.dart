import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_today/Component/FormattedDateTime.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/ListWalletPage.dart';
import 'package:todo_today/views/Money/ListCategoryPage.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

class Financialpage extends StatefulWidget {
  Financialpage({super.key, required this.user});
  final String user;
  @override
  State<Financialpage> createState() => _FinancialpageState();
}

class _FinancialpageState extends State<Financialpage> {
  String? selectedKategori;
  String selectedType = "pengeluaran";
  String? selectedWallet;
  String tabunganDocId = "Tabungan";
  String danaDaruratDocId = "Dana Darurat";
  String kebutuhanDocId = "Kebutuhan";
  @override
  void initState() {
    super.initState();
    checkIsExist(widget.user);
  }

  DateTime selectedDateTime = DateTime.now();

  Future<void> selectDateTime(BuildContext context,
      {required void Function(void Function()) dialogSetState,
      required DateTime dateInput}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateInput,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dateInput),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: PRIMARY_COLOR, // Warna utama (misal, warna tombol OK)
                onPrimary: Colors.white, // Warna teks di atas primary
                onSurface: Colors.black, // Warna teks di atas background
              ),
              dialogBackgroundColor: Colors.white, // Warna background picker
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: PRIMARY_COLOR, // Warna tombol Cancel
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        dialogSetState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () {
          DateTime dateInput = DateTime.now();
          selectedKategori = "Jajan";
          var titleController = TextEditingController();
          var totalController = TextEditingController();
          var kategoriController = TextEditingController();
          // var linkController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) =>
                StatefulBuilder(builder: (context, dialogSetState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: Duration(milliseconds: 300),
                        alignment: selectedType == "pengeluaran"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          decoration: BoxDecoration(
                            color: selectedType == "pengeluaran"
                                ? BG_COLOR
                                : BG_COLOR,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                dialogSetState(() {
                                  selectedType = "pengeluaran";
                                });
                              },
                              child: Center(
                                child: Text(
                                  "Pengeluaran",
                                  style: myTextStyle(
                                    size: 14,
                                    color: selectedType == "pengeluaran"
                                        ? Colors.white
                                        : BG_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                dialogSetState(() {
                                  selectedType = "pemasukan";
                                });
                              },
                              child: Center(
                                child: Text(
                                  "Pemasukan",
                                  style: myTextStyle(
                                    size: 14,
                                    color: selectedType == "pemasukan"
                                        ? Colors.white
                                        : BG_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                content: AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        controller: titleController,
                        hintText: (selectedType == "pengeluaran")
                            ? "Buat apa?"
                            : "Apah?",
                        onChanged: (var data) {},
                      ),
                      PrimaryTextField(
                        controller: totalController,
                        hintText: "Berapa?",
                        textInputType: TextInputType.number,
                        onChanged: (var data) {
                          int amount = int.tryParse(
                                  data.replaceAll(RegExp(r'[^0-9]'), '')) ??
                              0;
                          totalController.value = TextEditingValue(
                            text: formatToRupiah(amount),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                offset: formatToRupiah(amount).length,
                              ),
                            ),
                          );
                        },
                      ),
                      // Visibility(
                      //   visible: (selectedKategori == "Belanja Online"),
                      //   child: PrimaryTextField(
                      //     controller: linkController,
                      //     hintText: "Ada linknya ngga? (Opsional)",
                      //     onChanged: (data) {},
                      //   ),
                      // ),
                      Visibility(
                        visible: (selectedType == "pengeluaran"),
                        child: StreamBuilder(
                          stream: kategori.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            var items = [
                              // DropdownMenuItem<String>(
                              //   value: "tambah_kategori",
                              //   child: Text(
                              //     "Tambah Kategori",
                              //     style: myTextStyle(color: PRIMARY_COLOR),
                              //   ),
                              // ),
                              ...snapshot.data!.docs
                                  .map<DropdownMenuItem<String>>((doc) {
                                return DropdownMenuItem<String>(
                                  value: doc['name'],
                                  child: Text(
                                    doc['name'],
                                    style: myTextStyle(),
                                  ),
                                );
                              }).toList()
                            ];
                            return Row(
                              children: [
                                DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  style: myTextStyle(),
                                  iconEnabledColor: PRIMARY_COLOR,
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
                                          backgroundColor: Colors.white,
                                          title: Center(
                                            child: Text(
                                              "Nambahin Kategori",
                                              style: myTextStyle(
                                                color: PRIMARY_COLOR,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          content: PrimaryTextField(
                                            controller: kategoriController,
                                            hintText: "Kategori apah",
                                            onChanged: (data) {},
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                kategori.add({
                                                  "name": kategoriController
                                                      .value.text,
                                                  "time": DateTime.now(),
                                                });
                                                dialogSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Syudah",
                                                style: myTextStyle(
                                                  color: PRIMARY_COLOR,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  hint: Text(
                                    "Pilih Kategori",
                                    style: myTextStyle(),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: PRIMARY_COLOR,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListCategoryPage(
                                          kategori: kategori,
                                          user: widget.user,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: "Kelola Kategori",
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      StreamBuilder(
                        stream: wallet.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          var walletItems = snapshot.data!.docs
                              .map<DropdownMenuItem<String>>((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                doc['name'],
                                style: myTextStyle(),
                              ),
                            );
                          }).toList();
                          return DropdownButton<String>(
                            dropdownColor: Colors.white,
                            iconEnabledColor: PRIMARY_COLOR,
                            style: myTextStyle(),
                            items: walletItems,
                            value: selectedWallet,
                            onChanged: (value) {
                              dialogSetState(() {
                                selectedWallet = value;
                              });
                            },
                            hint: Text(
                              "Pilih Wallet",
                              style: myTextStyle(),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                          onTap: () async {
                            selectDateTime(
                              context,
                              dialogSetState: dialogSetState,
                              dateInput: dateInput,
                            );
                          },
                          child: Text(
                            formatDateWithTime(selectedDateTime),
                            style: myTextStyle(),
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: StreamBuilder(
                            stream: wallet.snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: PRIMARY_COLOR,
                                ),
                                onPressed: () {
                                  int totalAmount = 0;
                                  if (selectedType == "pengeluaran" &&
                                      titleController.value.text.isNotEmpty &&
                                      selectedKategori != null &&
                                      totalController.value.text.isNotEmpty &&
                                      selectedWallet != null) {
                                    totalAmount = convertRupiahToInt(
                                        totalController.value.text);
                                    record.add({
                                      "title": titleController.value.text,
                                      "kategori": selectedKategori,
                                      "time": selectedDateTime,
                                      "total": totalAmount,
                                      "type": "Pengeluaran",
                                      "wallet": selectedWallet,
                                      // "link": (selectedKategori ==
                                      //         "Belanja Online")
                                      //     ? linkController.value.text
                                      //     : "",
                                    });
                                  } else if (selectedType == "pemasukan" &&
                                      totalController.value.text.isNotEmpty) {
                                    totalAmount = convertRupiahToInt(
                                        totalController.value.text);
                                    record.add({
                                      "title": titleController.value.text,
                                      "time": selectedDateTime,
                                      "total": totalAmount,
                                      "type": "Pemasukan",
                                      "wallet": selectedWallet,
                                    });
                                  }
                                  if (totalAmount != 0) {
                                    updateAmount(
                                      selectedWallet:
                                          selectedWallet!.toLowerCase(),
                                      selectedType: selectedType.toLowerCase(),
                                      totalAmount: totalAmount,
                                      snapshot: snapshot,
                                      wallet: wallet,
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Syudah",
                                  style: myTextStyle(color: PRIMARY_COLOR),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
        child: Icon(
          Icons.add,
          color: PRIMARY_COLOR,
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                stream: wallet.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Container());
                  }
                  DocumentSnapshot? tabunganDoc;
                  DocumentSnapshot? danaDaruratDoc;
                  try {
                    for (var doc in snapshot.data!.docs) {
                      if (doc.id == tabunganDocId) {
                        print("EXIST");
                        tabunganDoc = doc;
                        break;
                      }
                    }
                    for (var doc in snapshot.data!.docs) {
                      if (doc.id == danaDaruratDocId) {
                        print("EXIST");
                        danaDaruratDoc = doc;
                        break;
                      }
                    }
                  } catch (e) {
                    print("Error: $e");
                  }
                  if (tabunganDoc == null || danaDaruratDoc == null) {
                    return Center(
                        child: Text(
                      "Data not found",
                      style: myTextStyle(),
                    ));
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
                                    Text(
                                      "Tabungan",
                                      style: myTextStyle(),
                                    ),
                                    Text(
                                      formatToRupiah(dataTabungan["amount"]),
                                      style: myTextStyle(),
                                    ),
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
                                    Text(
                                      "Dana Darurat",
                                      style: myTextStyle(),
                                    ),
                                    Text(
                                      formatToRupiah(dataDanaDarurat["amount"]),
                                      style: myTextStyle(),
                                    )
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
                          if (doc.id == kebutuhanDocId) {
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
                          Text(
                            "Kebutuhan",
                            style: myTextStyle(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatToRupiah(kebutuhanDoc["amount"]),
                                style: myTextStyle(),
                              ),
                              Text(
                                "/",
                                style: myTextStyle(),
                              ),
                              Text(
                                formatToRupiah(kebutuhanDoc["maxAmount"]),
                                style: myTextStyle(),
                              )
                            ],
                          )
                        ],
                      );
                    }),
              ),
              StreamBuilder(
                  stream: record.snapshots(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Listwalletpage(
                              wallet: wallet,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 36,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Dompet lainnya...",
                            style: myTextStyle(),
                          ),
                        ),
                      ),
                    );
                  }),
              StreamBuilder(
                  stream: record.orderBy("time", descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Container());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                        "Error: ${snapshot.error}",
                        style: myTextStyle(),
                      ));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        margin: EdgeInsets.all(50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 50,
                                color: Colors.black.withOpacity(0.15)),
                            SizedBox(height: 16),
                            Text(
                              "Belum ada catatan nihhh",
                              style: myTextStyle(
                                size: 18,
                                color: Colors.black.withOpacity(0.15),
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
                      var dayMonthYear = DateFormat("dd MMMM yyyy")
                          .format(date); // Format per hari
                      if (!groupedData.containsKey(dayMonthYear)) {
                        groupedData[dayMonthYear] = [];
                      }
                      groupedData[dayMonthYear]!.add(doc);
                    }

                    List<Map<String, dynamic>> dailyTotals = [];

                    for (var dayDocs in groupedData.values) {
                      int totalPemasukan = 0;
                      int totalPengeluaran = 0;

                      for (var doc in dayDocs) {
                        if (doc["type"].toString().toLowerCase() ==
                            "pemasukan") {
                          totalPemasukan += doc["total"] as int;
                        } else if (doc["type"].toString().toLowerCase() ==
                            "pengeluaran") {
                          totalPengeluaran += doc["total"] as int;
                        }
                      }

                      var date = (dayDocs.first["time"] as Timestamp).toDate();
                      var formattedDate =
                          DateFormat("dd MMMM yyyy").format(date);
                      var monthYear = DateFormat("MMMM yyyy")
                          .format(date); // Define monthYear here

                      dailyTotals.add({
                        'date': formattedDate,
                        'totalPemasukan': totalPemasukan,
                        'totalPengeluaran': totalPengeluaran,
                        'monthYear': monthYear, // Save monthYear for displaying
                      });
                    }

                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      itemCount: dailyTotals.length,
                      itemBuilder: (context, index) {
                        var dailyTotal = dailyTotals[index];
                        String monthYear = dailyTotal['monthYear'];

                        return Column(
                          children: [
                            if (index == 0 ||
                                dailyTotals[index - 1]['monthYear'] !=
                                    monthYear)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 12),
                                child: Text(
                                  monthYear,
                                  style: myTextStyle(
                                    size: 18,
                                    fontWeight: FontWeight.bold,
                                    color: PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dailyTotal["date"],
                                            style: myTextStyle(size: 16),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                formatToRupiah(dailyTotal[
                                                    'totalPemasukan']),
                                                style: myTextStyle(
                                                    size: 16,
                                                    color: Colors.green),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                formatToRupiah(dailyTotal[
                                                    'totalPengeluaran']),
                                                style: myTextStyle(
                                                    size: 16,
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: groupedData[dailyTotal['date']]!
                                        .map((doc) => FinancialTile1(
                                            data: doc,
                                            record: record,
                                            wallet: wallet))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
