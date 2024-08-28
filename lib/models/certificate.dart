class Certificate {
  late String certificateName;
  late String accreditor;
  late String certificationNumber;
  String? certificationLevel;
  String? issuanceDate;
  String? expirationDate;
  CertificateImage? certificateImage;

  Certificate({
    required this.certificateName,
    required this.accreditor,
    required this.certificationNumber,
    this.certificationLevel,
    this.issuanceDate,
    this.expirationDate,
    this.certificateImage,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateName: json['certificateName'],
      accreditor: json['accreditor'],
      certificationNumber: json['certificationNumber'],
      certificationLevel: json['certificationLevel'],
      issuanceDate: json['issuanceDate'],
      expirationDate: json['expirationDate'],
      certificateImage: json['certificateImage'] != null
          ? CertificateImage.fromJson(json['certificateImage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'certificateName': certificateName,
      'accreditor': accreditor,
      'certificationNumber': certificationNumber,
    };
    if (certificationLevel != null) {
      data['certificationLevel'] = certificationLevel;
    }
    if (issuanceDate != null) {
      data['issuanceDate'] = issuanceDate;
    }
    if (expirationDate != null) {
      data['expirationDate'] = expirationDate;
    }
    if (certificateImage != null) {
      data['certificateImage'] = certificateImage!.toJson();
    }
    return data;
  }
}

class CertificateImage {
  late String data;
  late String contentType;

  CertificateImage({
    required this.data,
    required this.contentType,
  });

  factory CertificateImage.fromJson(Map<String, dynamic> json) {
    return CertificateImage(
      data: json['data'],
      contentType: json['contentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'contentType': contentType,
    };
  }
}
