import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final Color defaultColor;
  final Color pressedColor;
  final Function onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.defaultColor,
    required this.pressedColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          onPressed();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: defaultColor,
          size: 16,
        ),
      ),
    );
  }
}

class SocialMediaCard extends StatefulWidget {
  final int index;
  const SocialMediaCard({super.key, required this.index});

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard> {
  bool isLiked = false;

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "adrian_2002",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Center(
              child: Image.asset(
                "lib/assets/images/logo.png",
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    icon: Icons.favorite,
                    defaultColor: const Color.fromRGBO(247, 243, 237, 1),
                    pressedColor: Colors.red,
                    onPressed: () {
                      onLikePressed();
                    },
                  ),
                )
              ],
            ),
          ],
        ),
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
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 36),
            child: Image.asset(
              "lib/assets/images/logo_noBg.png",
              width: 130,
              height: 50,
            ),
          ),
        ),
        SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          itemBuilder: (BuildContext context, int index) {
            return SocialMediaCard(
              index: index,
            );
          },
          childCount: 10,
        ),
      ]),
    );
  }
}
