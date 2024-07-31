import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FirebaseNotifications {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      //Confidential Data
      //Get Google Drive link from author
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Get Access Token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> sendNotificaionToSelectedDriver(
    String fcmToken,
    String title,
    String body,
    String? type,
  ) async {
    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/ascend-app-6e800/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'type': type ?? "",
        }
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      debugPrint("Notification sent successfully");
    } else {
      debugPrint(
          "Failed to send FCM message: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    messaging.getToken().then((token) async {
      if (token != null) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'fcmToken': token,
        });
      }
    }).catchError((error) {
      debugPrint("Error getting FCM token: $error");
    });
  }
}
