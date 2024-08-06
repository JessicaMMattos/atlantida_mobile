import 'dart:convert';
import 'dart:typed_data';

class DivingSpotReturn {
  late String id;
  late String name;
  late Location location;
  late String? description;
  late double? averageRating;
  late double? averageDifficulty;
  ImageData? image;

  DivingSpotReturn({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.averageRating,
    this.averageDifficulty,
    this.image,
  });

  factory DivingSpotReturn.fromJson(Map<String, dynamic> json) {
    return DivingSpotReturn(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      description: json['description'] ?? '',
      averageRating: json['averageRating']?.toDouble(),
      averageDifficulty: json['averageDifficulty']?.toDouble(),
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location.toJson(),
      'description': description,
      'averageRating': averageRating,
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
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class ImageData {
  final String data;
  final String contentType;

  ImageData({
    required this.data,
    required this.contentType,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      data: json['data'] ?? '',
      contentType: json['contentType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'contentType': contentType,
    };
  }

  Uint8List get decodedData => base64Decode(data);
}
