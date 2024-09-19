import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebasePicture extends StatelessWidget {
  FirebasePicture({
    super.key,
    required this.image,
    required this.boxFit,
  });
  final String image;
  final BoxFit boxFit;

  String imageUrl = 'gs://todo-today-74b74.appspot.com/wishlist/';

  Future<String> getImage(String image) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl + image);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImage(image),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(
            snapshot.data!,
            fit: boxFit,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
