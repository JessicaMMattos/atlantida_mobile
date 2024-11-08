import 'dart:convert';
import 'package:atlantida_mobile/models/address_update.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/address.dart';

class AddressService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/api/addresses';

  Future<http.Response> createAddress(Address address) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(address.toJson()),
    );

    return response;
  }

  Future<http.Response> updateAddress(String id, AddressUpdate address) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(address.toJson()),
    );

    return response;
    
  }

  Future<http.Response> deleteAddress(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    return response;
  }

  Future<http.Response> getAddressByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL'] ?? 'http://localhost:3000'}/addresses/user/$userId'),
    );

    return response;
  }
}
