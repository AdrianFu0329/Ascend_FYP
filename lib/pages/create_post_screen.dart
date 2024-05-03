import 'dart:io';

import 'package:ascend_fyp/widgets/custom_text_field.dart';
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
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    int mediaCount = 0;

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

    Future<List<String>> _uploadImages(String postId) async {
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

    Future<void> _createPost() async {
      if (_formKey.currentState!.validate()) {
        try {
          final String postId =
              FirebaseFirestore.instance.collection('posts').doc().id;

          // Upload images to Firebase Storage
          List<String> imageURLs = await _uploadImages(postId);

          final Map<String, dynamic> postData = {
            'postId': postId,
            'title': titleController.text.trim(),
            'description': descriptionController.text.trim(),
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'likes': [],
            'timestamp': Timestamp.now(),
            'latitude': "",
            'longitude': "",
            'imageURLs': imageURLs,
          };

          // Add the post document to Firestore
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .set(postData);

          _showMessage('Post created successfully');

          titleController.clear();
          descriptionController.clear();
          locationController.clear();
          setState(() {
            _images.clear();
          });
        } catch (error) {
          _showMessage('Error creating post: $error');
        }
      }
    }

    Future<void> getImage() async {
      final pickedImages = await picker.pickMultiImage();

      setState(() {
        if (pickedImages != null) {
          int remainingSlots = 10 - _images.length;
          _images.addAll(pickedImages
              .take(remainingSlots)
              .map((pickedImage) => File(pickedImage.path)));
          mediaCount = _images.length;
          if (pickedImages.length > remainingSlots) {
            _showMessage("You can only select up to 10 media items.");
          }
        } else {
          debugPrint("No images picked");
        }
      });
    }

    TextStyle textStyle = const TextStyle(
      fontSize: 13,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    );

    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
              onPressed: _createPost,
              style: buttonStyle,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: SingleChildScrollView(
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
                      "$mediaCount/10",
                      style: textStyle,
                    )
                  ],
                ),
                // Display selected images
                if (_images.isNotEmpty) ...[
                  SizedBox(
                    height: 150,
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
                  // Add button to select more images
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
                      hintText: "Description",
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
                CustomTextField(
                  controller: locationController,
                  hintText: "Location",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
