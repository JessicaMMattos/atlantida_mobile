import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/dive_statistics_service.dart';
import '../models/dive_statistics.dart';

class DiveStatisticsController {
  final DiveStatisticsService _diveStatisticsService = DiveStatisticsService();

  Future<Object> getDiveStatistics(BuildContext context, String startDate, String endDate) async {
    try {
      var response = await _diveStatisticsService.fetchDiveStatistics(startDate, endDate);
      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return DiveStatistics.fromJson(responseBody);
      } else {
        if (responseBody['message'] == 'Nenhum mergulho encontrado para o período selecionado') {
          return responseBody['message'];
        } else {
          throw Exception('Failed to fetch dive statistics: ${response.body}');
        }
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
