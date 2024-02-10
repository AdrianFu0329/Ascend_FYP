import 'package:flutter/material.dart';

class MediaPostScreen extends StatelessWidget {
  const MediaPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () => (Navigator.of(context).pop()),
        ),
      ),
    );
  }
}
