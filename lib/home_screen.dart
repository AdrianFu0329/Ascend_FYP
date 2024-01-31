import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SocialMediaCard extends StatelessWidget {
  final int index;
  const SocialMediaCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              "lib/assets/images/logo.png",
              width: 135,
              height: 275,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Image.asset(
              "lib/assets/images/logo_noBg.png",
              width: 130,
              height: 50,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            children: List.generate(
              10,
              (index) => SocialMediaCard(index: index),
            ),
          ),
        ),
      ]),
    );
  }
}
