class UserModel {
  final int? id;
  final String name;
  final double height;
  final double weight;
  final int age;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      height: map['height'],
      weight: map['weight'],
      age: map['age'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}