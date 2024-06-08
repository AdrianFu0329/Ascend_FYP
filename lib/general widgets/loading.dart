import 'package:flutter/material.dart';

class ContainerLoadingAnimation extends StatelessWidget {
  const ContainerLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const SizedBox(
            width: 16.0,
            height: 16.0,
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(194, 0, 0, 1),
                  backgroundColor: Color.fromRGBO(247, 243, 237, 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
