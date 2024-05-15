import 'package:ascend_fyp/pages/event_screen.dart';
import 'package:ascend_fyp/widgets/circle_tab_indicator.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 2);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Community',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Expanded(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                labelStyle: selectedTabBarStyle,
                unselectedLabelStyle: unselectedTabBarStyle,
                indicator: CircleTabIndicator(
                  color: Colors.red,
                  radius: 4,
                ),
                tabs: [
                  Tab(
                    child: Text(
                      "Events",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Groups",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                const EventScreen(),
                Container(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
