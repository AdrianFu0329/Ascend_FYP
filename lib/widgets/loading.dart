import 'package:flutter/material.dart';

class CustomLoadingAnimation extends StatelessWidget {
  const CustomLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            color: Color.fromRGBO(194, 0, 0, 1),
            backgroundColor: Color.fromRGBO(247, 243, 237, 1),
          ),
        ),
      ),
    );
  }
}
