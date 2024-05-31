import 'dart:async';
import 'dart:math';

import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

String generateUniqueId() {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < 20; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}

Stream<QuerySnapshot> getPostsFromDatabase() {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection("posts");

  final postsStream = posts.orderBy('timestamp', descending: true).snapshots();

  return postsStream;
}

Stream<QuerySnapshot> getEventsFromDatabase() {
  final CollectionReference events =
      FirebaseFirestore.instance.collection("events");

  final eventsStream = events.orderBy('date', descending: false).snapshots();

  return eventsStream;
}

Stream<QuerySnapshot> getGroupEventsFromDatabase(String groupId) {
  final CollectionReference events = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('events');

  final eventsStream = events.orderBy('date', descending: false).snapshots();

  return eventsStream;
}

Stream<QuerySnapshot> getGroupsFromDatabase() {
  final CollectionReference events =
      FirebaseFirestore.instance.collection("groups");

  final eventsStream =
      events.orderBy('timestamp', descending: false).snapshots();

  return eventsStream;
}

Stream<QuerySnapshot> getMembersForCurrentGroup(String groupId) {
  final DocumentReference grpRef =
      FirebaseFirestore.instance.collection("groups").doc(groupId);

  final grpStream = grpRef
      .collection('leaderboard')
      .orderBy('dateJoined', descending: false)
      .snapshots();

  return grpStream;
}

Stream<QuerySnapshot> getLeaderboardForCurrentGroup(String groupId) {
  final DocumentReference grpRef =
      FirebaseFirestore.instance.collection("groups").doc(groupId);

  final grpStream = grpRef
      .collection('leaderboard')
      .orderBy('groupEventsJoined', descending: false)
      .snapshots();

  return grpStream;
}

Stream<QuerySnapshot> getPostsForCurrentUser(String currentUserUid) {
  final DocumentReference userRef =
      FirebaseFirestore.instance.collection("users").doc(currentUserUid);

  final postsStream = userRef
      .collection('posts')
      .orderBy('timestamp', descending: true)
      .snapshots();

  return postsStream;
}

Future<Map<String, dynamic>> getEventData(String eventId) async {
  DocumentSnapshot eventSnapshot =
      await FirebaseFirestore.instance.collection('events').doc(eventId).get();
  return eventSnapshot.data() as Map<String, dynamic>;
}

Future<Map<String, dynamic>> getGroupData(String groupId) async {
  DocumentSnapshot eventSnapshot =
      await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
  return eventSnapshot.data() as Map<String, dynamic>;
}

Stream<QuerySnapshot> getEventsForCurrentUser(String currentUserUid) {
  final DocumentReference events =
      FirebaseFirestore.instance.collection("users").doc(currentUserUid);

  final eventsStream = events
      .collection('events')
      .orderBy('date', descending: false)
      .snapshots();

  return eventsStream;
}

Stream<QuerySnapshot> getNotiForCurrentUser(String currentUserUid) {
  final DocumentReference events =
      FirebaseFirestore.instance.collection("users").doc(currentUserUid);

  final eventsStream = events
      .collection('notification')
      .orderBy('timestamp', descending: true)
      .snapshots();

  return eventsStream;
}

Future<List<ImageWithDimension>> getPostImg(List<String> imageURLs) async {
  List<ImageWithDimension> images = [];

  try {
    for (String imageURL in imageURLs) {
      Image imageWidget = Image.network(
        imageURL,
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

      ImageWithDimension imageWithDimension = ImageWithDimension(
        image: imageWidget,
        height: imageHeight,
        width: imageWidth,
        aspectRatio: imageWidth / imageHeight,
      );

      images.add(imageWithDimension);
    }
  } catch (e) {
    images.add(ImageWithDimension(
      image: Image.asset("lib/assets/images/default_profile_image.png"),
      height: 0,
      width: 0,
      aspectRatio: 0,
    ));
  }

  return images;
}

Future<ImageWithDimension> getProfilePic(String userId) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child("users/$userId.png");
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
      aspectRatio: imageWidth / imageHeight,
    );
  } catch (e) {
    return ImageWithDimension(
      image: Center(child: Text('Error getting image: $e')),
      height: 0,
      width: 0,
      aspectRatio: 0,
    );
  }
}

Future<Image> getPoster(String posterURL) async {
  try {
    Image imageWidget = Image.network(
      posterURL,
      fit: BoxFit.cover,
    );

    Completer<ImageInfo> completer = Completer<ImageInfo>();
    imageWidget.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info);
        },
      ),
    );

    await completer.future;

    return imageWidget;
  } catch (e) {
    return Image.network(
      '',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Text('Error getting image: $e'));
      },
    );
  }
}
