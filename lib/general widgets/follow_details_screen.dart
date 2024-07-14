import 'package:ascend_fyp/general%20widgets/follower_list_tab.dart';
import 'package:ascend_fyp/general%20widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/general%20widgets/sliver_app_bar.dart';
import 'package:flutter/material.dart';

class FollowDetailsScreen extends StatefulWidget {
  final List<dynamic> followerList;
  final List<dynamic> followingList;
  const FollowDetailsScreen({
    super.key,
    required this.followerList,
    required this.followingList,
  });

  @override
  State<FollowDetailsScreen> createState() => _FollowDetailsScreenState();
}

class _FollowDetailsScreenState extends State<FollowDetailsScreen>
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
                  tabs: [
                    Tab(text: 'Followers (${widget.followerList.length})'),
                    Tab(text: 'Following (${widget.followingList.length})'),
                  ],
                ),
              ),
              pinned: true,
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            FollowerListTab(list: widget.followerList),
            FollowerListTab(list: widget.followingList),
          ],
        ),
      ),
    );
  }
}
