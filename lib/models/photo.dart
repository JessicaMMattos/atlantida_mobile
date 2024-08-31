
import 'dart:convert';

class Photo {
  late String data;
  late String contentType;

  Photo({
    required this.data,
    required this.contentType,
  });

  Photo.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType'] as String;

    if (json['data'] is Map<String, dynamic>) {
      var dataBuffer = json['data'] as Map<String, dynamic>;
      if (dataBuffer['type'] == 'Buffer') {

        List<int> byteData = List<int>.from(dataBuffer['data']);
        data = base64Encode(byteData);
      } else {
        throw const FormatException('Unexpected data type for photo');
      }
    } else {
      data = json['data'] as String;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['contentType'] = contentType;
    return data;
  }
}