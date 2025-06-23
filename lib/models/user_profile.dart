import 'package:hadoc_app/models/user_type.dart';

class UserProfile {
  final String name;
  final String email;
  final UserType role;
  final int age;
  final String gender;
  final String phoneNumber;
  final String address;

  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
  });

  // Dummy data for patient profile
  static const dummyPatientProfile = UserProfile(
    name: 'John Doe',
    email: 'john.doe@example.com',
    role: UserType.patient,
    age: 35,
    gender: 'Male',
    phoneNumber: '+1 234 567 8900',
    address: '123 Health Street, Medical City, MC 12345',
  );

  // Dummy data for doctor profile
  static const dummyDoctorProfile = UserProfile(
    name: 'Dr. Sarah Smith',
    email: 'dr.sarah@example.com',
    role: UserType.doctor,
    age: 42,
    gender: 'Female',
    phoneNumber: '+1 234 567 8901',
    address: '456 Hospital Avenue, Medical City, MC 12345',
  );
} 