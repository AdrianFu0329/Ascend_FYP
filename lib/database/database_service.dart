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
  Completer<List<Post>> completer = Completer<List<Post>>();
  try {
    DatabaseReference database = FirebaseDatabase.instance.ref().child('posts');
    List<Post> posts = [];

    database.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map?;
      data?.forEach((key, value) async {
        String title = value['title'];
        ImageWithDimension image = await getPostImg(key);
        int likes = value['likes'];
        String user = value['user'];

        Post post = Post(
          title: title,
          image: image,
          likes: likes,
          user: user,
        );
        posts.add(post);
      });
      completer.complete(posts);
    });
  } catch (e) {
    completer.completeError(e);
    Center(child: Text('Error getting posts: $e'));
    return [];
  }
  return completer.future;
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
