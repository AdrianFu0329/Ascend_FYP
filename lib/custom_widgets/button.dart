import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final IconData icon;
  final IconData pressedIcon;
  final Color defaultColor;
  final Color pressedColor;
  final Function onPressed;
  final bool isLiked;
  final double size;

  const CustomButton({
    super.key,
    required this.icon,
    required this.defaultColor,
    required this.pressedColor,
    required this.onPressed,
    required this.isLiked,
    required this.pressedIcon,
    required this.size,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: widget.isLiked
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              child: Icon(
                widget.pressedIcon,
                color: widget.pressedColor,
                size: widget.size,
              ),
            )
          : AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              child: Icon(
                widget.icon,
                color: widget.defaultColor,
                size: widget.size,
              ),
            ),
    );
  }
}
