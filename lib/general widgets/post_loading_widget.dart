import 'package:flutter/material.dart';

class PostLoadingWidget extends StatelessWidget {
  const PostLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).cardColor,
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 175,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
