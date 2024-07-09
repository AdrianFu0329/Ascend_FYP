import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueNotifier<int>? charCountNotifier;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.inputFormatters,
    this.charCountNotifier,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      fontSize: 11,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    );

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
        suffix: ValueListenableBuilder<int>(
          valueListenable: charCountNotifier!,
          builder: (context, value, child) {
            return Text(
              '$value / $maxLength',
              style: textStyle,
            );
          },
        ),
      ),
      cursorColor: const Color.fromRGBO(247, 243, 237, 1),
      inputFormatters: inputFormatters,
    );
  }
}
