import 'package:atlantida_mobile/screens/first_screen.dart';
// ignore: implementation_imports
import 'package:http/src/response.dart';
import '../services/user_service.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'dart:convert';

class UserController {
  final UserService _userService = UserService();

  Future<Response> createUser(BuildContext context, User user) async {
    try {
      var response = await _userService.createUser(user);

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Response> loginUser(BuildContext context, String email, String password) async {
    try {
      var response = await _userService.loginUser(email, password);

      if (response.statusCode == 200 || response.statusCode == 401) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String> recoverPassword(BuildContext context, String email) async {
    try {
      var response = await _userService.recoverPassword(email);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseBody['message'];
      } else {

        if (responseBody['message'] == 'Usuário não encontrado') {
          return 'Usuário não encontrado.';
        } else {
          throw Exception(response);
        }

      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> findUserByEmail(BuildContext context, String email) async {
    try {
      User? user = await _userService.findUserByEmail(email);

      if (user == null) {
        return false;
      }

      return true;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> findUserByToken() async {
    try {
      return await _userService.findUserByToken();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _userService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()), 
    );
  }
}
