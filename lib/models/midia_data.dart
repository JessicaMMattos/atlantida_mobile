import 'dart:convert';
import 'dart:typed_data';

class ImageData {
  final String data;
  final String contentType;

  ImageData({
    required this.data,
    required this.contentType,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      data: json['data'] ?? '',
      contentType: json['contentType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'contentType': contentType,
    };
  }

  Uint8List get decodedData => base64Decode(data);
}
