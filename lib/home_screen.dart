import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'database_service.dart';

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
          size: 15,
        ),
      ),
    );
  }
}

class SocialMediaCard extends StatefulWidget {
  final int index;
  final Widget image;
  final String title;
  final String user;
  final int likes;
  const SocialMediaCard(
      {super.key,
      required this.index,
      required this.image,
      required this.user,
      required this.likes,
      required this.title});

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked == true) {
        likeCount++;
      } else {
        likeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = widget.index == 0 ? 235.0 : 255.0;

    return SizedBox(
      width: 135,
      height: cardHeight,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: widget.image),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "adrian_2002",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          likeCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        CustomButton(
                          icon: Icons.favorite,
                          defaultColor: const Color.fromRGBO(247, 243, 237, 1),
                          pressedColor: Colors.red,
                          onPressed: () {
                            onLikePressed();
                          },
                          isLiked: isLiked,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: getPostsFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          List<Post> posts = snapshot.data!;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
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
                      image: posts[index].imageUrl,
                      title: posts[index].title,
                      user: posts[index].user,
                      likes: posts[index].likes,
                    );
                  },
                  childCount: posts.length,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
