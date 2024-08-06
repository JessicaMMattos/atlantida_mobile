class User {
  late String firstName;
  late String lastName;
  late String email;
  late String password;
  late String birthDate;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.birthDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      birthDate: json['birthDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'birthDate': birthDate,
    };
  }
}