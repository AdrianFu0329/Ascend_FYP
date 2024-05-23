import 'dart:io';

import 'package:ascend_fyp/pages/set_location_screen.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
  });

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<File> _images = [];
  Map<String, dynamic> _locationData = {};
  String? location;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCreatingPost = false;

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();

    void _showMessage(String message) {
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

    Future<List<String>> uploadImages(String postId) async {
      List<String> imageURLs = [];

      try {
        // Upload each image to Firebase Storage
        for (int i = 0; i < _images.length; i++) {
          final String fileName = '${postId}_$i.jpeg';
          final Reference reference =
              FirebaseStorage.instance.ref().child('posts/$postId/$fileName');
          final UploadTask uploadTask = reference.putFile(_images[i]);
          final TaskSnapshot taskSnapshot = await uploadTask;
          final String downloadURL = await taskSnapshot.ref.getDownloadURL();

          imageURLs.add(downloadURL);
        }
      } catch (error) {
        // Handle error while uploading images
        _showMessage('Error uploading images: $error');
      }

      return imageURLs;
    }

    bool validatePost() {
      if (titleController.text.trim().isEmpty) {
        _showMessage('Please enter a title.');
        return false;
      }

      if (_images.isEmpty) {
        _showMessage('Please select at least one image.');
        return false;
      }

      if (_locationData.isEmpty) {
        _showMessage('Please set a location.');
        return false;
      }

      return true;
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

            final Map<String, dynamic> postData = {
              'postId': postId,
              'title': titleController.text.trim(),
              'description': descriptionController.text.trim(),
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'likes': [],
              'timestamp': Timestamp.now(),
              'location': location,
              'imageURLs': imageURLs,
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

            _showMessage('Post created successfully');

            titleController.clear();
            descriptionController.clear();
            _locationData.clear();
            setState(() {
              _images.clear();
              _isCreatingPost = false;
            });
          } catch (error) {
            _showMessage('Error creating post: $error');
            setState(() {
              _isCreatingPost = false;
            });
          }
        }
      }
    }

    Future<void> getImage() async {
      final pickedImages = await picker.pickMultiImage();

      setState(() {
        int remainingSlots = 10 - _images.length;
        _images.addAll(pickedImages
            .take(remainingSlots)
            .map((pickedImage) => File(pickedImage.path)));
        if (pickedImages.length > remainingSlots) {
          _showMessage("You can only select up to 10 media items.");
        }
      });
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

    TextStyle textStyle = const TextStyle(
      fontSize: 13,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    );

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
        title: Text(
          'Create Post',
          style: Theme.of(context).textTheme.titleLarge!,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Selected Media",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "${_images.length}/10",
                          style: textStyle,
                        )
                      ],
                    ),
                    // Display selected images
                    if (_images.isNotEmpty) ...[
                      SizedBox(
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        _images[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: getImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                    ] else ...[
                      GestureDetector(
                        onTap: getImage,
                        child: Container(
                          width: 100,
                          height: 100,
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
                    ],
                    const SizedBox(height: 36.0),
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
