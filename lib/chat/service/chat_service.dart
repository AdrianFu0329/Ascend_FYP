import 'package:ascend_fyp/models/message.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Update is read status
  Future<void> updateIsRead(String chatRoomId) async {
    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

    try {
      DocumentSnapshot chatSnapshot = await chatRef.get();

      if (chatSnapshot.exists) {
        Map<String, dynamic> chatData =
            chatSnapshot.data() as Map<String, dynamic>;
        bool isSender = currentUser.uid == chatData["senderId"];
        if (isSender) {
          chatRef.update({
            'receiverRead': false,
          });
        } else {
          chatRef.update({
            'senderRead': false,
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to update read status for user: $e");
    }
  }

  //Send Messages
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
      );

      await updateIsRead(chatRoomId);

      await firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMsg.toMap());

      DocumentReference chatRef = firestore.collection('chats').doc(chatRoomId);
      await chatRef.update({
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  //Get Messages
  Stream<QuerySnapshot> getMessages(
      String userId, String senderUserId, String chatRoomId) {
    return firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Create Chat Room
  Future<void> createChatRoom(
    String receiverUserId,
    String receiverUsername,
    String receiverPhotoUrl,
    String receiverFcmToken,
    BuildContext context,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    try {
      String chatRoomId = "${currentUser.uid}_$receiverUserId";

      // Create chat room in firebase
      final Map<String, dynamic> chatRoomData = {
        'receiverId': receiverUserId,
        'senderId': currentUser.uid,
        'timestamp': Timestamp.now(),
        'receiverRead': false,
        'senderRead': true,
      };

      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .set(chatRoomData);

      // Push to chat screen with chosen user
      Navigator.of(context).push(
        SlidingNav(
          builder: (context) => ChatScreen(
            receiverUserId: receiverUserId,
            receiverUsername: receiverUsername,
            receiverPhotoUrl: receiverPhotoUrl,
            receiverFcmToken: receiverFcmToken,
            chatRoomId: chatRoomId,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error obtaining creating chat with user: $e');
    }
  }
}
