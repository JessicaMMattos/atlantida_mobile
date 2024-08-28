class UserReturn {
  late String id;
  late String firstName;
  late String lastName;
  late String email;
  late String password;
  late String birthDate;

  UserReturn({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.birthDate,
  });

  factory UserReturn.fromJson(Map<String, dynamic> json) {
    return UserReturn(
      id: json['_id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      birthDate: json['birthDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'birthDate': birthDate,
    };
  }
}
