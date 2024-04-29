import 'package:ascend_fyp/models/media.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';

Future<void> grantPermissions() async {
  try {
    final bool videosGranted = await Permission.videos.isGranted;
    final bool photosGranted = await Permission.photos.isGranted;

    if (!photosGranted || !videosGranted) {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.videos,
        Permission.photos,
      ].request();

      if (statuses[Permission.videos] == PermissionStatus.permanentlyDenied ||
          statuses[Permission.photos] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
    }
  } catch (e) {
    debugPrint('Error granting permissions: $e');
  }
}

Future<List<AssetPathEntity>> fetchAlbums() async {
  try {
    await grantPermissions();

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    return albums;
  } catch (e) {
    debugPrint('Error fetching albums: $e');
    return [];
  }
}

Future<List<Media>> fetchMedias({
  required AssetPathEntity album,
  required int page,
}) async {
  List<Media> medias = [];

  try {
    final List<AssetEntity> entities =
        await album.getAssetListPaged(page: page, size: 30);

    for (var entity in entities) {
      Media media = Media(
        assetEntity: entity,
        widget: FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: AssetEntityImageProvider(
            entity,
            thumbnailSize: const ThumbnailSize.square(500),
            isOriginal: false,
          ),
          fit: BoxFit.cover,
        ),
      );
      medias.add(media);
    }
  } catch (e) {
    debugPrint('Error fetching media: $e');
  }
  return medias;
}
