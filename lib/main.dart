import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadoc_app/providers/user_provider.dart';
import 'package:hadoc_app/screens/auth/login_screen.dart';
import 'package:hadoc_app/screens/auth/signup_screen.dart';
import 'package:hadoc_app/screens/doctor/doctor_dashboard.dart';
import 'package:hadoc_app/screens/patient/patient_dashboard.dart';
import 'package:hadoc_app/screens/profile/profile_screen.dart';
import 'package:hadoc_app/screens/profile/edit_profile_screen.dart';
import 'package:hadoc_app/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Hadoc',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryColor,
            primary: AppTheme.primaryColor,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) {
            final userProvider = context.watch<UserProvider>();
            if (userProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (userProvider.user != null) {
              return userProvider.user!.role == 'patient'
                  ? const PatientDashboard()
                  : const DoctorDashboard();
            }
            return const LoginScreen();
          },
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/patient': (context) => const PatientDashboard(),
          '/doctor': (context) => const DoctorDashboard(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) {
            final user = context.read<UserProvider>().user;
            if (user == null) {
              return const LoginScreen();
            }
            return EditProfileScreen(profile: user);
          },
        },
      ),
    );
  }
}
