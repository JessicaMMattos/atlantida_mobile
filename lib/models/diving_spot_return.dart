import 'package:atlantida_mobile/models/diving_spot_create.dart';
import 'package:atlantida_mobile/models/midia_data.dart';

class DivingSpotReturn {
  late String id;
  late String name;
  late Location location;
  late String waterBody;
  late String? visibility;
  late String? description;
  late double? averageRating;
  late double? averageDifficulty;
  late double? numberOfComments;
  ImageData? image;

  DivingSpotReturn({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.waterBody,
    this.visibility,
    this.averageRating,
    this.averageDifficulty,
    this.numberOfComments,
    this.image,
  });

  factory DivingSpotReturn.fromJson(Map<String, dynamic> json) {
    return DivingSpotReturn(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      waterBody: json['waterBody'] ?? '',
      visibility: json['visibility'] ?? '',
      description: json['description'] ?? '',
      averageRating: json['averageRating']?.toDouble(),
      averageDifficulty: json['averageDifficulty']?.toDouble(),
      numberOfComments: json['numberOfComments']?.toDouble(),
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location.toJson(),
      'description': description,
      'waterBody': waterBody,
      'visibility': visibility,
      'averageRating': averageRating,
      'averageDifficulty': averageDifficulty,
      'numberOfComments': numberOfComments,
      'image': image?.toJson(),
    };
  }
}

