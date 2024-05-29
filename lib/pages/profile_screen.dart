import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/current_user_joined_events.dart';
import 'package:ascend_fyp/pages/current_user_posts.dart';
import 'package:ascend_fyp/pages/edit_profile_screen.dart';
import 'package:ascend_fyp/pages/welcome_screen.dart';
import 'package:ascend_fyp/widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:ascend_fyp/widgets/sliver_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late String username;
  late String email;
  late String description;
  late List<dynamic> following;
  late List<dynamic> followers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    refreshProfileData();
  }

  Future<void> refreshProfileData() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userData = await getUserData(currentUser.uid);

    setState(() {
      username = userData["username"] ?? "Unknown";
      description = userData["description"] == ""
          ? "Empty~~ Add one today!"
          : userData["description"]!;
      email = userData['email'] ?? "Unknown";
      following = userData['following'] ?? [];
      followers = userData['followers'] ?? [];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(
            color: Color.fromRGBO(247, 243, 237, 1),
            width: 1.5,
          ),
        ),
      ),
    );

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

    return RefreshIndicator(
      onRefresh: refreshProfileData,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              "lib/assets/images/logo_noBg.png",
              width: 130,
              height: 50,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  highlightColor: const Color.fromRGBO(194, 0, 0, 1),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(194, 0, 0, 1),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color.fromRGBO(247, 243, 237, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: getUserData(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CustomLoadingAnimation();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      Map<String, dynamic> userData =
                          snapshot.data as Map<String, dynamic>;
                      username = userData["username"] ?? "Unknown";
                      description = userData["description"] == ""
                          ? "Empty~~ Add one today!"
                          : userData["description"]!;
                      email = userData['email'] ?? "Unknown";
                      following = userData['following'] ?? [];
                      followers = userData['followers'] ?? [];

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ProfilePicture(
                                        userId: currentUser.uid,
                                        photoURL:
                                            currentUser.photoURL ?? "Unknown",
                                        radius: 40,
                                        onTap: () {},
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                followers.length.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              Text(
                                                "Followers",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 28),
                                          Column(
                                            children: [
                                              Text(
                                                following.length.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              Text(
                                                "Following",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    username,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    description,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      final result =
                                          await Navigator.of(context).push(
                                        SlidingNav(
                                          builder: (context) =>
                                              EditProfileScreen(
                                            username: username,
                                            email: email,
                                            description: description,
                                          ),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          username = result['username'];
                                          email = result['email'];
                                          description = result['description'];
                                        });
                                      }
                                    },
                                    style: buttonStyle,
                                    child: const Text('Edit Profile'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                  },
                ),
              ),
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
                      Tab(text: 'Posts'),
                      Tab(text: 'Joined Events'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              CurrentUserPosts(),
              CurrentUserJoinedEvents(),
            ],
          ),
        ),
      ),
    );
  }
}
