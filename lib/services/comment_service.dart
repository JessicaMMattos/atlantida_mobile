import 'dart:convert';
import 'package:atlantida_mobile/models/comment_return.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/comment.dart';

class CommentService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/comments';
  final String baseUrlByDivingSpotId = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api';
  final String baseUrlByUserToken = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/commentsByUserToken';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> createComment(Comment comment) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode(comment.toJson()),
    );
    return response;
  }

  Future<List<CommentReturn>> getCommentsByDivingSpotId(String divingSpotId) async {
    final response = await http.get(
      Uri.parse('$baseUrlByDivingSpotId/$divingSpotId/comments'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CommentReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments for diving spot');
    }
  }

  Future<CommentReturn> getCommentById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      return CommentReturn.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load comment');
    }
  }

  Future<http.Response> updateComment(String id, Comment comment) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
      body: jsonEncode(comment.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteComment(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );
    return response;
  }

  Future<List<CommentReturn>> getCommentsByUserToken() async {
    final response = await http.get(
      Uri.parse(baseUrlByUserToken),
      headers: {
        'Authorization': 'Bearer ${await _secureStorage.read(key: 'authToken')}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CommentReturn.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments by user token');
    }
  }
}
