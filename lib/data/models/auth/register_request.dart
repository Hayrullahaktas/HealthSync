class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final double height;
  final double weight;
  final int age;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'height': height,
    'weight': weight,
    'age': age,
  };
}