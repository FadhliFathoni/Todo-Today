import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';

TextStyle myTextStyle({double? size, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
    fontSize: size ?? 14,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: color ?? Colors.black,
    fontFamily: PRIMARY_FONT,
  );
}

String formatDateWithShortMonth(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat("d MMM")
      .format(date)
      .toUpperCase(); // Contoh output: "17 Aug"
}

// Fungsi untuk mengambil waktu dari Timestamp (contoh: "17:23")
String formatTimeOnly(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat("HH:mm").format(date); // Contoh output: "17:23"
}

class FinancialTile extends StatelessWidget {
  final DocumentSnapshot<Object?> data;

  FinancialTile({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final dataMap = data.data() as Map<String, dynamic>?;
    final isIncome = dataMap?["type"] == "Pemasukan";
    final colorIndicator = isIncome ? Colors.green : Colors.red;
    final title = dataMap?["title"] ?? dataMap?["type"];
    final totalAmount = formatToRupiah(
      dataMap?["total"] * (isIncome ? 1 : -1),
    );
    final category = dataMap!.containsKey("kategori")
        ? dataMap["kategori"]
        : dataMap["wallet"];
    final date = convertTimestampToIndonesianDate(dataMap["time"])!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: BG_COLOR, shape: BoxShape.circle),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formatDateWithShortMonth(dataMap["time"]),
                        style: myTextStyle(size: 12, color: PRIMARY_COLOR)),
                    Text(formatTimeOnly(dataMap["time"]),
                        style: myTextStyle(size: 12, color: PRIMARY_COLOR))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalAmount,
                    style: myTextStyle(),
                  ),
                  Text(
                    title,
                    style: myTextStyle(),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(date, style: myTextStyle()),
              Text(category, style: myTextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialTile1 extends StatelessWidget {
  final DocumentSnapshot<Object?> data;

  FinancialTile1({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final dataMap = data.data() as Map<String, dynamic>?;
    final isIncome = dataMap?["type"] == "Pemasukan";
    final colorIndicator = isIncome ? Colors.green : Colors.red;
    final title = dataMap?["title"] ?? dataMap?["type"];
    final totalAmount = formatToRupiah(
      dataMap?["total"] * (isIncome ? 1 : -1),
    );
    final category = dataMap!.containsKey("kategori")
        ? dataMap["kategori"]
        : dataMap["wallet"];
    final date = convertTimestampToIndonesianDate(dataMap["time"])!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: BG_COLOR, shape: BoxShape.circle),
                child: Text(formatTimeOnly(dataMap["time"]),
                    style: myTextStyle(
                      size: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(title, style: myTextStyle())],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                totalAmount,
                style: myTextStyle(
                    color: (isIncome) ? Colors.green : Colors.red, size: 16),
              ),
              Text(dataMap["wallet"],
                  style: myTextStyle(fontWeight: FontWeight.normal))
            ],
          ),
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

int convertRupiahToInt(String formattedAmount) {
  String numericString = formattedAmount.replaceAll(RegExp(r'[^0-9]'), '');
  return int.parse(numericString);
}

void updateAmount(
    {required String selectedWallet,
    required String selectedType,
    required int totalAmount,
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    required CollectionReference<Map<String, dynamic>> wallet}) {
  QueryDocumentSnapshot<Map<String, dynamic>>? walletDoc;
  for (var doc in snapshot.data!.docs) {
    var data = doc.data();
    if (data["name"].toString().toLowerCase() == selectedWallet.toLowerCase()) {
      walletDoc = doc;
      break;
    } else if (doc.id.toLowerCase() ==
        selectedWallet.toString().toLowerCase()) {
      walletDoc = doc;
    }
  }
  if (walletDoc != null) {
    int currentAmount = walletDoc["amount"] ?? 0;
    int updatedAmount = 0;

    if (selectedType == "pengeluaran") {
      if (selectedWallet == "kebutuhan") {
        updatedAmount = currentAmount + totalAmount;
        wallet.doc(walletDoc.id).update({
          "amount": updatedAmount,
        });
      } else {
        updatedAmount = currentAmount - totalAmount;
        wallet.doc(walletDoc.id).update({
          "amount": updatedAmount,
        });
      }
    } else {
      if (selectedWallet == "kebutuhan") {
        int currentAmount = walletDoc["max_amount"] ?? 0;
        updatedAmount = currentAmount + totalAmount;
        wallet.doc(walletDoc.id).update({
          "max_amount": updatedAmount,
        });
      } else {
        updatedAmount = currentAmount + totalAmount;
        wallet.doc(walletDoc.id).update({
          "amount": updatedAmount,
        });
      }
    }
  }
}
