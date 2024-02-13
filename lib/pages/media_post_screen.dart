import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../database/database_service.dart';

class MediaPostScreen extends StatelessWidget {
  final ImageWithDimension image;
  final String title;
  final String user;
  final int likes;

  const MediaPostScreen({
    super.key,
    required this.image,
    required this.title,
    required this.user,
    required this.likes,
  });

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
                      "description here...",
                      style: Theme.of(context).textTheme.bodyMedium,
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
