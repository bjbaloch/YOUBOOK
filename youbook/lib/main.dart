import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/location_provider.dart';
import 'core/services/background_service.dart';
import 'core/theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.offlineBox);

  // Initialize notifications (disabled firebase for now)
  // await NotificationService.initialize(flutterLocalNotificationsPlugin);

  // Initialize background service for drivers
  await BackgroundService.initialize();

  // Initialize app theme
  await AppTheme.init();

  runApp(const YouBookApp());
}

class YouBookApp extends StatelessWidget {
  const YouBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: AppTheme.themedApp((context, themeMode) {
        return MaterialApp(
          title: 'YOUBOOK',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            // Routes will be defined in separate files
          },
        );
      }),
    );
  }
}
