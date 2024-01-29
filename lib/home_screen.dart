import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Image.asset(
            "lib/assets/images/logo_noBg.png",
            width: 130,
            height: 50,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Text("Welcome", style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
