import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomButton extends StatefulWidget {
  final IconData icon;
  final Color defaultColor;
  final Color pressedColor;
  final Function onPressed;
  final bool isLiked;

  const CustomButton({
    super.key,
    required this.icon,
    required this.defaultColor,
    required this.pressedColor,
    required this.onPressed,
    required this.isLiked,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        child: Icon(
          widget.icon,
          color: widget.isLiked ? widget.pressedColor : widget.defaultColor,
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
    double cardHeight = widget.index == 0 ? 275.0 : 300.0;

    return SizedBox(
      width: 135,
      height: cardHeight,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "adrian_2002",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  "lib/assets/images/logo.png",
                  fit: BoxFit.contain,
                  height: cardHeight * 1.5,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CustomButton(
                    icon: Icons.favorite,
                    defaultColor: const Color.fromRGBO(247, 243, 237, 1),
                    pressedColor: Colors.red,
                    onPressed: () {
                      onLikePressed();
                    },
                    isLiked: isLiked,
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
            padding: const EdgeInsets.fromLTRB(0, 36, 0, 36),
            child: Image.asset(
              "lib/assets/images/logo_noBg.png",
              width: 130,
              height: 50,
            ),
          ),
        ),
        SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 4,
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
