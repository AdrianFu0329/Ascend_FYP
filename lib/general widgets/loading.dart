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
    };

    final currentPage = page ?? "normal";
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Lottie.asset(
          loading[currentPage]!,
          width: currentPage != "normal" ? 200 : 100,
          height: currentPage != "normal" ? 200 : 100,
        ),
      ),
    );
  }
}
