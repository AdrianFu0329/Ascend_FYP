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
        ? Column(
            children: [
              Stack(
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
                          top: 8,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(63, 63, 77, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${activePage + 1}/${widget.images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              const SizedBox(height: 8),
              widget.images.length > 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        widget.images.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () {
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: activePage == index
                                  ? Colors.red[700]
                                  : Colors.white,
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
