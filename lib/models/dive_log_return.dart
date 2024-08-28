import 'package:atlantida_mobile/models/dive_log.dart';

class DiveLogReturn {
  late String id;
  late String title;
  late String divingSpotId;
  late String date;
  late String type;
  double? depth;
  int? bottomTimeInMinutes;
  String? waterType;
  String? waterBody;
  String? weatherConditions;
  Temperature? temperature;
  String? visibility;
  String? waves;
  String? current;
  String? surge;
  String? suit;
  String? weight;
  List<String>? additionalEquipment;
  Cylinder? cylinder;
  int? rating;
  int? difficulty;
  String? notes;
  List<Photo>? photos;

  DiveLogReturn({
    required this.id,
    required this.title,
    required this.divingSpotId,
    required this.date,
    required this.type,
    this.depth,
    this.bottomTimeInMinutes,
    this.waterType,
    this.waterBody,
    this.weatherConditions,
    this.temperature,
    this.visibility,
    this.waves,
    this.current,
    this.surge,
    this.suit,
    this.weight,
    this.additionalEquipment,
    this.cylinder,
    this.rating,
    this.difficulty,
    this.notes,
    this.photos,
  });

  DiveLogReturn.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as String;
    title = json['title'] as String;
    divingSpotId = json['divingSpotId'] as String;
    date = json['date'] as String;
    type = json['type'] as String;
    depth = (json['depth'] as num?)?.toDouble();
    bottomTimeInMinutes = json['bottomTimeInMinutes'] as int?;
    waterType = json['waterType'] as String?;
    waterBody = json['waterBody'] as String?;
    weatherConditions = json['weatherConditions'] as String?;
    temperature = json['temperature'] != null 
        ? Temperature.fromJson(json['temperature'] as Map<String, dynamic>) 
        : null;
    visibility = json['visibility'] as String?;
    waves = json['waves'] as String?;
    current = json['current'] as String?;
    surge = json['surge'] as String?;
    suit = json['suit'] as String?;
    weight = json['weight'] as String?;
    additionalEquipment = (json['additionalEquipment'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    cylinder = json['cylinder'] != null 
        ? Cylinder.fromJson(json['cylinder'] as Map<String, dynamic>) 
        : null;
    rating = json['rating'] != null ? (json['rating'] as num).toInt() : null;
    difficulty = json['difficulty'] != null ? (json['difficulty'] as num).toInt() : null;
    notes = json['notes'] as String?;
    photos = (json['photos'] as List<dynamic>?)
        ?.map((item) => Photo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    data['_id'] = id;
    data['title'] = title;
    data['divingSpotId'] = divingSpotId;
    data['date'] = date;
    data['type'] = type;
    if (depth != null) data['depth'] = depth;
    if (bottomTimeInMinutes != null) data['bottomTimeInMinutes'] = bottomTimeInMinutes;
    if (waterType != null) data['waterType'] = waterType;
    if (waterBody != null) data['waterBody'] = waterBody;
    if (weatherConditions != null) data['weatherConditions'] = weatherConditions;
    if (temperature != null) data['temperature'] = temperature!.toJson();
    if (visibility != null) data['visibility'] = visibility;
    if (waves != null) data['waves'] = waves;
    if (current != null) data['current'] = current;
    if (surge != null) data['surge'] = surge;
    if (suit != null) data['suit'] = suit;
    if (weight != null) data['weight'] = weight;
    if (additionalEquipment != null) data['additionalEquipment'] = additionalEquipment;
    if (cylinder != null) data['cylinder'] = cylinder!.toJson();
    if (rating != null) data['rating'] = rating;
    if (difficulty != null) data['difficulty'] = difficulty;
    if (notes != null) data['notes'] = notes;
    if (photos != null && photos!.isNotEmpty) {
      data['photos'] = photos!.map((item) => item.toJson()).toList();
    }
    
    return data;
  }
}