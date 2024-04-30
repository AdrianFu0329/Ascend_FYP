import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String userId;
  final String photoURL;
  final double radius;

  const ProfilePicture({
    super.key,
    required this.userId,
    required this.photoURL,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageWithDimension>(
      future: getProfilePic(userId), // Assuming getProfilePic is defined
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomLoadingAnimation());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          //final profilePic = snapshot.data;
          if (photoURL != "Unknown") {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(photoURL),
            );
          } /*else if (currentUser.photoURL == null) {
            return CircleAvatar(
              radius: radius,
              child:Image.network(profilePic),
              backgroundColor: Colors.transparent,
            );
          }*/
          else {
            debugPrint("No profile picture detected...");
            return CircleAvatar(
              radius: radius,
              backgroundImage: const AssetImage(
                'lib/assets/images/default_profile_image.png',
              ),
            );
          }
        }
      },
    );
  }
}
