import 'package:video_player/video_player.dart';

class VideoWithDimension {
  final VideoPlayerController videoController;
  final double width;
  final double height;
  final double aspectRatio;

  VideoWithDimension({
    required this.videoController,
    required this.width,
    required this.height,
    required this.aspectRatio,
  });
}
