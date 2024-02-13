import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Post {
  final String title;
  final ImageWithDimension image;
  final int likes;
  final String user;

  Post({
    required this.title,
    required this.image,
    required this.likes,
    required this.user,
  });
}

class ImageWithDimension {
  final Widget image;
  final double height;
  final double width;

  ImageWithDimension(
      {required this.image, required this.height, required this.width});
}

String generateUniqueId() {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < 20; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}

Future<List<Post>> getPostsFromDatabase() async {
  try {
    DatabaseReference _ref = FirebaseDatabase.instance.ref().child('posts');
    List<Post> posts = [];

    _ref.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map?;
      if (data != null) {
        for (var entry in data.entries) {
          String postId = entry.key;
          Map<String, dynamic> postValue = entry.value;

          String title = postValue['title'];
          ImageWithDimension image = await getPostImg(postId);
          int likes = postValue['likes'];
          String user = postValue['user'];

          Post post = Post(
            title: title,
            image: image,
            likes: likes,
            user: user,
          );
          posts.add(post);
        }
      } else {
        print("No data");
      }
    });
    return posts;
  } catch (e) {
    Center(child: Text('Error getting posts: $e'));
    return [];
  }
}

Future<ImageWithDimension> getPostImg(String path) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child("posts/$path.png");
    String imgDownload = await ref.getDownloadURL();
    Image imageWidget = Image.network(
      imgDownload,
      fit: BoxFit.fitHeight,
    );

    Completer<ImageInfo> completer = Completer<ImageInfo>();
    imageWidget.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info);
        },
      ),
    );

    ImageInfo imageInfo = await completer.future;
    double imageHeight = imageInfo.image.height.toDouble();
    double imageWidth = imageInfo.image.width.toDouble();

    return ImageWithDimension(
      image: imageWidget,
      height: imageHeight,
      width: imageWidth,
    );
  } catch (e) {
    return ImageWithDimension(
      image: Center(child: Text('Error getting image: $e')),
      height: 0,
      width: 0,
    );
  }
}
