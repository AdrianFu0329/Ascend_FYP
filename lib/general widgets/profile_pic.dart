import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? userId;
  final String photoURL;
  final double radius;
  final VoidCallback onTap;

  const ProfilePicture({
    super.key,
    this.userId,
    required this.photoURL,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageWithDimension>(
      future: getProfilePic(userId ?? photoURL),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (photoURL != "Unknown") {
            return GestureDetector(
              onTap: onTap,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.transparent,
                backgroundImage: CachedNetworkImageProvider(photoURL),
              ),
            );
          } else {
            return GestureDetector(
              onTap: onTap,
              child: CircleAvatar(
                radius: radius,
                backgroundImage: const AssetImage(
                  'lib/assets/images/default_profile_image.png',
                ),
              ),
            );
          }
        }
      },
    );
  }
}
