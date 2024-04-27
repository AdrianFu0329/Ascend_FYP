import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, String>> getUserData(String userId) async {
  final docSnapshot =
      await FirebaseFirestore.instance.collection("users").doc(userId).get();

  final Map<String, String> userData = {
    'username': docSnapshot.data()?['displayName'] ?? 'Unknown',
    'photoURL': docSnapshot.data()?['photoURL'] ?? 'Unknown',
  };

  return userData;
}
