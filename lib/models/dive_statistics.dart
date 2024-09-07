class DiveStatistics {
  late int totalDives;
  late double totalDepth;
  late double averageDepth;
  late double averageBottomTime;
  String? mostCommonWaterBody;
  String? mostCommonWeatherCondition;
  String? userId;

  DiveStatistics({
    required this.totalDives,
    required this.averageDepth,
    required this.averageBottomTime,
    this.mostCommonWaterBody,
    this.mostCommonWeatherCondition,
    this.userId,
  });

  factory DiveStatistics.fromJson(Map<String, dynamic> json) {
    return DiveStatistics(
      totalDives: json['totalDives'] ?? 0,
      averageDepth: double.tryParse(json['averageDepth']?.toString() ?? '0.00') ?? 0.00,
      averageBottomTime: json['averageBottomTime']?.toDouble() ?? 0,
      mostCommonWaterBody: json['mostCommonWaterBody'] as String?,
      mostCommonWeatherCondition: json['mostCommonWeatherCondition'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDives': totalDives,
      'averageDepth': averageDepth,
      'averageBottomTime': averageBottomTime,
      'mostCommonWaterBody': mostCommonWaterBody,
      'mostCommonWeatherCondition': mostCommonWeatherCondition,
      'userId': userId,
    };
  }
}
