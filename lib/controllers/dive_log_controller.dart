import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/dive_log_service.dart';
import '../models/dive_log.dart';

class DiveLogController {
  final DiveLogService _diveLogService = DiveLogService();

  Future<http.Response> createDiveLog(BuildContext context, DiveLog diveLog) async {
    try {
      var response = await _diveLogService.createDiveLog(diveLog);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to create dive log');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DiveLog>> getDiveLogsByToken(BuildContext context) async {
    try {
      return await _diveLogService.getDiveLogsByToken();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DiveLog>> getDiveLogsByDateRange(String startDate, String endDate) async {
    try {
      return await _diveLogService.getDiveLogsByDateRange(startDate, endDate);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DiveLog>> getDiveLogsByTitle(BuildContext context, String title) async {
    try {
      return await _diveLogService.getDiveLogsByTitle(title);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DiveLog>> getDiveLogsByDate(BuildContext context, String date) async {
    try {
      return await _diveLogService.getDiveLogsByDate(date);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<DiveLog>> getDiveLogsByLocation(String locationName) async {
    try {
      return await _diveLogService.getDiveLogsByLocation(locationName);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<DiveLog> getDiveLogById(BuildContext context, String id) async {
    try {
      return await _diveLogService.getDiveLogById(id);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateDiveLog(BuildContext context, String id, DiveLog diveLog) async {
    try {
      var response = await _diveLogService.updateDiveLog(id, diveLog);
      if (response.statusCode == 200) {
        // Mergulho atualizado com sucesso
        // Handle success
      } else {
        throw Exception('Failed to update dive log');
      }
    } catch (error) {
      // Handle error
      throw Exception(error);
    }
  }

  Future<void> deleteDiveLog(BuildContext context, String id) async {
    try {
      var response = await _diveLogService.deleteDiveLog(id);
      if (response.statusCode == 204) {
        // Mergulho deletado com sucesso
        // Handle success
      } else {
        throw Exception('Failed to delete dive log');
      }
    } catch (error) {
      // Handle error
      throw Exception(error);
    }
  }
}
