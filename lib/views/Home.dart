import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 7),
          color: BG_COLOR,
          child: ListView.builder(
              itemCount: 5,
              itemBuilder: ((context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      height: 150,
                      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          margin: EdgeInsets.only(top: 24, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Title",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    "Time",
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              Text(
                                "Description...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                width: 81,
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(color: PRIMARY_COLOR),
                                  ),
                                )),
                            Container(
                                width: 81,
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                                  child: Text("Done"),
                                )),
                          ],
                        )
                      ]),
                    ),
                  ),
                );
              }))),
    );
  }
}
