import 'package:ascend_fyp/pages/event_screen.dart';
import 'package:ascend_fyp/pages/home_screen.dart';
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

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'selected': 'lib/assets/images/home_pressed.png',
      'unselected': 'lib/assets/images/home.png',
      'label': 'Home',
    },
    {
      'selected': 'lib/assets/images/messages_pressed.png',
      'unselected': 'lib/assets/images/messages.png',
      'label': 'Messages',
    },
    {
      'selected': 'lib/assets/images/events.png',
      'unselected': 'lib/assets/images/events.png',
      'label': 'Events',
    },
    {
      'selected': 'lib/assets/images/profile_pressed.png',
      'unselected': 'lib/assets/images/profile.png',
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List pages = [
      const HomeScreen(),
      Container(),
      const EventScreen(),
      Container(),
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
                  width: iconSize,
                  height: iconSize,
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
