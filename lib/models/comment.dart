import 'package:atlantida_mobile/models/comment_return.dart';

class Comment {
  final int rating;
  String? comment;
  List<Photo>? photos;
  final String divingSpotId;

  Comment({
    required this.rating,
    this.comment,
    this.photos,
    required this.divingSpotId
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      rating: json['rating'],
      comment: json['comment'],
      photos: (json['photos'] as List?)
          ?.map((photo) => Photo.fromJson(photo))
          .toList(),
      divingSpotId: json['divingSpotId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'photos': photos?.map((photo) => photo.toJson()).toList(),
      'divingSpotId': divingSpotId
    };
  }

  copyWith({required String comment, required List<Photo> photos, required int rating}) {}
}
