import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/certificate.dart';

class CertificateService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/certificates';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> createCertificate(Certificate certificate) async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(certificate.toJson()),
    );

    return response;
  }

  Future<http.Response> getCertificateById(String id) async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> updateCertificate(String id, Certificate certificate) async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(certificate.toJson()),
    );

    return response;
  }

  Future<http.Response> deleteCertificate(String id) async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getCertificatesByToken() async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getExpiredCertificates() async {
    String? token = await _secureStorage.read(key: 'authToken');

    final response = await http.post(
      Uri.parse('$baseUrl/expired'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
