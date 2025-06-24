import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:io';
import '../models/user_model.dart';
import '../models/chat_message.dart';
import '../models/analysis_result.dart';
import 'ecg_analysis_service.dart';

class ProfileIncompleteException implements Exception {
  final String message;
  ProfileIncompleteException(this.message);
}

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL and Anon Key must be provided in .env file');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Authentication Methods
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    String? licenseNumber, // For doctors
    String? specialization, // For doctors
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in database
        final userData = {
          'id': response.user!.id,
          'email': email,
          'name': name,
          'role': role,
          'age': age,
          'gender': gender,
          'phone_number': phoneNumber,
          'address': address,
          'created_at': DateTime.now().toIso8601String(),
        };

        if (role == 'doctor') {
          userData['license_number'] = licenseNumber ?? '';
          userData['specialization'] = specialization ?? '';
        }

        await client.from('users').insert(userData);

        return UserModel(
          id: response.user!.id,
          name: name,
          email: email,
          age: age,
          gender: gender,
          phoneNumber: phoneNumber,
          address: address,
          role: role,
          licenseNumber: licenseNumber,
          specialization: specialization,
        );
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG: Starting sign in for email: $email');
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('DEBUG: Auth response success: ${response.user != null}');
      print('DEBUG: User ID: ${response.user?.id}');

      if (response.user != null) {
        // Fetch user profile from database
        print('DEBUG: Fetching user profile from database...');
        final userDataList = await client
            .from('users')
            .select()
            .eq('id', response.user!.id);

        print('DEBUG: User data list length: ${userDataList.length}');
        print('DEBUG: User data: $userDataList');

        if (userDataList.isEmpty) {
          print('DEBUG: No user profile found, throwing ProfileIncompleteException');
          throw ProfileIncompleteException('PROFILE_INCOMPLETE');
        }

        final userData = userDataList.first;
        print('DEBUG: User data fields: ${userData.keys.toList()}');
        print('DEBUG: name: ${userData['name']}');
        print('DEBUG: age: ${userData['age']}');
        print('DEBUG: gender: ${userData['gender']}');
        print('DEBUG: phone_number: ${userData['phone_number']}');
        print('DEBUG: address: ${userData['address']}');

        // Check if essential profile fields are missing
        if (userData['name'] == null || 
            userData['age'] == null || 
            userData['gender'] == null ||
            userData['phone_number'] == null ||
            userData['address'] == null) {
          print('DEBUG: Essential profile fields missing, throwing ProfileIncompleteException');
          throw ProfileIncompleteException('PROFILE_INCOMPLETE');
        }

        print('DEBUG: Profile complete, creating UserModel');
        return UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          age: userData['age'],
          gender: userData['gender'],
          phoneNumber: userData['phone_number'],
          address: userData['address'],
          role: userData['role'],
          licenseNumber: userData['license_number'],
          specialization: userData['specialization'],
        );
      }
    } on ProfileIncompleteException {
      print('DEBUG: ProfileIncompleteException caught, rethrowing');
      rethrow;
    } catch (e) {
      print('DEBUG: Other exception caught: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      throw Exception('Sign in failed: $e');
    }
    print('DEBUG: Sign in returning null');
    return null;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<UserModel?> updateUserProfile({
    required String userId,
    required String name,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      // Get current auth user to get email and role info
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if user record exists
      final existingUser = await client
          .from('users')
          .select()
          .eq('id', userId);

      final userData = {
        'id': userId,
        'email': authUser.email,
        'name': name,
        'age': age,
        'gender': gender,
        'phone_number': phoneNumber,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Determine role if not set
      if (existingUser.isEmpty) {
        // For new users, we need to determine role somehow
        // We'll use specialization/licenseNumber presence to infer role
        userData['role'] = (licenseNumber != null || specialization != null) ? 'doctor' : 'patient';
        userData['created_at'] = DateTime.now().toIso8601String();
      }

      if (licenseNumber != null) {
        userData['license_number'] = licenseNumber;
      }
      if (specialization != null) {
        userData['specialization'] = specialization;
      }

      if (existingUser.isEmpty) {
        // Insert new user record
        await client.from('users').insert(userData);
      } else {
        // Update existing user record
        await client
            .from('users')
            .update(userData)
            .eq('id', userId);
      }

      // Fetch updated user data
      final updatedUserData = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(updatedUserData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // File Upload and Analysis
  Future<String> uploadFile(PlatformFile file) async {
    try {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      await client.storage
          .from('medical-files')
          .uploadBinary(fileName, bytes);

      return fileName;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  Future<String> getFileUrl(String fileName) async {
    return client.storage
        .from('medical-files')
        .getPublicUrl(fileName);
  }

  Future<AnalysisResult> analyzeFile({
    required PlatformFile file,
    required String userId,
  }) async {
    try {
      // Get user data for enhanced analysis
      Map<String, dynamic>? patientData;
      try {
        final userData = await client
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        patientData = {
          'age': userData['age'],
          'gender': userData['gender'],
          'role': userData['role'],
        };
      } catch (e) {
        // Continue without patient data if unavailable
        patientData = null;
      }

      // Use the comprehensive ECG analysis service
      final analysisResult = await ECGAnalysisService.performComprehensiveAnalysis(
        file: file,
        userId: userId,
        patientData: patientData,
      );

      // Store analysis result in database (let database generate the ID)
      final analysisData = {
        'user_id': analysisResult.userId,
        'file_name': analysisResult.fileName,
        'file_type': analysisResult.fileType,
        'analysis_result': analysisResult.analysisResult,
        'confidence_score': analysisResult.confidenceScore,
        'created_at': analysisResult.createdAt.toIso8601String(),
      };

      final insertedData = await client
          .from('analysis_results')
          .insert(analysisData)
          .select()
          .single();

      // Update the analysis result with the database-generated ID
      return AnalysisResult(
        id: insertedData['id'].toString(),
        userId: analysisResult.userId,
        fileName: analysisResult.fileName,
        fileType: analysisResult.fileType,
        analysisResult: analysisResult.analysisResult,
        confidenceScore: analysisResult.confidenceScore,
        createdAt: analysisResult.createdAt,
      );
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }



  // Chat Methods
  Future<List<ChatMessage>> getChatMessages({
    required String userId,
    required String otherUserId,
  }) async {
    try {
      final response = await client
          .from('chat_messages')
          .select('*, sender:users!sender_id(name, role)')
          .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
          .order('created_at');

      return response.map<ChatMessage>((message) => ChatMessage.fromJson(message)).toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      await client.from('chat_messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<UserModel>> getDoctors() async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('role', 'doctor');

      return response.map<UserModel>((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  Future<List<UserModel>> getPatients() async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('role', 'patient');

      return response.map<UserModel>((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to fetch patients: $e');
    }
  }

  Future<List<AnalysisResult>> getUserAnalyses(String userId) async {
    try {
      final response = await client
          .from('analysis_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<AnalysisResult>((analysis) => AnalysisResult.fromJson(analysis)).toList();
    } catch (e) {
      throw Exception('Failed to fetch analyses: $e');
    }
  }
} 