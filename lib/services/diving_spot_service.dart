import 'dart:convert';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/diving_spot_create.dart';

class DivingSpotService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/divingSpots';
  final String baseUrlByLocation = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/divingSpotsByLocation';
  final String baseUrlByName = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/divingSpotsByName';
  final String baseUrlByRating = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/divingSpotsByRating';
  final String baseUrlByDifficulty = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/divingSpotsByDifficulty';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<DivingSpotReturn>> getAllDivingSpots() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DivingSpotReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load diving spots');
    }
  }

  Future<http.Response> createDivingSpot(DivingSpotCreate divingSpot) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode(divingSpot.toJson()),
    );
    return response;
  }

  Future<DivingSpotReturn> getDivingSpotById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      return DivingSpotReturn.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load diving spot');
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByLocation(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$baseUrlByLocation?latitude=$latitude&longitude=$longitude'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DivingSpotReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load diving spots by location');
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrlByName?name=$name'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DivingSpotReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load dive logs');
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByRating(double rating) async {
    final response = await http.get(
      Uri.parse('$baseUrlByRating?rating=$rating'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DivingSpotReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load diving spots by rating');
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByDifficulty(double difficulty) async {
    final response = await http.get(
      Uri.parse('$baseUrlByDifficulty?difficulty=$difficulty'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => DivingSpotReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load diving spots by difficulty');
    }
  }
}
