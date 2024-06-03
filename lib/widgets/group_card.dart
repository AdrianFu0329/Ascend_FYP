import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/group_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/loading.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String ownerUserId;
  final String groupTitle;
  final List<dynamic> requestList;
  final List<dynamic> memberList;
  final String groupSport;
  final String posterURL;
  final String participants;
  final bool isOther;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.ownerUserId,
    required this.groupTitle,
    required this.requestList,
    required this.memberList,
    required this.groupSport,
    required this.posterURL,
    required this.participants,
    required this.isOther,
  });

  @override
  Widget build(BuildContext context) {
    void navigateToGroupDetailsScreen() {
      Navigator.of(context).push(
        SlidingNav(
          builder: (context) => GroupDetailsScreen(
            groupId: groupId,
            ownerUserId: ownerUserId,
            groupTitle: groupTitle,
            requestList: requestList,
            memberList: memberList,
            groupSport: groupSport,
            posterURL: posterURL,
            participants: participants,
            isOther: isOther,
          ),
        ),
      );
    }

    Widget buildCard() {
      return SizedBox(
        height: 200,
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Stack(
            children: [
              FutureBuilder<Image>(
                future: getPoster(posterURL),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingAnimation();
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "An unexpected error occurred. Try again later...",
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: snapshot.data!.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    );
                  }
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: Text(
                        groupTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        groupSport,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: navigateToGroupDetailsScreen,
      child: buildCard(),
    );
  }
}
