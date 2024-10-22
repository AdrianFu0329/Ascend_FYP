import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:flutter/material.dart';

class LeaderboardTop3 extends StatefulWidget {
  final String? top1UserId;
  final String? top2UserId;
  final String? top3UserId;
  final int? top1Points;
  final int? top2Points;
  final int? top3Points;
  const LeaderboardTop3({
    super.key,
    required this.top1UserId,
    required this.top2UserId,
    required this.top3UserId,
    this.top1Points,
    this.top2Points,
    this.top3Points,
  });

  @override
  State<LeaderboardTop3> createState() => _LeaderboardTop3State();
}

class _LeaderboardTop3State extends State<LeaderboardTop3> {
  TextStyle textStyle = const TextStyle(
    fontSize: 11,
    fontFamily: 'Merriweather Sans',
    fontWeight: FontWeight.normal,
    color: Color.fromRGBO(247, 243, 237, 1),
  );

  Widget userAvatar(String userId, Color borderColor) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 5.0,
                  ),
                ),
                child: ProfilePicture(
                  userId: userId,
                  photoURL: userData['photoURL'],
                  radius: 25,
                  onTap: () {},
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget username(String userId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          return Text(
            userData['username'],
            style: textStyle,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget.top2UserId == ""
            ? Container(
                height: 180,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : Container(
                height: 180,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    userAvatar(
                      widget.top2UserId!,
                      Colors.grey,
                    ),
                    Image.asset(
                      "lib/assets/images/second_place.png",
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(height: 6),
                    username(widget.top2UserId!),
                    const SizedBox(height: 6),
                    Text(
                      widget.top2Points.toString(),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
        widget.top1UserId == ""
            ? Container(
                height: 200,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : Container(
                height: 200,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    userAvatar(
                      widget.top1UserId!,
                      const Color.fromRGBO(189, 155, 22, 1),
                    ),
                    Image.asset(
                      "lib/assets/images/crown.png",
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(height: 6),
                    username(widget.top1UserId!),
                    const SizedBox(height: 6),
                    Text(
                      widget.top1Points.toString(),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
        widget.top3UserId == ""
            ? Container(
                height: 165,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : Container(
                height: 165,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    userAvatar(
                      widget.top3UserId!,
                      Colors.brown,
                    ),
                    Image.asset(
                      "lib/assets/images/third_place.png",
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(height: 12),
                    username(widget.top3UserId!),
                    const SizedBox(height: 6),
                    Text(
                      widget.top3Points.toString(),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
