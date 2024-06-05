import 'package:ascend_fyp/pages/user_created_groups.dart';
import 'package:ascend_fyp/pages/user_joined_groups.dart';
import 'package:ascend_fyp/widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/widgets/sliver_app_bar.dart';
import 'package:flutter/material.dart';

class UserGroupsScreen extends StatefulWidget {
  const UserGroupsScreen({super.key});

  @override
  State<UserGroupsScreen> createState() => _UserGroupsScreenState();
}

class _UserGroupsScreenState extends State<UserGroupsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle selectedTabBarStyle = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    TextStyle unselectedTabBarStyle = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelStyle: selectedTabBarStyle,
                  unselectedLabelStyle: unselectedTabBarStyle,
                  indicator: CircleTabIndicator(
                    color: Colors.red,
                    radius: 4,
                  ),
                  tabs: const [
                    Tab(text: 'Joined Groups'),
                    Tab(text: 'Created Groups'),
                  ],
                ),
              ),
              pinned: true,
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            CurrentUserJoinedGroups(),
            CurrentUserCreatedGroups(),
          ],
        ),
      ),
    );
  }
}
