import 'package:atlantida_mobile/models/comment_return.dart';

import '../services/comment_service.dart';
import '../models/comment.dart';

class CommentController {
  final CommentService _commentService = CommentService();

  Future<void> createComment(Comment comment) async {
    try {
      final response = await _commentService.createComment(comment);
      if (response.statusCode != 201) {
        throw Exception('Failed to create comment');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<CommentReturn>> getCommentsByDivingSpotId(String divingSpotId) async {
    try {
      return await _commentService.getCommentsByDivingSpotId(divingSpotId);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<CommentReturn> getCommentById(String id) async {
    try {
      return await _commentService.getCommentById(id);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateComment(String id, Comment comment) async {
    try {
      final response = await _commentService.updateComment(id, comment);
      if (response
      .statusCode != 200) {
        throw Exception('Failed to update comment');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      final response = await _commentService.deleteComment(id);
      if (response.statusCode != 204) {
        throw Exception('Failed to delete comment');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<CommentReturn>> getCommentsByUserToken() async {
    try {
      return await _commentService.getCommentsByUserToken();
    } catch (error) {
      throw Exception(error);
    }
  }
}
