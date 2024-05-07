import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String title;
  final List<ImageWithDimension> images;
  final List<String> likes;
  final String userId;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;

  Post({
    required this.postId,
    required this.title,
    required this.images,
    required this.likes,
    required this.userId,
    required this.timestamp,
    required this.description,
    required this.coordinates,
  });
}
