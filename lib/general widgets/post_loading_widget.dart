import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:flutter/material.dart';

class PostLoadingWidget extends StatelessWidget {
  const PostLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      height: 250,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 175,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: ContainerLoadingAnimation(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
