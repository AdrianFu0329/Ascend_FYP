import 'dart:async';
import 'dart:math';

import 'package:ascend_fyp/location/service/Geolocation.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/models/video_with_dimension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';

String generateUniqueId() {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < 20; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}

Future<bool> sendPasswordResetLink(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return true;
  } catch (e) {
    return false;
  }
}

Stream<QuerySnapshot>? getChatData(String chatRoomId, String currentUserId) {
  final CollectionReference? chats = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection("chats")
      .doc(chatRoomId)
      .collection('messages');

  if (chats != null) {
    final chatsStream =
        chats.orderBy('timestamp', descending: true).snapshots();
    return chatsStream;
  } else {
    return null;
  }
}

Stream<QuerySnapshot> getPostsFromDatabase() {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection("posts");

  final postsStream = posts.orderBy('timestamp', descending: true).snapshots();

  return postsStream;
}

Stream<QuerySnapshot> getEventsFromDatabase() {
  return FirebaseFirestore.instance
      .collection("events")
      .orderBy('date', descending: false)
      .snapshots();
}

Future<List<DocumentSnapshot>> sortEventsByDistance(
    List<DocumentSnapshot> events) async {
  Position userLocation = await GeoLocation().getLocation();
  List<Map<String, dynamic>> eventsWithDistance = [];

  for (var event in events) {
    String address = event['location'];
    Position? eventPosition =
        await GeoLocation().getCoordinatesFromAddress(address);

    if (eventPosition != null) {
      double distance = GeoLocation().calculateDistance(
        userLocation,
        eventPosition,
      );
      eventsWithDistance.add({
        'event': event,
        'distance': distance,
      });
    }
  }

  eventsWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

  return eventsWithDistance.map((e) => e['event'] as DocumentSnapshot).toList();
}

Stream<QuerySnapshot> getGroupEventsFromDatabase(String groupId) {
  final CollectionReference events = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('events');

  final eventsStream = events.orderBy('date', descending: false).snapshots();

  return eventsStream;
}

Future<DocumentSnapshot> getSpecificGroupEventFromDatabase(
    String groupId, String eventId) async {
  return FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('events')
      .doc(eventId)
      .get();
}

Stream<DocumentSnapshot> getParticipantsForCurrentEvent(
    String eventId, String groupId) {
  return groupId != "Unknown"
      ? FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .doc(eventId)
          .snapshots()
      : FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .snapshots();
}

Stream<DocumentSnapshot> getMembersForGroup(String groupId) {
  return FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .snapshots();
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
      .orderBy('participationPoints', descending: true)
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

Future<DocumentSnapshot> getEventData(String eventId) async {
  return FirebaseFirestore.instance.collection('events').doc(eventId).get();
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

Future<VideoWithDimension?> getPostVideo(String videoURL) async {
  VideoWithDimension? video;

  try {
    if (videoURL == "Unknown") {
      debugPrint("No Video Found");
      return null;
    } else {
      Uri videoUri = Uri.parse(videoURL);
      VideoPlayerController videoController =
          VideoPlayerController.networkUrl(videoUri);

      await videoController.initialize();

      double videoHeight = videoController.value.size.height;
      double videoWidth = videoController.value.size.width;

      VideoWithDimension videoWithDimension = VideoWithDimension(
        videoController: videoController,
        height: videoHeight,
        width: videoWidth,
        aspectRatio: videoWidth / videoHeight,
      );

      video = videoWithDimension;
      return video;
    }
  } catch (e) {
    debugPrint("Error loading video: $e");
    return null;
  }
}

Future<List<ImageWithDimension>> getPostImg(List<String> imageURLs) async {
  List<ImageWithDimension> images = [];

  try {
    for (String imageURL in imageURLs) {
      CachedNetworkImageProvider imageProvider =
          CachedNetworkImageProvider(imageURL);

      Completer<ImageInfo> completer = Completer<ImageInfo>();
      imageProvider.resolve(const ImageConfiguration()).addListener(
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
        image: Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
        imageURL: imageURL,
        height: imageHeight,
        width: imageWidth,
        aspectRatio: imageWidth / imageHeight,
      );

      images.add(imageWithDimension);
    }
  } catch (e) {
    images.add(ImageWithDimension(
      image: Image.asset("lib/assets/images/default_profile_image.png"),
      imageURL: "Unknown",
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
      imageURL: imgDownload,
      height: imageHeight,
      width: imageWidth,
      aspectRatio: imageWidth / imageHeight,
    );
  } catch (e) {
    return ImageWithDimension(
      image: Center(child: Text('Error getting image: $e')),
      imageURL: "Unknown",
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
