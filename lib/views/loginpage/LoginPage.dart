import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<String> person = ["Fadhli", "Rchyla"];
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  double width(BuildContext context) => MediaQuery.of(context).size.width;

  void checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') == null) {
      print("ini null temanku");
    } else {
      // await initializeService();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return MainPage(user: prefs.getString('user')!);
      }));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color.fromARGB(255, 139, 139, 139),
          height: height(context),
          width: width(context),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: width(context) * 0.7,
                  height: height(context) * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      margin: EdgeInsets.only(top: 14),
                      child: Text(
                        "Account",
                        style: TextStyle(fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ListView.builder(
                        itemCount: person.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Center(
                              child: TextButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              String name = person[index];
                              // await initializeService();
                              prefs.remove('user');
                              prefs.setString('user', name);
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) {
                                  return MainPage(user: name);
                                },
                              ));
                            },
                            child: Text(
                              person[index],
                              style: TextStyle(fontFamily: "DeliciousHandrawn", fontSize: 16),
                            ),
                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                          ));
                        })
                  ]),
                ),
              )
            ],
          )),
    );
  }
}
