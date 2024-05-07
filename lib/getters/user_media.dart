import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

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
