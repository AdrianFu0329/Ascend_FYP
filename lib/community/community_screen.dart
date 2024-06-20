import 'package:ascend_fyp/community/groups/screens/community_groups_screen.dart';
import 'package:ascend_fyp/community/events/screens/event_screen.dart';
import 'package:ascend_fyp/general%20widgets/circle_tab_indicator.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  final int startingTab;
  const CommunityScreen({
    super.key,
    required this.startingTab,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: widget.startingTab,
    );
    super.initState();
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

    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, '/start');
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Community',
            style: Theme.of(context).textTheme.titleLarge!,
          ),
        ),
        body: Column(
          children: [
            TabBar(
              controller: tabController,
              labelStyle: selectedTabBarStyle,
              unselectedLabelStyle: unselectedTabBarStyle,
              indicator: CircleTabIndicator(
                color: Colors.red,
                radius: 4,
              ),
              tabs: const [
                Tab(text: 'Events'),
                Tab(text: 'Groups'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  EventScreen(),
                  CommunityGroupsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
