// lib/main_admin.dart

import 'package:flutter/material.dart';
import 'package:green_gold/services/cart_service.dart';
import 'package:green_gold/services/notification_service.dart';
import 'package:green_gold/services/order_service.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:green_gold/theme/app_theme.dart';
import 'package:green_gold/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:green_gold/route/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_gold/screens/login/views/splash_screen.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dvywdzjwtgxdghihmnoc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2eXdkemp3dGd4ZGdoaWhtbm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNjg5MDEsImV4cCI6MjA3MDg0NDkwMX0.Zwn7JzEDPxZZOnJVY4m9RqQeP1aOtn-TK_xn3x2f_oI',
  );
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => UserDataService(notificationService: notificationService),
        ),
        ChangeNotifierProvider(create: (context) => CartService()),
        Provider(create: (context) => notificationService),
        ChangeNotifierProvider(create: (context) => SettingsService()),
        ChangeNotifierProvider(
          create: (context) => OrderService(notificationService: notificationService),
        ),
      ],
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  @override
  void initState() {
    super.initState();
    notificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Green Gold - Admin',
          theme: AppTheme.darkTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: themeProvider.themeMode,
          initialRoute: 'splash', 
          onGenerateRoute: (settings) {
            if (settings.name == 'splash') {
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            }
            return generateRoute(settings);
          },
          navigatorKey: navigatorKey,
          // === THE CHANGE IS HERE ===
          // We've added the builder property to create the background layer.
          builder: (context, child) {
            return Stack(
              children: [
                Image.asset(
                  "assets/images/cosmic_background.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: child,
                ),
              ],
            );
          },
        );
      },
    );
  }
}