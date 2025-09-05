// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:just_audio_background/just_audio_background.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:green_gold/entry_point.dart';

// Global instances, as per your reference app's structure
final AudioPlayer audioPlayer = AudioPlayer();
final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the background audio service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.greengold.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    // This points to your existing 'ic_stat_music_note.png' resource
    androidNotificationIcon: 'drawable/ic_stat_music_note',
  );

  await Supabase.initialize(
    url: 'https://dzddxcamivibccwokgnt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6ZGR4Y2FtaXZpYmNjd29rZ250Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNTYzMzQsImV4cCI6MjA3MjYzMjMzNH0.iBqZMdEBoBs7I_jabjkmQlRIoKgVi4M2T6j6vYysh3s',
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
        // Provide the single, global audio player instance to the app
        Provider<AudioPlayer>(create: (context) => audioPlayer),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    notificationService.requestPermissions();
    _initHomeWidget();
  }

  // Set up listeners for the home screen widget
  void _initHomeWidget() {
    HomeWidget.setAppGroupId('group.com.greengold.widget');
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  // Handles navigation when the home widget is tapped
  void _launchedFromWidget(Uri? uri) {
    if (uri?.host == 'open_profile') {
      // The argument '2' corresponds to the index of the ProfileScreen in your EntryPoint widget
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'entry_point', 
        (route) => false,
        arguments: 2, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Green Gold',
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: themeProvider.themeMode,
          initialRoute: 'splash',
          onGenerateRoute: (settings) {
            // Handle argument passing for widget navigation
            if (settings.name == 'entry_point') {
              final initialIndex = settings.arguments as int? ?? 0;
              return MaterialPageRoute(builder: (_) => EntryPoint(initialIndex: initialIndex));
            }
            if (settings.name == 'splash') {
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            }
            return generateRoute(settings);
          },
          navigatorKey: navigatorKey,
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