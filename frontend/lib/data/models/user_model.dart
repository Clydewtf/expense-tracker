class UserModel {
  final int id;
  final String email;
  final String defaultCurrency;

  UserModel({
    required this.id,
    required this.email,
    required this.defaultCurrency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      defaultCurrency: json['default_currency'] as String,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'email': email,
      'default_currency': defaultCurrency,
    };
}