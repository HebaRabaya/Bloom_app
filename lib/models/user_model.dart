class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String age;
  final String phone;
  final String bio;
  final String imageUrl;
  final String address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.age,
    required this.phone,
    required this.bio,
    required this.imageUrl,
    required this.address,
  });

  factory UserModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return UserModel(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      age: map['age']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
    );
  }
}
