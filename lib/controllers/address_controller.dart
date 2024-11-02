import 'dart:convert';
import 'package:atlantida_mobile/models/address_update.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/address_service.dart';
import '../models/address.dart';

class AddressController {
  final AddressService _addressService = AddressService();

  Future<http.Response> createAddress(Address address) async {
    try {
      var response = await _addressService.createAddress(address);

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to create address: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<http.Response> updateAddress(String id, AddressUpdate address) async {
    try {
      var response = await _addressService.updateAddress(id, address);

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to update address: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<http.Response> deleteAddress(BuildContext context, String id) async {
    try {
      var response = await _addressService.deleteAddress(id);

      if (response.statusCode == 204) {
        return response;
      } else {
        throw Exception('Failed to delete address: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Address?> getAddressByUserId(String userId) async {
    try {
      var response = await _addressService.getAddressByUserId(userId);

      List<dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Address.fromJson(jsonResponse[0]);
      } else {
        throw Exception('Failed to fetch address by user ID: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
