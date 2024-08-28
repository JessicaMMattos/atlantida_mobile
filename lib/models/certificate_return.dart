import 'package:atlantida_mobile/models/certificate.dart';

class CertificateReturn {
  late String id;
  late String certificateName;
  late String accreditor;
  late String certificationNumber;
  String? certificationLevel;
  String? issuanceDate;
  String? expirationDate;
  CertificateImage? certificateImage;
  bool isExpired;

  CertificateReturn({
    required this.id,
    required this.certificateName,
    required this.accreditor,
    required this.certificationNumber,
    this.certificationLevel,
    this.issuanceDate,
    this.expirationDate,
    this.certificateImage,
    required this.isExpired,
  });

  factory CertificateReturn.fromJson(Map<String, dynamic> json) {
    return CertificateReturn(
      id: json['_id'],
      certificateName: json['certificateName'],
      accreditor: json['accreditor'],
      certificationNumber: json['certificationNumber'],
      certificationLevel: json['certificationLevel'],
      issuanceDate: json['issuanceDate'],
      expirationDate: json['expirationDate'],
      certificateImage: json['certificateImage'] != null
          ? CertificateImage.fromJson(json['certificateImage'])
          : null,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'certificateName': certificateName,
      'accreditor': accreditor,
      'certificationNumber': certificationNumber,
      'certificationLevel': certificationLevel,
      'issuanceDate': issuanceDate,
      'expirationDate': expirationDate,
      'certificateImage': certificateImage?.toJson(),
      'isExpired': isExpired,
    };
  }
}
