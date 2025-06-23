import 'package:hadoc_app/models/user_type.dart';

class UserModel {
  final String name;
  final String email;
  final int age;
  final String gender;
  final String phoneNumber;
  final String address;
  final String role; // 'patient' or 'doctor'

  const UserModel({
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    required this.role,
  });

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    int? age,
    String? gender,
    String? phoneNumber,
    String? address,
    String? role,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
    };
  }

  // Create user model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      role: json['role'] as String,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, age: $age, gender: $gender, phoneNumber: $phoneNumber, address: $address, role: $role)';
  }
} 