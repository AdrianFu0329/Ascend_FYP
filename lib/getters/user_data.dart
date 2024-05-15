import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getUserData(String userId) async {
  final docSnapshot =
      await FirebaseFirestore.instance.collection("users").doc(userId).get();

  final Map<String, dynamic> userData = {
    'username': docSnapshot.data()?["displayName"] ?? 'Unknown',
    'photoURL': docSnapshot.data()?["photoURL"] ?? 'Unknown',
    'email': docSnapshot.data()?["email"] ?? 'Unknown',
    'description':
        docSnapshot.data()?["description"] ?? "Empty~~ Add one today!",
    'following': docSnapshot.data()?["following"] ?? [],
    'followers': docSnapshot.data()?["followers"] ?? [],
  };

  return userData;
}
