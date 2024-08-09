class AddressUpdate {
  late String country;
  late String state;
  late String city;
  late String neighborhood;
  late String street;
  late int number;
  String? complement;
  late String postalCode;

  AddressUpdate({
    required this.country,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
    required this.postalCode,
  });

  factory AddressUpdate.fromJson(Map<String, dynamic> json) {
    return AddressUpdate(
      country: json['country'],
      state: json['state'],
      city: json['city'],
      neighborhood: json['neighborhood'],
      street: json['street'],
      number: json['number'],
      complement: json['complement'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'country': country,
      'state': state,
      'city': city,
      'neighborhood': neighborhood,
      'street': street,
      'number': number,
      'postalCode': postalCode,
    };

    if (complement != null) {
      data['complement'] = complement;
    }

    return data;
  }
}
