class CommentReturn {
  late String id;
  final int rating;
  final String? comment;
  final List<Photo>? photos;
  final String divingSpotId;
  final String? createdDate;
  final String userId;

  CommentReturn({
    required this.id,
    required this.rating,
    this.comment,
    this.photos,
    required this.divingSpotId,
    required this.userId,
    this.createdDate,
  });

  factory CommentReturn.fromJson(Map<String, dynamic> json) {
    return CommentReturn(
      id: json['_id'],
      rating: json['rating'],
      comment: json['comment'],
      photos: (json['photos'] as List?)
          ?.map((photo) => Photo.fromJson(photo))
          .toList(),
      divingSpotId: json['divingSpotId'],
      userId: json['userId'],
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rating': rating,
      'comment': comment,
      'photos': photos?.map((photo) => photo.toJson()).toList(),
      'divingSpotId': divingSpotId,
      'userId': userId,
      'createdDate': createdDate,
    };
  }
}

class Photo {
  final String data;
  final String contentType;

  Photo({required this.data, required this.contentType});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      data: json['data'],
      contentType: json['contentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'contentType': contentType,
    };
  }
}
