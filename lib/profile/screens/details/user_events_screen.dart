import 'package:ascend_fyp/profile/screens/details/user_created_events.dart';
import 'package:ascend_fyp/profile/screens/details/user_joined_events.dart';
import 'package:ascend_fyp/general%20widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/general%20widgets/sliver_app_bar.dart';
import 'package:flutter/material.dart';

class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({super.key});

  @override
  State<UserEventsScreen> createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen>
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
                    Tab(text: 'Joined Events'),
                    Tab(text: 'Created Events'),
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
            CurrentUserJoinedEvents(),
            CurrentUserCreatedEvents(),
          ],
        ),
      ),
    );
  }
}
