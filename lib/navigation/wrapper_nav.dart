import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/nav_screen.dart';
import 'package:flutter/material.dart';

class WrapperNav extends StatefulWidget {
  const WrapperNav({super.key});

  @override
  State<WrapperNav> createState() => _WrapperNavState();
}

class _WrapperNavState extends State<WrapperNav> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = getPostsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return const NavScreen();
  }
}
