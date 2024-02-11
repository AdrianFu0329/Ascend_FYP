import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/home_screen.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:flutter/material.dart';

class NavScreen extends StatefulWidget {
  final List<Post> posts;
  const NavScreen({super.key, required this.posts});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final double iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final List pages = [
      HomeScreen(posts: widget.posts),
      const MediaPostScreen(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      backgroundColor: Theme.of(context).cardColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigate,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/images/home.png',
              width: iconSize,
              height: iconSize,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/images/messages.png',
              width: iconSize,
              height: iconSize,
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/images/events.png',
              width: iconSize,
              height: iconSize,
            ),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/images/profile.png',
              width: iconSize,
              height: iconSize,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
