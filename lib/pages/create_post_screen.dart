import 'dart:io';

import 'package:ascend_fyp/widgets/custom_text_field.dart';
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

    Future<void> getImage() async {
      final pickedImages = await picker.pickMultiImage();

      setState(() {
        if (pickedImages != null) {
          int remainingSlots = 10 - _images.length;
          _images.addAll(pickedImages
              .take(remainingSlots)
              .map((pickedImage) => File(pickedImage.path)));
          if (pickedImages.length > remainingSlots) {
            _showMessage("You can only select up to 10 media items.");
          }
        } else {
          debugPrint("No images picked");
        }
      });
    }

    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();

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
              onPressed: () {},
              style: buttonStyle,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 24.0),
              CustomTextField(
                controller: titleController,
                hintText: "Title",
              ),
              const SizedBox(height: 24.0),
              CustomTextField(
                controller: descriptionController,
                hintText: "Description",
              ),
              const SizedBox(height: 24.0),
              CustomTextField(
                controller: locationController,
                hintText: "Location",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
