import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../database/database_service.dart';
import 'package:intl/intl.dart';

class MediaPostScreen extends StatelessWidget {
  final ImageWithDimension image;
  final String title;
  final String user;
  final int likes;
  final Timestamp timestamp;
  final String description;

  const MediaPostScreen({
    super.key,
    required this.image,
    required this.title,
    required this.user,
    required this.likes,
    required this.timestamp,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = timestamp.toDate();
    String formatted = DateFormat('MMM dd, yyyy HH:mm').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () => (Navigator.of(context).pop()),
        ),
        title: Text(
          user,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: image.height * 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image.image,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      formatted,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
