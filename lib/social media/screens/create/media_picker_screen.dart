import 'dart:io';

import 'package:ascend_fyp/general%20widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/social%20media/screens/create/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen>
    with SingleTickerProviderStateMixin {
  final List<File> _images = [];
  File? _video;
  VideoPlayerController? _videoController;
  late TabController _tabController;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() {
          _video = null;
          _videoController?.dispose();
          _videoController = null;
        });
      } else if (_tabController.index == 1) {
        setState(() {
          _images.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  TextStyle textStyle = const TextStyle(
    fontSize: 13,
    fontFamily: 'Merriweather Sans',
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  TextStyle selectedTabBarStyle = const TextStyle(
    fontSize: 14,
    fontFamily: 'Merriweather Sans',
    fontWeight: FontWeight.normal,
    color: Color.fromRGBO(247, 243, 237, 1),
  );

  TextStyle unselectedTabBarStyle = const TextStyle(
    fontSize: 14,
    fontFamily: 'Merriweather Sans',
    fontWeight: FontWeight.normal,
    color: Color.fromRGBO(247, 243, 237, 1),
  );

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setState(() {
        int remainingSlots = 10 - _images.length;
        _images.addAll(pickedImages
            .take(remainingSlots)
            .map((pickedImage) => File(pickedImage.path)));
        if (pickedImages.length > remainingSlots) {
          showMessage("You can only select up to 10 media items.");
        }
      });
    } else {
      showMessage("No image selected");
    }
  }

  Future<void> getVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _video = File(pickedVideo.path);
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.pause();
          });
      });
    } else {
      showMessage("No video selected");
    }
  }

  Widget imageTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${_images.length}/10",
              style: textStyle,
            ),
          ],
        ),
        if (_images.isNotEmpty) ...[
          Flexible(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  _images[index],
                                  width: 175,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: getImage,
                      child: Container(
                        width: 65,
                        height: 65,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          Flexible(
            child: GestureDetector(
              onTap: getImage,
              child: Container(
                width: 200,
                height: 200,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget videoTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (_video != null)
          Flexible(
            child: Stack(
              children: [
                if (_videoController != null &&
                    _videoController!.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                else
                  Container(),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _video = null;
                        _videoController?.dispose();
                        _videoController = null;
                      });
                    },
                    child: Container(
                      color: Colors.black54,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Flexible(
            child: GestureDetector(
              onTap: getVideo,
              child: Container(
                width: 200,
                height: 200,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Button below the video
        if (_videoController != null)
          IconButton(
            onPressed: () {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
                setState(() {
                  isPlaying = false;
                });
              } else {
                _videoController!.play();
                setState(() {
                  isPlaying = true;
                });
              }
            },
            icon: isPlaying
                ? const Icon(
                    Icons.pause_rounded,
                    color: Color.fromRGBO(247, 243, 237, 1),
                    size: 30,
                  )
                : const Icon(
                    Icons.play_arrow_rounded,
                    color: Color.fromRGBO(247, 243, 237, 1),
                    size: 30,
                  ),
          ),
      ],
    );
  }

  bool hasMedia() {
    if (_images.isEmpty && _video == null) {
      showMessage('Please select at least one media file.');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side:
              const BorderSide(color: Color.fromRGBO(194, 0, 0, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Create Post',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: ElevatedButton(
              onPressed: () {
                if (hasMedia()) {
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => CreatePostScreen(
                        images: _images,
                        video: _video,
                      ),
                    ),
                  );
                }
              },
              style: buttonStyle,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Selected Media",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelStyle: selectedTabBarStyle,
              unselectedLabelStyle: unselectedTabBarStyle,
              indicator: CircleTabIndicator(
                color: Colors.red,
                radius: 4,
              ),
              tabs: const [
                Tab(text: "Images"),
                Tab(text: "Video"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Images
                  imageTab(),
                  // Tab 2: Video
                  videoTab(),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
