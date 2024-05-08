import 'package:flutter/material.dart';

class ImageWithDimension {
  final Widget image;
  final double height;
  final double width;
  final double aspectRatio;

  ImageWithDimension({
    required this.image,
    required this.height,
    required this.width,
    required this.aspectRatio,
  });
}
