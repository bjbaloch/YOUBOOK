import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase/supabase.dart';
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
  print('DEBUG: main() started');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  print('DEBUG: Initializing Supabase...');
  await SupabaseConfig.initialize();
  print('DEBUG: Supabase initialized');

  // Initialize Hive for offline storage
  print('DEBUG: Initializing Hive...');
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.offlineBox);
  print('DEBUG: Hive initialized');

  // Initialize notifications (disabled firebase for now)
  // await NotificationService.initialize(flutterLocalNotificationsPlugin);

  // Initialize background service for drivers
  print('DEBUG: Initializing background service...');
  await BackgroundService.initialize();
  print('DEBUG: Background service initialized');

  // Initialize app theme
  print('DEBUG: Initializing app theme...');
  await AppTheme.init();
  print('DEBUG: App theme initialized');

  print('DEBUG: Running YouBookApp...');
  runApp(const YouBookApp());
  print('DEBUG: App started');
}

class YouBookApp extends StatefulWidget {
  const YouBookApp({super.key});

  @override
  State<YouBookApp> createState() => _YouBookAppState();
}

class _YouBookAppState extends State<YouBookApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // Handle initial link if app was launched from a link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Handle links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) async {
    print('DEBUG: Received deep link: $uri');

    // Handle Supabase auth callback
    if (uri.scheme == 'youbook' && uri.host == 'auth') {
      print('DEBUG: Deep link is auth callback, refreshing profile...');
      // Supabase automatically handles the auth session from the deep link
      // We just need to notify the app that auth state might have changed
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('DEBUG: Calling authProvider.refreshProfile() from deep link');
        authProvider.refreshProfile();
      });
    } else {
      print('DEBUG: Deep link is not auth callback, ignoring');
    }
  }

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
