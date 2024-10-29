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
                return GestureDetector(
                  onLongPress: () {
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => AlertDialog(
                    //     actions: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           resetWallet(
                    //             wallet: widget.wallet,
                    //             snapshot: snapshot,
                    //             selectedWallet: dataWallet["name"],
                    //           );
                    //         },
                    //         child: Text("Reset"),
                    //       ),
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           updateAmount(selectedWallet: dataWallet["name"], selectedType: selectedType, totalAmount: totalAmount, snapshot: snapshot, wallet: wallet)
                    //         },
                    //         child: Text("Syudah"),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                  child: Container(
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
                            Text(formatToRupiah(dataWallet["amount"]),
                                style: myTextStyle()),
                          ],
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Icon(
                            Icons.settings,
                          ),
                        ),
                      ],
                    ),
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
                    onPressed: () {
                      widget.wallet.doc(walletController.value.text).set({
                        "name": walletController.value.text,
                        "amount":
                            convertRupiahToInt(amountController.value.text),
                      });
                      Navigator.pop(context);
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
