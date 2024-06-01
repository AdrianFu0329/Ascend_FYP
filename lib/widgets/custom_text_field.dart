import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.titleMedium,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.titleMedium,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(247, 243, 237, 1),
            width: 2.5,
          ),
        ),
      ),
      cursorColor: const Color.fromRGBO(247, 243, 237, 1),
    );
  }
}
