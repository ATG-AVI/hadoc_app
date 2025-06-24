import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _selectedRole = 'patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // App Logo/Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [AppTheme.shadowLG],
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLG),
              
              // Welcome Text
              Text(
                'Welcome to HaDoc',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingMD),
              
              Text(
                'Your AI-Powered Medical Analysis Platform',
                style: AppTheme.subtitleStyle.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Role Selection
              Text(
                'Choose your role',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingLG),
              
              // Role selection cards - responsive layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use column layout on very small screens
                  if (constraints.maxWidth < 300) {
                    return Column(
                      children: [
                        _buildRoleCard(
                          role: 'patient',
                          title: 'Patient',
                          subtitle: 'Upload & analyze reports',
                          icon: Icons.person_outline,
                          isSelected: _selectedRole == 'patient',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'patient';
                            });
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        _buildRoleCard(
                          role: 'doctor',
                          title: 'Doctor',
                          subtitle: 'Review reports & chat',
                          icon: Icons.medical_services_outlined,
                          isSelected: _selectedRole == 'doctor',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'doctor';
                            });
                          },
                        ),
                      ],
                    );
                  }
                  
                  // Use row layout for normal screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          role: 'patient',
                          title: 'Patient',
                          subtitle: 'Upload & analyze medical reports',
                          icon: Icons.person_outline,
                          isSelected: _selectedRole == 'patient',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'patient';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMD),
                      Expanded(
                        child: _buildRoleCard(
                          role: 'doctor',
                          title: 'Doctor',
                          subtitle: 'Review patient reports & chat',
                          icon: Icons.medical_services_outlined,
                          isSelected: _selectedRole == 'doctor',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'doctor';
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(selectedRole: _selectedRole),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
              
              const SizedBox(height: AppTheme.spacingMD),
              
              // Signup Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(selectedRole: _selectedRole),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Sign Up'),
              ),
              
              const SizedBox(height: AppTheme.spacingLG),
              
              // Features List (only show if screen has enough space)
              if (MediaQuery.of(context).size.height > 700)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingSM),
                        _buildFeatureItem(Icons.upload_file, 'Upload medical documents'),
                        _buildFeatureItem(Icons.analytics, 'AI-powered analysis'),
                        _buildFeatureItem(Icons.chat, 'Chat with healthcare professionals'),
                        _buildFeatureItem(Icons.security, 'Secure & private'),
                      ],
                    ),
                  ),
                ),
              
              // Add some bottom padding for smaller screens
              const SizedBox(height: AppTheme.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 160,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.1) : AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected ? const [AppTheme.shadowMD] : const [AppTheme.shadowSM],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.textMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Flexible(
                  child: Text(
                    subtitle,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 