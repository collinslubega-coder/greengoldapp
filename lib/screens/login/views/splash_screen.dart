// lib/screens/login/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/admin_entry_point.dart';
import 'package:green_gold/hubs_entry_point.dart'; // ** THE FIX IS HERE **
import 'package:green_gold/screens/onbording/views/onbording_screnn.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    final userDataService = Provider.of<UserDataService>(context, listen: false);

    if (session != null) {
      await userDataService.initialized;

      if (!mounted) return;
      
      final role = userDataService.userRole;
      Widget destination;
      switch (role) {
        case 'admin':
          destination = const AdminEntryPoint();
          break;
        case 'customer':
        default:
          // ** THE FIX IS HERE: Changed to the new HubsEntryPoint **
          destination = const HubsEntryPoint();
          break;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnBordingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}