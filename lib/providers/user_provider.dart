import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadoc_app/models/user_model.dart';
import 'package:hadoc_app/services/supabase_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _userKey = 'user_data';
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load user data';
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
      } else {
        await prefs.remove(_userKey);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to save user data';
      debugPrint('Error saving user data: $e');
      notifyListeners();
    }
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    await _saveUserToStorage();
    notifyListeners();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await updateUserProfile(
        name: updatedUser.name,
        age: updatedUser.age,
        gender: updatedUser.gender,
        phoneNumber: updatedUser.phoneNumber,
        address: updatedUser.address,
        licenseNumber: updatedUser.licenseNumber,
        specialization: updatedUser.specialization,
      );

      if (success) {
        _user = updatedUser;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await SupabaseService.instance.signOut();
      _user = null;
      await _saveUserToStorage();
      _error = null;
    } catch (e) {
      _error = 'Failed to logout';
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG: UserProvider signIn called');
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('DEBUG: Calling SupabaseService.signIn');
      final user = await SupabaseService.instance.signIn(
        email: email,
        password: password,
      );

      print('DEBUG: SupabaseService.signIn returned: ${user != null}');
      if (user != null) {
        print('DEBUG: Setting user in provider');
        await setUser(user);
        return true;
      } else {
        print('DEBUG: No user returned, setting error');
        _error = 'Invalid credentials';
        return false;
      }
    } on ProfileIncompleteException catch (e) {
      print('DEBUG: ProfileIncompleteException caught in UserProvider: $e');
      // Let ProfileIncompleteException bubble up to the UI
      rethrow;
    } catch (e) {
      print('DEBUG: Other exception caught in UserProvider: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      _error = e.toString();
      return false;
    } finally {
      print('DEBUG: UserProvider signIn finally block');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await SupabaseService.instance.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        age: age,
        gender: gender,
        phoneNumber: phoneNumber,
        address: address,
        licenseNumber: licenseNumber,
        specialization: specialization,
      );

      if (user != null) {
        await setUser(user);
        return true;
      } else {
        _error = 'Failed to create account';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    required String name,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get current user from Supabase auth
      final currentUser = SupabaseService.instance.client.auth.currentUser;
      if (currentUser == null) {
        _error = 'No authenticated user found';
        return false;
      }

      final user = await SupabaseService.instance.updateUserProfile(
        userId: currentUser.id,
        name: name,
        age: age,
        gender: gender,
        phoneNumber: phoneNumber,
        address: address,
        licenseNumber: licenseNumber,
        specialization: specialization,
      );

      if (user != null) {
        await setUser(user);
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 