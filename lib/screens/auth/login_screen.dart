import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hadoc_app/providers/user_provider.dart';
import 'package:hadoc_app/utils/theme.dart';
import 'package:hadoc_app/services/supabase_service.dart';
import 'package:hadoc_app/screens/auth/user_details_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedRole;
  
  const LoginScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      print('DEBUG: Login form validated');
      setState(() {
        _isLoading = true;
      });

      try {
        print('DEBUG: Getting UserProvider');
        final userProvider = context.read<UserProvider>();
        
        print('DEBUG: Calling userProvider.signIn');
        final success = await userProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print('DEBUG: SignIn success: $success');
        if (mounted) {
          if (success && userProvider.user != null) {
            print('DEBUG: Login successful, navigating to dashboard');
            // Navigate based on role
            Navigator.pushReplacementNamed(
              context,
              userProvider.user!.role == 'patient' ? '/patient' : '/doctor',
            );
          } else {
            print('DEBUG: Login failed, showing error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(userProvider.error ?? 'Login failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on ProfileIncompleteException catch (e) {
        print('DEBUG: ProfileIncompleteException caught in LoginScreen: $e');
        if (mounted) {
          // Get the authenticated user's email and role from Supabase Auth
          final authUser = SupabaseService.instance.client.auth.currentUser;
          print('DEBUG: Auth user: ${authUser?.email}');
          if (authUser != null) {
            print('DEBUG: Navigating to UserDetailsScreen');
            // Navigate to user details screen to complete profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(
                  email: authUser.email ?? _emailController.text.trim(),
                  role: widget.selectedRole,
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('DEBUG: Other exception caught in LoginScreen: $e');
        print('DEBUG: Exception type: ${e.runtimeType}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        print('DEBUG: Login finally block');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacingXL),
                
                // Role indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMD,
                    vertical: AppTheme.spacingSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.selectedRole == 'patient' 
                            ? Icons.person_outline 
                            : Icons.medical_services_outlined,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        'Signing in as ${widget.selectedRole}',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                Text(
                  'Welcome Back',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  'Sign in to continue to HaDoc',
                  style: AppTheme.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing2XL),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/signup');
                        },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 