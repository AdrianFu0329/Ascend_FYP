import 'package:ascend_fyp/getters/user_media.dart';
import 'package:ascend_fyp/models/media.dart';
import 'package:ascend_fyp/pages/picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
  });

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<Media> _selectedMedias = [];

  Future<void> obtainMedia() async {
    await grantPermissions();

    final List<Media>? result = await Navigator.push<List<Media>>(
      context,
      MaterialPageRoute(
        builder: (context) => PickerScreen(selectedMedia: _selectedMedias),
      ),
    );

    if (result != null) {
      _updateSelectedMedias(result);
    }
  }

  void _updateSelectedMedias(List<Media> result) {
    setState(() {
      _selectedMedias.clear();
      _selectedMedias.addAll(result);
    });
  }

  Future<void> grantPermissions() async {
    try {
      final bool photosGranted = await Permission.photos.isGranted;

      if (!photosGranted) {
        final PermissionStatus status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Permission denied. Please grant access to photos.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error granting permissions: $e');
    }
  }

  Widget displayMedia(List<Media> selectedMedia) {
    return ListView.builder(
      itemCount: selectedMedia.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: selectedMedia[index].widget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Create Post',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: displayMedia(_selectedMedias),
      floatingActionButton: FloatingActionButton(
        onPressed: obtainMedia,
        child: const Icon(Icons.add_circle_outline_rounded),
      ),
    );
  }
}
