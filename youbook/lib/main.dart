import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Uri? _pendingDeepLink;

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
      print('DEBUG: Deep link is auth callback');

      // Parse fragment parameters (format: #access_token=...&refresh_token=...)
      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        print('DEBUG: Parsing fragment: $fragment');
        final params = Uri.splitQueryString(fragment);
        final accessToken = params['access_token'];
        final refreshToken = params['refresh_token'];
        final type = params['type'];

        print('DEBUG: Parsed params - access_token: ${accessToken != null ? 'present' : 'null'}, refresh_token: ${refreshToken != null ? 'present' : 'null'}, type: $type');

        print('DEBUG: Auth callback received, refreshing app state');
        // The deep link contains auth information
        // Supabase should handle the session automatically
        // We just need to refresh the app state

        try {
          // Refresh the current session to pick up any auth changes
          await Supabase.instance.client.auth.refreshSession();
          print('DEBUG: Session refreshed after deep link');

          // Clear any pending confirmation data since email is now confirmed
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('pending_email');
          await prefs.remove('pending_role');
          await prefs.remove('pending_company_name');
          await prefs.remove('pending_credential_details');
          print('DEBUG: Cleared pending confirmation data');

        } catch (e) {
          print('DEBUG: Error refreshing session: $e');
        }
      } else {
        print('DEBUG: No fragment in deep link URI');
      }
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
