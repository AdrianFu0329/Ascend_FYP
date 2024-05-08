import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:flutter/material.dart';

class ImagePageView extends StatefulWidget {
  final List<ImageWithDimension> images;
  final double maxHeight;
  const ImagePageView({
    super.key,
    required this.images,
    required this.maxHeight,
  });

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  final PageController pageController = PageController(initialPage: 0);
  int activePage = 0;

  @override
  Widget build(BuildContext context) {
    return widget.images.isNotEmpty
        ? Stack(
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      activePage = page;
                    });
                  },
                  itemCount: widget.images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Expanded(
                            child: widget.images[index].image,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              widget.images.length > 1
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          widget.images.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () {
                                pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                );
                              },
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: activePage == index
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        : const Center(
            child: Text("Error fetching image. Please try again"),
          );
  }
}
