import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/nav_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WrapperNav extends StatefulWidget {
  const WrapperNav({super.key});

  @override
  State<WrapperNav> createState() => _WrapperNavState();
}

class _WrapperNavState extends State<WrapperNav> {
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = getPostsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return const NavScreen();
  }
}
