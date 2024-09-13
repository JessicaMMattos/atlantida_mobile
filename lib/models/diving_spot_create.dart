import 'package:atlantida_mobile/models/midia_data.dart';

class DivingSpotCreate {
  late String name;
  late Location location;
  late String? description;
  late String waterBody;
  late String? visibility;
  late double? averageRating;
  late double? averageDifficulty;
  ImageData? image;

  DivingSpotCreate({
    required this.name,
    required this.location,
    this.description,
    this.averageRating,
    required this.waterBody,
    this.visibility,
    this.averageDifficulty,
    this.image,
  });

  factory DivingSpotCreate.fromJson(Map<String, dynamic> json) {
    return DivingSpotCreate(
      name: json['name'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      waterBody: json['waterBody'] ?? '',
      visibility: json['visibility'] ?? '',
      description: json['description'] ?? '',
      averageRating: json['averageRating']?.toDouble(),
      averageDifficulty: json['averageDifficulty']?.toDouble(),
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location.toJson(),
      'description': description,
      'averageRating': averageRating,
      'waterBody': waterBody,
      'visibility': visibility,
      'averageDifficulty': averageDifficulty,
      'image': image?.toJson(),
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: (json['coordinates'] as List)
              .map((coord) => coord is num ? coord.toDouble() : 0.0)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
