import 'dart:io';

import 'package:ascend_fyp/location/screens/set_location_screen.dart';
import 'package:ascend_fyp/general%20widgets/custom_text_field.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/location/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  final List<File> images;
  final File? video;
  const CreatePostScreen({
    super.key,
    required this.images,
    required this.video,
  });

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Map<String, dynamic> _locationData = {};
  String? location;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCreatingPost = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    bool validatePost() {
      if (titleController.text.trim().isEmpty) {
        showMessage('Please enter a title.');
        return false;
      }

      if (_locationData.isEmpty) {
        showMessage('Please set a location.');
        return false;
      }

      return true;
    }

    Future<String> uploadVideo(String postId) async {
      if (widget.video == null) return "";

      try {
        final String fileName = '$postId.mp4';
        final Reference reference =
            FirebaseStorage.instance.ref().child('posts/$postId/$fileName');
        final UploadTask uploadTask = reference.putFile(widget.video!);
        final TaskSnapshot taskSnapshot = await uploadTask;
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        return downloadURL;
      } catch (error) {
        showMessage('Error uploading video: $error');
        throw error;
      }
    }

    Future<List<String>> uploadImages(String postId) async {
      List<String> imageURLs = [];

      try {
        // Upload each image to Firebase Storage
        for (int i = 0; i < widget.images.length; i++) {
          final String fileName = '${postId}_$i.jpeg';
          final Reference reference =
              FirebaseStorage.instance.ref().child('posts/$postId/$fileName');
          final UploadTask uploadTask = reference.putFile(widget.images[i]);
          final TaskSnapshot taskSnapshot = await uploadTask;
          final String downloadURL = await taskSnapshot.ref.getDownloadURL();

          imageURLs.add(downloadURL);
        }
      } catch (error) {
        // Handle error while uploading images
        showMessage('Error uploading images: $error');
      }

      return imageURLs;
    }

    Future<void> createPost() async {
      if (validatePost()) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        String location = _locationData['location'] ?? "Unknown";

        if (_formKey.currentState!.validate()) {
          setState(() {
            _isCreatingPost = true;
          });

          try {
            final String postId =
                FirebaseFirestore.instance.collection('posts').doc().id;

            // Upload images to Firebase Storage
            List<String> imageURLs = await uploadImages(postId);

            // Upload video to Firebase Storage
            String videoURL = await uploadVideo(postId);

            final Map<String, dynamic> postData = {
              'postId': postId,
              'title': titleController.text.trim(),
              'description': descriptionController.text.trim(),
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'likes': [],
              'timestamp': Timestamp.now(),
              'location': location,
              widget.video != null ? 'videoURL' : 'imageURLs':
                  widget.video != null ? videoURL : imageURLs,
              'type': widget.video != null ? "Video" : "Images",
            };

            // Add the post document to Firestore
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .set(postData);

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('posts')
                .doc(postId)
                .set(postData);

            showMessage('Post created successfully');

            titleController.clear();
            descriptionController.clear();
            _locationData.clear();
            setState(() {
              _isCreatingPost = false;
            });
          } catch (error) {
            showMessage('Error creating post: $error');
            setState(() {
              _isCreatingPost = false;
            });
          }
        }
      }
    }

    Future<void> getLocation() async {
      final Map<String, dynamic> locationData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetLocationScreen(
            enableCurrentLocation: true,
          ),
        ),
      );
      String? city = locationData['location'];
      if (locationData.isNotEmpty) {
        _locationData = locationData;
        location = city;
        setState(() {});
      } else {
        debugPrint("No location data...");
      }
    }

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

    ButtonStyle locationButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 14,
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
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: ElevatedButton(
              onPressed: () {
                if (validatePost()) {
                  createPost();
                }
              },
              style: buttonStyle,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: titleController,
                      hintText: "Title",
                    ),
                    const SizedBox(height: 36.0),
                    SingleChildScrollView(
                      child: TextField(
                        maxLines: null,
                        controller: descriptionController,
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: InputDecoration(
                          hintText: "Create a caption",
                          hintStyle: Theme.of(context).textTheme.titleMedium,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(247, 243, 237, 1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(247, 243, 237, 1),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: getLocation,
                        style: locationButtonStyle,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text('Set Location'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: LocationListTile(
                        location: _locationData.isNotEmpty
                            ? location!
                            : "No Location Selected",
                        onPress: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isCreatingPost)
              const Positioned.fill(
                child: Center(
                  child: ContainerLoadingAnimation(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
