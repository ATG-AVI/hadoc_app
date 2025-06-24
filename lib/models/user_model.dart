

class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String phoneNumber;
  final String address;
  final String role; // 'patient' or 'doctor'
  final String? licenseNumber; // For doctors
  final String? specialization; // For doctors

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.licenseNumber,
    this.specialization,
  });

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? phoneNumber,
    String? address,
    String? role,
    String? licenseNumber,
    String? specialization,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
    );
  }

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'phone_number': phoneNumber,
      'address': address,
      'role': role,
      'license_number': licenseNumber,
      'specialization': specialization,
    };
  }

  // Create user model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      role: json['role'] as String,
      licenseNumber: json['license_number'] as String?,
      specialization: json['specialization'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, age: $age, gender: $gender, phoneNumber: $phoneNumber, address: $address, role: $role)';
  }
} 