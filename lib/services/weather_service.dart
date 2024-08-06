import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String? apiKey = dotenv.env['API_KEY'];
  final String baseUrl = 'https://api.openweathermap.org/data/3.0';

  Future<Map<String, dynamic>> getWeatherForecast(double lat, double lon) async {
    final url = '$baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly&units=metric&lang=pt_br&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
