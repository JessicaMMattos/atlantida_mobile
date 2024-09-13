class Address {
String? id;
  late String country;
  late String state;
  late String city;
  late String neighborhood;
  late String street;
  late int number;
  String? complement;
  late String postalCode;
  late String userId;

  Address({
    this.id,
    required this.country,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
    required this.postalCode,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      neighborhood: json['neighborhood'],
      street: json['street'],
      number: json['number'],
      complement: json['complement'],
      postalCode: json['postalCode'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'country': country,
      'state': state,
      'city': city,
      'neighborhood': neighborhood,
      'street': street,
      'number': number,
      'postalCode': postalCode,
      'userId': userId,
    };

    if (complement != null) {
      data['complement'] = complement;
    }

    return data;
  }
}
