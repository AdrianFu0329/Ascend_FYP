import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GeneralNotificationDetailsScreen extends StatefulWidget {
  final String notificationId;
  final String title;
  final String message;
  const GeneralNotificationDetailsScreen({
    super.key,
    required this.title,
    required this.message,
    required this.notificationId,
  });

  @override
  State<GeneralNotificationDetailsScreen> createState() =>
      _GeneralNotificationDetailsScreenState();
}

class _GeneralNotificationDetailsScreenState
    extends State<GeneralNotificationDetailsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showMessage(String message, {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteNotification() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notification')
        .doc(widget.notificationId)
        .delete();
  }

  void onReadPress() async {
    try {
      // Delete Notification
      await deleteNotification();
      Navigator.pop(context);
    } catch (e) {
      _showMessage(
          "There was an unexpected error while recording your response. Try again later!");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: FutureBuilder<Image>(
              future: getPoster(generalNotification),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingAnimation(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "An unexpected error occurred. Try again later...",
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: snapshot.data!.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 145,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.75),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromRGBO(194, 0, 0, 1),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(194, 0, 0, 1),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: onReadPress,
                  child: const Text(
                    'Mark as Read',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Merriweather Sans',
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(247, 243, 237, 1),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
