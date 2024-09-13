import 'dart:convert';

import 'package:atlantida_mobile/models/certificate.dart';
import 'package:atlantida_mobile/models/certificate_return.dart';
import 'package:http/http.dart';
import '../services/certificate_service.dart';

class CertificateController {
  final CertificateService _certificateService = CertificateService();

  Future<Response> createCertificate(Certificate certificate) async {
    try {
      var response = await _certificateService.createCertificate(certificate);

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to create certificate: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error creating certificate: $error');
    }
  }

  Future<CertificateReturn> getCertificateById(String id) async {
    try {
      var response = await _certificateService.getCertificateById(id);

      if (response.statusCode == 200) {
        return CertificateReturn.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch certificate by ID: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching certificate: $error');
    }
  }

  Future<CertificateReturn> updateCertificate(String id, Certificate certificate) async {
    try {
      var response = await _certificateService.updateCertificate(id, certificate);

      if (response.statusCode == 200) {
        return CertificateReturn.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update certificate: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error updating certificate: $error');
    }
  }

  Future<void> deleteCertificate(String id) async {
    try {
      var response = await _certificateService.deleteCertificate(id);

      if (response.statusCode == 204) {
        // Certificate deleted successfully
      } else {
        throw Exception('Failed to delete certificate: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error deleting certificate: $error');
    }
  }

  Future<List<CertificateReturn>> getCertificatesByToken() async {
    try {
      var response = await _certificateService.getCertificatesByToken();

      if (response.statusCode == 200) {
        List<dynamic> certificatesJson = jsonDecode(response.body);
        return certificatesJson.map((json) => CertificateReturn.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch certificates: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching certificates: $error');
    }
  }

  Future<List<CertificateReturn>> getExpiredCertificates() async {
    try {
      var response = await _certificateService.getExpiredCertificates();

      if (response.statusCode == 200) {
        List<dynamic> expiredCertificatesJson = jsonDecode(response.body);
        return expiredCertificatesJson.map((json) => CertificateReturn.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch expired certificates: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching expired certificates: $error');
    }
  }
}
