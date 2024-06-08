import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:flutter/material.dart';

class SideMenuTile extends StatelessWidget {
  final String title;
  final String assetPath;
  final Widget navScreen;
  const SideMenuTile({
    super.key,
    required this.title,
    required this.assetPath,
    required this.navScreen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 24,
        width: 24,
        child: Image.asset(assetPath),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        Navigator.of(context).push(
          SlidingNav(
            builder: (context) => navScreen,
          ),
        );
      },
    );
  }
}
