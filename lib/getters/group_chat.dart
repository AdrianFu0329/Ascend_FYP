import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getGroupChatRoomData(String chatRoomId) async {
  final docSnapshot = await FirebaseFirestore.instance
      .collection("group_chats")
      .doc(chatRoomId)
      .get();

  if (!docSnapshot.exists) {
    throw Exception("Chat room with ID $chatRoomId does not exist.");
  }

  final data = docSnapshot.data();

  final Map<String, dynamic> chatRoomData = {
    'groupChatName': data?["groupChatName"] ?? 'Unknown',
    'groupPictureUrl': data?["groupPictureUrl"] ?? 'Unknown',
    'memberMap': data?["memberMap"] ?? {},
    'memberFCMToken': data?["memberFCMToken"] ?? [],
    'timestamp': data?["timestamp"] ?? Timestamp.now(),
    'type': data?["type"] ?? 'group',
  };

  return chatRoomData;
}
