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
      "type": "service_account",
      "project_id": "ascend-app-6e800",
      "private_key_id": "ba105c9b1ea7fccd69fa9b3c0f57ee87a374987d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC9Wy1xFYE0XyWy\n+nSXjmEq93BCeveUBIsBP9JZ7orjwlKRu01f1KptXjuER6vq6vJM6Fs/k/VTDry2\nIpmfWsNKWOnhndEcvYoicu7jzvrrpWvVP1lvvzkB5svj4SXUbp8b9JXm162Vkc2z\nR2zhr3gPbgkfGoIX4SBMPd7Q6iuLue+Uo99R1OdMzYtN2rtrCX6IJlEUXXIGnzin\n6D1/DkCT4c24De5DSNTqmj5Zf4AH9TGow1XPKbsfoF3q1BwE3U+U3dEEbNnqk9F8\nnrK11uwY5MD/H3wq6Ut9cnj9VVxMM9YXvp0ITLkOECWpGZ73loKC/N13WjMNp4a2\nQsXOflcjAgMBAAECggEAVg5wjgLIeB0/3GIAB/rgxS60Obp59y7DX9t6BX4oaA9i\nCDI4HXPgypi3csxB4R9K5FH7Wl8rcMZzVFFQQQB2Xb0f+fYH2ch4VWSnlif0mJDS\n+5TxWBxvU6JpClVCJJPrwsA7OjDOBno/opk07jKZXWXURmr9Mc4SKCQ8NfUeuj6L\n5zCQac8WlHrHw2NmQfu8LXK+b9Wn3qKhqvxTU4eblgpQM70tQnZ439pjtg436DhV\npe862gHtDKZudPMDS4ufRWP/Totj+uHiOl5R0+xfgRhpu4rE7Cz47ugif2pawwzk\n1WjDDSn5Pmxq92F/1AAnJYk3Y+Cg/1Xfnz959evbcQKBgQDh7nLwYjTo6Gk5TtnN\n+4SalrlxqWajNEawW9gbV4NSpkVat7tr7ArJK2O6HugadmFdWTZ3/a2opPwxuhXp\nFC1mmcCHG5e+c3cW1Fchn0i2ShuPdtULaiNxt+Y6O+FnPt76F0ZQxDZ4zcrsqIcM\nw0Yk9vpQCFizIipxK2OCi+fpUwKBgQDWjpkTHjtUQ9Skl+QzlL6TKjwv2ZCRVq4N\nAQp88gsQVCSECUeHaSKkUurDZhrEu94Q7fMvICuQ4KkjwEW6cxrwAd0QipPBIgxF\n3YRcwUGaWDjMNsrSMiN0UzYVqp8U3P7o3bXqlWVnYHC8dhoVZBb99Z+FSfplnW3j\nb7pgC7+Q8QKBgQCm57/To8lQknlBk+XFjNzOUzDWLf4b7T+Xg5InyMPEJ/8uYHM9\n7Befu8UltzVibzfIfWKGzEohPxjsJ3uOP5C2rjkT1qeIU8aTf/SKayCNQjwQBQqo\nLxXWKbQUKy5+VmzlNpKEkh9nqSgTIwD5xbypDCepPjFAzKmsBxCxXWfK7wKBgQCD\n4F4iLCDXaGHZUSsIsVJ57inUV2vOiXKtt4gUyEkYnj9bkMCQcITEb9qwg5/McJTL\n3xXsT1+3yv7rZJD3SyyxfNO+CQ9MVHsqrj9fK8IA9lzi2ILNs9eq9kJ2CsuA7V0Z\nEL1yFKWhZtukWwspPr4LFuAX8yKfNqaGdvQdeNskYQKBgQDgMjV2xgeuXyaH4ZM9\nPUrlEpNzMGT8InT431Ec+JXit3nj4aIE90JZRg7DvMPA/hIDrASvECby3TXKzoOX\nO5WwIDfeIQhEoIRpcDJfWijGi58WKmMa8b+twioy5UlV77+l1aC/0RexMRZl6AiL\n8AoS0vMGL1tnYakBUWlPq3cH2w==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-ascend-fyp@ascend-app-6e800.iam.gserviceaccount.com",
      "client_id": "116509311427108104513",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-ascend-fyp%40ascend-app-6e800.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
