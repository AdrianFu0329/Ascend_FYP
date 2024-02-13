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
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
              color: Color.fromRGBO(194, 0, 0, 1),
              backgroundColor: Color.fromRGBO(247, 243, 237, 1),
            )),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return NavScreen(posts: snapshot.data!);
        }
      },
    );
  }
}
