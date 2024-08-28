import 'dart:convert';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  Future<String> generateMapWithMarkers(List<DivingSpotReturn> divingSpots) async {
    final apiKey = dotenv.env['API_KEY_GOOGLE_MAPS'];

    // Carregar o template HTML com JavaScript
    final template = await rootBundle.loadString('assets/map_template.html');

    // Gerar os pontos de mergulho em formato JavaScript
    final markersJs = divingSpots.map((spot) {
      final latitude = spot.location.coordinates[1];
      final longitude = spot.location.coordinates[0];
      final name = spot.name.replaceAll('"', '\\"');
      final description = spot.description?.replaceAll('"', '\\"') ?? 'Sem descrição';

      return '''
        new google.maps.Marker({
          position: {lat: $latitude, lng: $longitude},
          map: map,
          title: "$name",
          label: "$name",
          icon: {
            url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png"
          }
        });
      ''';
    }).join('\n');

    // Substituir as variáveis no template
    final mapHtml = template
        .replaceAll('{{API_KEY}}', apiKey!)
        .replaceAll('{{MARKERS_JS}}', markersJs);

    return mapHtml;
  }
}
