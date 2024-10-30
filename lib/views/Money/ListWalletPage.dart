import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

class Listwalletpage extends StatefulWidget {
  const Listwalletpage({super.key, required this.wallet});
  final CollectionReference<Map<String, dynamic>> wallet;

  @override
  State<Listwalletpage> createState() => _ListwalletpageState();
}

class _ListwalletpageState extends State<Listwalletpage> {
  bool tabunganExist = false;
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
          "List Wallet",
          style: myTextStyle(color: PRIMARY_COLOR, size: 18),
        ),
      ),
      body: StreamBuilder(
        stream: widget.wallet.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container();
          }
          var data = snapshot.data!.docs;
          return Container(
            margin: EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                var dataWallet = data[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dataWallet["name"], style: myTextStyle()),
                          Text(
                              (dataWallet["name"] != "Kebutuhan")
                                  ? formatToRupiah(dataWallet["amount"])
                                  : formatToRupiah(
                                      dataWallet["maxAmount"] ??
                                          0 - dataWallet["amount"],
                                    ),
                              style: myTextStyle()),
                        ],
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.settings),
                          onSelected: (value) {
                            if (value == "edit") {
                              var nameController = TextEditingController(
                                  text: dataWallet["name"]);
                              var amountController = TextEditingController();

                              // Pastikan `amount` adalah angka, bersihkan dari karakter non-numerik terlebih dahulu
                              int amount = int.tryParse(
                                    dataWallet["amount"]
                                        .toString()
                                        .replaceAll(RegExp(r'[^0-9]'), ''),
                                  ) ??
                                  0;

                              // Set nilai awal `amountController` dalam format rupiah
                              amountController.value = TextEditingValue(
                                text: formatToRupiah(amount),
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                      offset: formatToRupiah(amount).length),
                                ),
                              );

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Center(
                                    child: Text(
                                      "Edit Wallet",
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
                                        hintText: dataWallet["name"],
                                        onChanged: (data) {},
                                      ),
                                      PrimaryTextField(
                                        textInputType: TextInputType.number,
                                        controller: amountController,
                                        hintText: formatToRupiah(
                                            dataWallet["amount"]),
                                        onChanged: (data) {
                                          int amount = int.tryParse(
                                                data.replaceAll(
                                                    RegExp(r'[^0-9]'), ''),
                                              ) ??
                                              0;
                                          amountController.value =
                                              TextEditingValue(
                                            text: formatToRupiah(amount),
                                            selection:
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: formatToRupiah(amount)
                                                      .length),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white),
                                      onPressed: () {
                                        resetWallet(
                                          wallet: widget.wallet,
                                          snapshot: snapshot,
                                          selectedWallet: dataWallet["name"],
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Reset",
                                        style:
                                            myTextStyle(color: PRIMARY_COLOR),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: PRIMARY_COLOR,
                                      ),
                                      onPressed: () {
                                        String walletId = getWalletDocId(
                                          snapshot: snapshot,
                                          dataWallet: dataWallet,
                                        );
                                        widget.wallet.doc(walletId).set({
                                          "name": nameController.value.text,
                                          "amount": convertRupiahToInt(
                                              amountController.value.text),
                                          "time": DateTime.now(),
                                        });
                                        Navigator.pop(context);
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
                                        "Ketik dulu : " + dataWallet["name"],
                                        style: myTextStyle(),
                                      ),
                                      PrimaryTextField(
                                        controller: nameController,
                                        hintText: dataWallet["name"],
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
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          if (nameController.value.text ==
                                              dataWallet["name"]) {
                                            String idWallet = getWalletDocId(
                                              snapshot: snapshot,
                                              dataWallet: dataWallet,
                                            );

                                            widget.wallet
                                                .doc(idWallet)
                                                .delete();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                          "Hapus ajah",
                                          style: myTextStyle(
                                              color:
                                                  Colors.red.withOpacity(0.7)),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              enabled: (dataWallet["name"] != "Kebutuhan" &&
                                  dataWallet["name"] != "Dana Darurat" &&
                                  dataWallet["name"] != "Tabungan"),
                              value: "delete",
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.account_balance_wallet_outlined,
          color: PRIMARY_COLOR,
        ),
        backgroundColor: Colors.white,
        onPressed: () {
          var walletController = TextEditingController();
          var amountController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) =>
                StatefulBuilder(builder: (context, dialogSetState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    "Tambah Wallet",
                    style: myTextStyle(size: 16, color: PRIMARY_COLOR),
                  ),
                ),
                content: StatefulBuilder(
                  // Tambahkan StatefulBuilder hanya di bagian content ini
                  builder: (context, dialogSetState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrimaryTextField(
                          controller: walletController,
                          hintText: "Wallet apah?",
                          onChanged: (data) {},
                        ),
                        Visibility(
                          visible: tabunganExist,
                          child: PrimaryTextField(
                            controller:
                                amountController, // Pastikan menggunakan amountController
                            hintText: "Berapah?",
                            textInputType: TextInputType.number,
                            onChanged: (var data) {
                              int amount = int.tryParse(
                                      data.replaceAll(RegExp(r'[^0-9]'), '')) ??
                                  0;
                              amountController.value = TextEditingValue(
                                text: formatToRupiah(amount),
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    offset: formatToRupiah(amount).length,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Dah ada tabungan?",
                              style: myTextStyle(),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Switch(
                              value: tabunganExist,
                              activeColor: BG_COLOR,
                              inactiveThumbColor: PRIMARY_COLOR,
                              inactiveTrackColor:
                                  PRIMARY_COLOR.withOpacity(0.5),
                              onChanged: (data) {
                                dialogSetState(() {
                                  tabunganExist = data;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    style: myElevatedButtonStyle(),
                    onPressed: () {
                      if (walletController.value.text.isNotEmpty) {
                        widget.wallet.doc(walletController.value.text).set({
                          "name": walletController.value.text,
                          "amount": (tabunganExist)
                              ? convertRupiahToInt(amountController.value.text)
                              : 0,
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
              );
            }),
          );
        },
      ),
    );
  }
}

String getWalletDocId(
    {required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    required QueryDocumentSnapshot<Map<String, dynamic>> dataWallet}) {
  QueryDocumentSnapshot<Map<String, dynamic>>? walletDoc;
  for (var doc in snapshot.data!.docs) {
    if (doc.data()["name"] == dataWallet["name"]) {
      walletDoc = doc;
      break;
    }
  }
  return walletDoc!.id;
}
