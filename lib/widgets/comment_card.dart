import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/getters/user_data.dart';

class CommentPost extends StatelessWidget {
  final String text;
  final String time;
  final String userId;

  const CommentPost({
    super.key,
    required this.text,
    required this.time,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: FutureBuilder<Map<String, String>>(
        future: getUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingAnimation());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data!;
            final username = userData['username'] ?? 'Unknown';
            final photoUrl = userData['photoURL'] ?? 'Unknown';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProfilePicture(
                      userId: userId,
                      photoURL: photoUrl,
                      radius: 12,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Merriweather Sans',
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(211, 211, 211, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Merriweather Sans',
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(211, 211, 211, 1),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
