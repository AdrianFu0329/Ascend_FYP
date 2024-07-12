import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/profile/screens/side%20menu/view/side_menu.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/profile/screens/details/current_user_posts.dart';
import 'package:ascend_fyp/profile/screens/edit/edit_profile_screen.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
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
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final data = await getUserData(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> refreshProfileData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, '/start');
      }),
      child: RefreshIndicator(
        onRefresh: refreshProfileData,
        backgroundColor: Theme.of(context).cardColor,
        color: Colors.red,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu),
              color: const Color.fromRGBO(247, 243, 237, 1),
            ),
          ),
          drawer: Drawer(
            surfaceTintColor: const Color.fromRGBO(247, 243, 237, 1),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: const SideMenu(),
          ),
          body: isLoading
              ? const Center(child: CustomLoadingAnimation())
              : hasError
                  ? const Center(child: Text('Error fetching user data'))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            photoURL: FirebaseAuth.instance
                                                    .currentUser!.photoURL ??
                                                "Unknown",
                                            radius: 40,
                                            onTap: () {},
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    (userData?['followers'] ??
                                                            [])
                                                        .length
                                                        .toString(),
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
                                                    (userData?['following'] ??
                                                            [])
                                                        .length
                                                        .toString(),
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
                                        userData?['username'] ?? 'Unknown',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      subtitle: Text(
                                        userData?['description'] == ""
                                            ? "Empty~~ Add one today!"
                                            : userData?['description'] ??
                                                'No description',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            SlidingNav(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                username:
                                                    userData?['username'] ??
                                                        'Unknown',
                                                email: userData?['email'] ??
                                                    'Unknown',
                                                description:
                                                    userData?['description'] ??
                                                        '',
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            setState(() {
                                              userData = result;
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
                              const Divider(),
                            ],
                          ),
                        ),
                        const CurrentUserPosts(),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
        ),
      ),
    );
  }
}
