class DiveLog {
  late String title;
  late String divingSpotId;
  late DateTime date;
  late String type;
  late double depth;
  late int bottomTimeInMinutes;
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

  DiveLog({
    required this.title,
    required this.divingSpotId,
    required this.date,
    required this.type,
    required this.depth,
    required this.bottomTimeInMinutes,
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

  DiveLog.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    divingSpotId = json['divingSpotId'];
    date = DateTime.parse(json['date']);
    type = json['type'];
    depth = json['depth'];
    bottomTimeInMinutes = json['bottomTimeInMinutes'];
    waterType = json['waterType'];
    waterBody = json['waterBody'];
    weatherConditions = json['weatherConditions'];
    temperature = json['temperature'] != null ? Temperature.fromJson(json['temperature']) : null;
    visibility = json['visibility'];
    waves = json['waves'];
    current = json['current'];
    surge = json['surge'];
    suit = json['suit'];
    weight = json['weight'];
    additionalEquipment = json['additionalEquipment']?.cast<String>();
    cylinder = json['cylinder'] != null ? Cylinder.fromJson(json['cylinder']) : null;
    rating = json['rating'];
    difficulty = json['difficulty'];
    notes = json['notes'];
    photos = json['photos']?.map((item) => Photo.fromJson(item)).toList().cast<Photo>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['divingSpotId'] = divingSpotId;
    data['date'] = date.toIso8601String();
    data['type'] = type;
    data['depth'] = depth;
    data['bottomTimeInMinutes'] = bottomTimeInMinutes;
    data['waterType'] = waterType;
    data['waterBody'] = waterBody;
    data['weatherConditions'] = weatherConditions;
    if (temperature != null) {
      data['temperature'] = temperature!.toJson();
    }
    data['visibility'] = visibility;
    data['waves'] = waves;
    data['current'] = current;
    data['surge'] = surge;
    data['suit'] = suit;
    data['weight'] = weight;
    data['additionalEquipment'] = additionalEquipment;
    if (cylinder != null) {
      data['cylinder'] = cylinder!.toJson();
    }
    data['rating'] = rating;
    data['difficulty'] = difficulty;
    data['notes'] = notes;
    if (photos != null) {
      data['photos'] = photos!.map((item) => item.toJson()).toList();
    }
    return data;
  }
}

class Temperature {
  late double air;
  late double surface;
  late double bottom;

  Temperature({
    required this.air,
    required this.surface,
    required this.bottom,
  });

  Temperature.fromJson(Map<String, dynamic> json) {
    air = json['air'];
    surface = json['surface'];
    bottom = json['bottom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['air'] = air;
    data['surface'] = surface;
    data['bottom'] = bottom;
    return data;
  }
}

class Cylinder {
  late String type;
  late double size;
  late String gasMixture;
  late double initialPressure;
  late double finalPressure;
  late double usedAmount;

  Cylinder({
    required this.type,
    required this.size,
    required this.gasMixture,
    required this.initialPressure,
    required this.finalPressure,
    required this.usedAmount,
  });

  Cylinder.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    size = json['size'];
    gasMixture = json['gasMixture'];
    initialPressure = json['initialPressure'];
    finalPressure = json['finalPressure'];
    usedAmount = json['usedAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['size'] = size;
    data['gasMixture'] = gasMixture;
    data['initialPressure'] = initialPressure;
    data['finalPressure'] = finalPressure;
    data['usedAmount'] = usedAmount;
    return data;
  }
}

class Photo {
  late String data;
  late String contentType;

  Photo({
    required this.data,
    required this.contentType,
  });

  Photo.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    contentType = json['contentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['contentType'] = contentType;
    return data;
  }
}
