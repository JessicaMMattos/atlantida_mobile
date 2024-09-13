import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiveStatisticsService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/diveStatistics';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> fetchDiveStatistics(String startDate, String endDate) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode({
        'startDate': startDate,
        'endDate': endDate,
      }),
    );

    return response;
  }
}
