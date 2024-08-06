import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  Future<Map<String, String>> getCityAndState(
      double latitude, double longitude) async {
    final apiKey = dotenv.env['API_KEY_GOOGLE_MAPS'];
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final addressComponents = results[0]['address_components'] as List;
          String city = '';
          String state = '';

          for (var component in addressComponents) {
            final types = component['types'] as List;
            if (types.contains('locality') || types.contains('administrative_area_level_4')) {
              city = component['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              state = component['short_name'];
            }
          }

          // Verificar se a cidade e o estado estão vazios e tentar preenchê-los com base em outros tipos
          if (city.isEmpty) {
            for (var component in addressComponents) {
              final types = component['types'] as List;
              if (types.contains('administrative_area_level_2')) {
                city = component['long_name'];
              }
            }
          }
          if (state.isEmpty) {
            for (var component in addressComponents) {
              final types = component['types'] as List;
              if (types.contains('administrative_area_level_1')) {
                state = component['short_name'];
              }
            }
          }

          return {'name': city, 'state': state};
        }
      }
    }

    return {'name': 'Detalhes não disponíveis', 'state': 'Detalhes não disponíveis'};
  }
}
