import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/buy/BuyPage.dart';
import 'package:todo_today/views/Money/spended/SpendedPage.dart';

class MainMoney extends StatefulWidget {
  const MainMoney({super.key, required this.user});

  final String user;

  @override
  State<MainMoney> createState() => _MainMoneyState();
}

class _MainMoneyState extends State<MainMoney> {
  int currentIndex = 0;
  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return BuyPage(
          user: widget.user,
        );
      case 1:
        return SpendedPage(
          user: widget.user,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          unselectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          selectedItemColor: PRIMARY_COLOR,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.money_off), label: ""),
          ]),
    );
  }
}
