import 'package:ascend_fyp/community/community_screen.dart';
import 'package:ascend_fyp/social%20media/screens/create/media_picker_screen.dart';
import 'package:ascend_fyp/social%20media/screens/home_screen.dart';
import 'package:ascend_fyp/chat/screens/messages_screen.dart';
import 'package:ascend_fyp/profile/screens/details/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavScreen extends StatefulWidget {
  final int? index;
  final int? tab;
  const NavScreen({
    super.key,
    this.index,
    this.tab,
  });

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      setState(() {
        _selectedIndex = widget.index!;
      });
    }
  }

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<int> _fetchUnreadChatCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      int unreadCount = 0;

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        String receiverId = data['receiverId'] as String;
        bool receiverRead = data['receiverRead'] as bool;
        String senderId = data['senderId'] as String;
        bool senderRead = data['senderRead'] as bool;

        if (currentUser!.uid == receiverId && !receiverRead) {
          unreadCount++;
        } else if (currentUser!.uid == senderId && !senderRead) {
          unreadCount++;
        }
      }

      return unreadCount;
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
      const MediaPickerScreen(),
      CommunityScreen(startingTab: widget.tab ?? 0),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: StreamBuilder<int>(
          stream: _fetchUnreadChatCount(),
          builder: (context, snapshot) {
            int unreadChatCount = snapshot.data ?? 0;

            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _navigate,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              items: _navigationItems.map(
                (item) {
                  return BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        Image.asset(
                          _selectedIndex == _navigationItems.indexOf(item)
                              ? item['selected']
                              : item['unselected'],
                          width: _iconSizes[item['sizeKey']],
                          height: _iconSizes[item['sizeKey']],
                        ),
                        if (_navigationItems.indexOf(item) == 1 &&
                            unreadChatCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadChatCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: item['label'],
                  );
                },
              ).toList(),
              selectedItemColor: const Color.fromRGBO(247, 243, 237, 1),
              unselectedItemColor: const Color.fromRGBO(247, 243, 237, 1),
              selectedFontSize: 10,
              unselectedFontSize: 9,
            );
          },
        ),
      ),
    );
  }
}
