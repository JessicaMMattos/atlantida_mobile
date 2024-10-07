class DiveStatistics {
  late int totalDives;
  late double totalBottomTime;
  late double totalDepth;
  late double averageDepth;
  late double averageBottomTime;
  String? mostCommonWaterBody;
  String? mostCommonWeatherCondition;
  String? userId;

  DiveStatistics({
    required this.totalDives,
    required this.totalBottomTime,
    required this.averageDepth,
    required this.averageBottomTime,
    this.mostCommonWaterBody,
    this.mostCommonWeatherCondition,
    this.userId,
  });

  factory DiveStatistics.fromJson(Map<String, dynamic> json) {
    return DiveStatistics(
      totalDives: json['totalDives'] ?? 0,
      totalBottomTime: double.tryParse(json['totalBottomTime']?.toString() ?? '0.00') ?? 0.00,
      averageDepth: double.tryParse(json['averageDepth']?.toString() ?? '0.00') ?? 0.00,
      averageBottomTime: double.tryParse(json['averageBottomTime']?.toString() ?? '0.00') ?? 0.00,
      mostCommonWaterBody: json['mostCommonWaterBody'] as String?,
      mostCommonWeatherCondition: json['mostCommonWeatherCondition'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDives': totalDives,
      'totalBottomTime': totalBottomTime,
      'averageDepth': averageDepth,
      'averageBottomTime': averageBottomTime,
      'mostCommonWaterBody': mostCommonWaterBody,
      'mostCommonWeatherCondition': mostCommonWeatherCondition,
      'userId': userId,
    };
  }
}
