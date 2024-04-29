import 'package:ascend_fyp/models/media.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaItem extends StatelessWidget {
  final Media media;
  final bool isSelected;
  final Function selectMedia;

  const MediaItem({
    super.key,
    required this.media,
    required this.isSelected,
    required this.selectMedia,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectMedia(media),
      child: Stack(
        children: [
          _buildMediaWidget(),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
              child: media.assetEntity.type == AssetType.video
                  ? const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          if (isSelected) _buildIsSelectedOverlay(),
        ],
      ),
    );
  }

  Widget _buildMediaWidget() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(isSelected ? 10 : 0),
        child: media.widget,
      ),
    );
  }

  Widget _buildIsSelectedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
