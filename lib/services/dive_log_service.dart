import 'dart:convert';
import 'package:atlantida_mobile/models/dive_log_return.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/dive_log.dart';

class DiveLogService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/diveLogs';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> createDiveLog(DiveLog diveLog) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode(diveLog.toJson()),
    );
    return response;
  }

  Future<List<DiveLogReturn>> getDiveLogsByToken() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      return jsonResponse.map((data) => DiveLogReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<List<DiveLogReturn>> getDiveLogsByDateRange(String startDate, String endDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dateRange'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode({
        'startDate': startDate,
        'endDate': endDate,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DiveLogReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<List<DiveLogReturn>> getDiveLogsByTitle(String title) async {
    final response = await http.get(
      Uri.parse('$baseUrl/title/$title'),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DiveLogReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<List<DiveLogReturn>> getDiveLogsByDate(String date) async {
    final response = await http.post(
      Uri.parse('$baseUrl/date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode({'date': date}),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DiveLogReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<List<DiveLogReturn>> getDiveLogsByLocation(String locationName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/location/$locationName'),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DiveLogReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<DiveLogReturn> getDiveLogById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );

    if (response.statusCode == 200) {
      return DiveLogReturn.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dive log');
    }
  }

  Future<http.Response> updateDiveLog(String id, DiveLog diveLog) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode(diveLog.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteDiveLog(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );
    return response;
  }
}
