import 'dart:io';
import 'package:ascend_fyp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Update is read status
  Future<void> updateIsRead(String chatRoomId, String receiverUserId) async {
    DocumentReference currentChatRef = firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .doc(chatRoomId);

    DocumentReference receiverChatRef = firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(chatRoomId);

    try {
      DocumentSnapshot currentChatSnapshot = await currentChatRef.get();
      DocumentSnapshot receiverChatSnapshot = await receiverChatRef.get();

      if (currentChatSnapshot.exists && receiverChatSnapshot.exists) {
        Map<String, dynamic> currentChatData =
            currentChatSnapshot.data() as Map<String, dynamic>;
        bool isSender = currentUser.uid == currentChatData["senderId"];

        if (isSender) {
          currentChatRef.update({
            'receiverRead': false,
          });
          receiverChatRef.update({
            'receiverRead': false,
          });
        } else {
          currentChatRef.update({
            'senderRead': false,
          });
          receiverChatRef.update({
            'senderRead': false,
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to update read status for user: $e");
    }
  }

  // Send Messages
  Future<void> sendMessage(
      String receiverId, String message, String chatRoomId) async {
    try {
      final String currentUserId = firebaseAuth.currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      Message newMsg = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
        type: "text",
      );

      await updateIsRead(chatRoomId, receiverId);

      // Write message to current user doc
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      // Write message to receiver user doc
      await firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      // Update timestamp for chatroom in current user docs
      DocumentReference currentChatRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatRoomId);
      await currentChatRef.update({
        'timestamp': Timestamp.now(),
      });

      // Update timestamp for chatroom in receiver user docs
      DocumentReference receiverChatRef = firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(chatRoomId);
      await receiverChatRef.update({
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  // Send Image Message
  Future<void> sendImageMessage(
      String receiverId, String imageUrl, String chatRoomId) async {
    try {
      final String currentUserId = firebaseAuth.currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      Message newMsg = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        message: imageUrl,
        timestamp: timestamp,
        type: 'image',
      );

      await updateIsRead(chatRoomId, receiverId);

      // Write image message to current user doc
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      // Write image message to receiver user doc
      await firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      // Update timestamp for chatroom in current user docs
      DocumentReference currentChatRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatRoomId);
      await currentChatRef.update({
        'timestamp': Timestamp.now(),
      });

      // Update timestamp for chatroom in receiver user docs
      DocumentReference receiverChatRef = firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(chatRoomId);
      await receiverChatRef.update({
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint("Error sending image message: $e");
    }
  }

  // Upload Image
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = storage.ref().child('chatImages').child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(
      String userId, String senderUserId, String chatRoomId) {
    return firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Create Chat Room
  Future<String?> createChatRoom(
    String receiverUserId,
    String receiverUsername,
    String receiverPhotoUrl,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    try {
      String chatRoomId = "${currentUser.uid}_$receiverUserId";
      // Create chat room in firebase
      final Map<String, dynamic> chatRoomData = {
        'receiverId': receiverUserId,
        'senderId': currentUser.uid,
        'timestamp': Timestamp.now(),
        'receiverRead': true,
        'senderRead': true,
      };

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference receiverChatDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(receiverUserId)
            .collection('chats')
            .doc(chatRoomId);

        DocumentReference senderChatDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('chats')
            .doc(chatRoomId);

        transaction.set(receiverChatDoc, chatRoomData);
        transaction.set(senderChatDoc, chatRoomData);
      });

      Message newMsg = Message(
        senderId: currentUser.uid,
        receiverId: receiverUserId,
        message: "first",
        timestamp: Timestamp.now(),
        type: "first",
      );

      // Write first message to current user doc
      await firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      // Write first message to current user doc
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      return chatRoomId;
    } catch (e) {
      debugPrint('Error creating chat with user: $e');
      return null;
    }
  }
}
