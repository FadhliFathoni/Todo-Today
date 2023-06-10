import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebasePicture extends StatelessWidget {
  FirebasePicture({
    super.key,
    required this.listData,
    required this.index,
    required this.boxFit,
  });

  final List listData;
  final int index;
  final BoxFit boxFit;

  String imageUrl = 'gs://todo-today-74b74.appspot.com/Fadhli/';

  Future<String> getImage(String image) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl + image);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw "No image";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImage(listData[index]['picture']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(
            snapshot.data!,
            fit: boxFit,
          );
        } else if (snapshot.hasError) {
          return Text("There's an error");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
