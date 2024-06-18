import 'package:ascend_fyp/database/firebase_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  Future<bool> requestNotificationPermission() async {
    PermissionStatus oriStatus = await Permission.notification.request();
    debugPrint(oriStatus.toString());
    try {
      if (oriStatus == PermissionStatus.denied) {
        PermissionStatus status = await Permission.notification.request();
        debugPrint(status.toString());
        return status == PermissionStatus.granted;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint("error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(20, 23, 26, 1),
    );

    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        const Color.fromRGBO(247, 243, 237, 1),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "lib/assets/images/notifications_permission.png",
                width: 300,
                height: 300,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Notifications are currently turned off",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enabling notifications allows us to ensure that you are constantly connected with other users while using Messages!",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    bool granted = await requestNotificationPermission();
                    debugPrint(granted.toString());
                    if (granted) {
                      FirebaseNotifications.getFirebaseMessagingToken();
                      Navigator.pop(context, true);
                    }
                  },
                  style: buttonStyle,
                  child: Text(
                    'Enable Notifications',
                    style: style,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
