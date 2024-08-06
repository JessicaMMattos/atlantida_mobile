import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/users';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    return response;
  }

  Future<http.Response> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String token = responseBody['token'];

      // Store token securely
      await _secureStorage.write(key: 'authToken', value: token);
    }
    return response;
  }

  Future<http.Response> recoverPassword(String email) async {
    final url = Uri.parse('$baseUrl/recoverPassword');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response;
  }

  Future<User?> findUserByEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/email'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse == null || jsonResponse.isEmpty) {
        return null;
      }

      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch user by email: ${response.body}');
    }
  }

  Future<User> findUserByToken() async {
    String? token = await _secureStorage.read(key: 'authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado no armazenamento seguro');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/findUserByToken'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response);
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'authToken');
  }
}