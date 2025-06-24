import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadoc_app/providers/user_provider.dart';
import 'package:hadoc_app/screens/auth/auth_screen.dart';

import 'package:hadoc_app/screens/doctor/doctor_dashboard.dart';
import 'package:hadoc_app/screens/patient/patient_dashboard.dart';
import 'package:hadoc_app/screens/profile/profile_screen.dart';
import 'package:hadoc_app/screens/profile/edit_profile_screen.dart';
import 'package:hadoc_app/utils/theme.dart';
import 'package:hadoc_app/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
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
            return const AuthScreen();
          },
          '/auth': (context) => const AuthScreen(),
          '/patient': (context) => const PatientDashboard(),
          '/doctor': (context) => const DoctorDashboard(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) {
            final user = context.read<UserProvider>().user;
            if (user == null) {
              return const AuthScreen();
            }
            return EditProfileScreen(profile: user);
          },
        },
      ),
    );
  }
}
