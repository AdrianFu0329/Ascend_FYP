import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final String username;
  final String email;
  final String description;
  const ProfileDetailsScreen({
    super.key,
    required this.username,
    required this.email,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    bool isEditButtonEnabled() {
      return usernameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Edit Profile Details',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              CustomTextField(
                controller: usernameController,
                hintText: username,
              ),
              const SizedBox(height: 35),
              CustomTextField(
                controller: emailController,
                hintText: email,
              ),
              const SizedBox(height: 35),
              SingleChildScrollView(
                child: TextField(
                  maxLines: null,
                  controller: descriptionController,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(
                    hintText: description,
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
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        highlightColor: Colors.greenAccent,
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                  color: const Color.fromRGBO(247, 243, 237, 1),
                                  width: !isEditButtonEnabled() ? 1.0 : 3.0),
                            ),
                          ),
                        ),
                        onPressed: !isEditButtonEnabled() ? null : () {},
                        icon: Image.asset(
                          'lib/assets/images/register.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
