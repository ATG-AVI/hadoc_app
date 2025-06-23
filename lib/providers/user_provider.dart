import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadoc_app/models/user_model.dart';

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
    if (_user == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _user = updatedUser;
      await _saveUserToStorage();
      _error = null;
    } catch (e) {
      _error = 'Failed to update user';
      debugPrint('Error updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 