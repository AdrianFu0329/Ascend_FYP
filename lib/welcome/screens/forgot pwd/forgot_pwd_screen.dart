import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/general%20widgets/custom_text_field.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:flutter/material.dart';

class ForgotPwdScreen extends StatefulWidget {
  const ForgotPwdScreen({super.key});

  @override
  State<ForgotPwdScreen> createState() => _ForgotPwdScreenState();
}

class _ForgotPwdScreenState extends State<ForgotPwdScreen> {
  bool isSending = false;
  TextEditingController forgotPwdController = TextEditingController();
  ValueNotifier<bool> isButtonEnabled = ValueNotifier<bool>(false);

  void _showMessage(String message, bool confirm,
      {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
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
                if (confirm) {
                  if (onYesPressed != null) {
                    onYesPressed();
                  }
                } else {
                  if (onOKPressed != null) {
                    onOKPressed();
                  }
                }
              },
              child: Text(
                confirm ? 'Yes' : 'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            confirm
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    forgotPwdController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    forgotPwdController.removeListener(_updateButtonState);
    forgotPwdController.dispose();
    isButtonEnabled.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    isButtonEnabled.value = forgotPwdController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle sendEmailBtnStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 14,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        const Color.fromRGBO(247, 243, 237, 1),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
            color: Color.fromRGBO(247, 243, 237, 1),
            width: 1.5,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Forgot Password',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  controller: forgotPwdController,
                  hintText: "Account Email",
                ),
                const SizedBox(height: 35),
                ValueListenableBuilder<bool>(
                  valueListenable: isButtonEnabled,
                  builder: (context, isEnabled, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isEnabled
                            ? () async {
                                setState(() {
                                  isSending = true;
                                });
                                final result = await sendPasswordResetLink(
                                  forgotPwdController.text,
                                );

                                debugPrint("Result: $result");

                                if (result) {
                                  _showMessage(
                                    "Password Reset Email has been sent! Please follow the instructions in the sent email!",
                                    false,
                                    onOKPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                } else {
                                  _showMessage(
                                    "Password Reset Email was not sent due to an error. Please try again...",
                                    false,
                                  );
                                }

                                setState(() {
                                  isSending = false;
                                });
                              }
                            : null,
                        style: sendEmailBtnStyle,
                        icon: const Icon(Icons.mail_outline),
                        label: const Text("Send Reset Password Email"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (isSending)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: ContainerLoadingAnimation(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
