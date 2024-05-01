import 'package:ascend_fyp/models/media.dart';
import 'package:ascend_fyp/pages/picker_screen.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

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

  Widget displayMedia(List<Media> selectedMedia) {
    if (selectedMedia.isEmpty) {
      return GestureDetector(
        onTap: obtainMedia,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.grey,
          child: const Center(
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.red,
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: selectedMedia.length + 1,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == selectedMedia.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: obtainMedia,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: selectedMedia[index].widget,
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Create'),
              style: buttonStyle,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            displayMedia(_selectedMedias),
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
    );
  }
}
