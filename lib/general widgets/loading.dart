import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingAnimation extends StatelessWidget {
  final String? page;
  const CustomLoadingAnimation({super.key, this.page});

  @override
  Widget build(BuildContext context) {
    final loading = {
      "normal": "lib/assets/lottie/loading_circle.json",
      "events": "lib/assets/lottie/events_loading.json",
      "profile": "lib/assets/lottie/profile_loading.json",
      "groups": "lib/assets/lottie/groups_loading.json",
      "chats": "lib/assets/lottie/chats_loading.json",
      "posts": "lib/assets/lottie/posts_loading.json",
    };

    final currentPage = page ?? "normal";
    return currentPage == "normal"
        ? Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Lottie.asset(
                  loading[currentPage]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Lottie.asset(
                loading[currentPage]!,
                width: 200,
                height: 200,
              ),
            ),
          );
  }
}
