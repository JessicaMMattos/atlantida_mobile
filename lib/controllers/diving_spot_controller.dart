import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:http/src/response.dart';
import '../services/diving_spot_service.dart';
import '../models/diving_spot_create.dart';

class DivingSpotController {
  final DivingSpotService _divingSpotService = DivingSpotService();

  Future<Response> createDivingSpot(DivingSpotCreate divingSpot) async {
    try {
      final response = await _divingSpotService.createDivingSpot(divingSpot);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to create diving spot');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DivingSpotReturn>> getAllDivingSpots() async {
    try {
      return await _divingSpotService.getAllDivingSpots();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<DivingSpotReturn> getDivingSpotById(String id) async {
    try {
      return await _divingSpotService.getDivingSpotById(id);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByLocation(double latitude, double longitude) async {
    try {
      return await _divingSpotService.getDivingSpotsByLocation(latitude, longitude);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByName(String name) async {
    try {
      return await _divingSpotService.getDivingSpotsByName(name);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByRating(double rating) async {
    try {
      return await _divingSpotService.getDivingSpotsByRating(rating);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DivingSpotReturn>> getDivingSpotsByDifficulty(double difficulty) async {
    try {
      return await _divingSpotService.getDivingSpotsByDifficulty(difficulty);
    } catch (error) {
      throw Exception(error);
    }
  }
}
