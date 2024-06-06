import 'package:ascend_fyp/pages/community_screen.dart';
import 'package:ascend_fyp/pages/create_post_screen.dart';
import 'package:ascend_fyp/pages/home_screen.dart';
import 'package:ascend_fyp/pages/messages_screen.dart';
import 'package:ascend_fyp/pages/profile_screen.dart';
import 'package:flutter/material.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

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

  final Map<String, double> _iconSizes = {
    'home': 32,
    'messages': 32,
    'add': 55,
    'community': 32,
    'profile': 32,
  };

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'selected': 'lib/assets/images/home_pressed.png',
      'unselected': 'lib/assets/images/home.png',
      'label': 'Home',
      'sizeKey': 'home',
    },
    {
      'selected': 'lib/assets/images/messages_pressed.png',
      'unselected': 'lib/assets/images/messages.png',
      'label': 'Messages',
      'sizeKey': 'messages',
    },
    {
      'selected': 'lib/assets/images/add_pressed.png',
      'unselected': 'lib/assets/images/add.png',
      'label': '',
      'sizeKey': 'add',
    },
    {
      'selected': 'lib/assets/images/community_pressed.png',
      'unselected': 'lib/assets/images/community.png',
      'label': 'Community',
      'sizeKey': 'community',
    },
    {
      'selected': 'lib/assets/images/profile_pressed.png',
      'unselected': 'lib/assets/images/profile.png',
      'label': 'Profile',
      'sizeKey': 'profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List pages = [
      const HomeScreen(),
      const MessagesScreen(),
      const CreatePostScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _navigate,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: _navigationItems.map(
            (item) {
              return BottomNavigationBarItem(
                icon: Image.asset(
                  _selectedIndex == _navigationItems.indexOf(item)
                      ? item['selected']
                      : item['unselected'],
                  width: _iconSizes[item['sizeKey']],
                  height: _iconSizes[item['sizeKey']],
                ),
                label: item['label'],
              );
            },
          ).toList(),
          selectedItemColor: const Color.fromRGBO(247, 243, 237, 1),
          unselectedItemColor: const Color.fromRGBO(247, 243, 237, 1),
          selectedFontSize: 10,
          unselectedFontSize: 9,
        ),
      ),
    );
  }
}
