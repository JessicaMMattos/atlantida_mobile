import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/address_service.dart';
import '../models/address.dart';

class AddressController {
  final AddressService _addressService = AddressService();

  Future<http.Response> createAddress(BuildContext context, Address address) async {
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

  Future<Address> getAddressById(BuildContext context, String id) async {
    try {
      var response = await _addressService.getAddressById(id);

      if (response.statusCode == 200) {
        return Address.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch address: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<http.Response> updateAddress(BuildContext context, String id, Address address) async {
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

  Future<Address?> getAddressByUserId(BuildContext context, String userId) async {
    try {
      var response = await _addressService.getAddressByUserId(userId);

      if (response.statusCode == 200) {
        return Address.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch address by user ID: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
