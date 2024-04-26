import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Post {
  final String postId;
  final String title;
  final ImageWithDimension image;
  final List<String> likes;
  final String user;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;

  Post({
    required this.postId,
    required this.title,
    required this.image,
    required this.likes,
    required this.user,
    required this.timestamp,
    required this.description,
    required this.coordinates,
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
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    List<Post> posts = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String postId = doc.id;
      String title = doc['title'];
      ImageWithDimension image = await getPostImg(doc.id);
      List<String> likes = List<String>.from(doc['likes']);
      String user = doc['user'];
      Timestamp timestamp = doc['timestamp'];
      String description = doc['description'];
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];

      Map<String, double> coordinates = {
        'latitude': latitude,
        'longitude': longitude,
      };

      Post post = Post(
        postId: postId,
        title: title,
        image: image,
        likes: likes,
        user: user,
        timestamp: timestamp,
        description: description,
        coordinates: coordinates,
      );
      posts.add(post);
    }

    return posts;
  } catch (e) {
    Center(child: Text('Error getting posts: $e'));
    return []; // Return an empty list in case of error
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
