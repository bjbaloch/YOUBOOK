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
import 'screens/passenger/home_shell.dart';
import 'screens/manager/manager_dashboard.dart';

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
    print('DEBUG: ===== DEEP LINK PROCESSING START =====');
    print('DEBUG: Received deep link: $uri');

    // Handle Supabase auth callback
    if (uri.scheme == 'youbook' && uri.host == 'auth') {
      print('DEBUG: Deep link is auth callback - processing email confirmation');

      // Parse fragment parameters (format: #access_token=...&refresh_token=...&type=signup)
      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        print('DEBUG: Parsing fragment: $fragment');
        final params = Uri.splitQueryString(fragment);
        final accessToken = params['access_token'];
        final refreshToken = params['refresh_token'];
        final type = params['type'];

        print('DEBUG: Parsed params:');
        print('DEBUG: - access_token: ${accessToken != null ? 'present (${accessToken.length} chars)' : 'null'}');
        print('DEBUG: - refresh_token: ${refreshToken != null ? 'present (${refreshToken.length} chars)' : 'null'}');
        print('DEBUG: - type: $type');

        if (accessToken != null && refreshToken != null) {
          print('DEBUG: Tokens found, refreshing session and forcing navigation');

          try {
            // Refresh the current session to pick up any auth changes
            await Supabase.instance.client.auth.refreshSession();
            print('DEBUG: Session refreshed successfully');

            // Clear any pending confirmation data since email is now confirmed
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('pending_email');
            await prefs.remove('pending_role');
            await prefs.remove('pending_company_name');
            await prefs.remove('pending_credential_details');
            print('DEBUG: Cleared pending confirmation data');

            // Force navigation to appropriate screen based on user role
            print('DEBUG: Checking current user and navigating...');
            final currentUser = Supabase.instance.client.auth.currentUser;
            print('DEBUG: Current user after refresh: ${currentUser?.email}');

            if (currentUser != null) {
              // Get user role from stored data or default to passenger
              final userRole = prefs.getString('pending_role') ?? 'passenger';
              print('DEBUG: User role: $userRole');

              Widget nextScreen;
              switch (userRole) {
                case 'manager':
                  print('DEBUG: Navigating to ManagerDashboard');
                  nextScreen = const ManagerDashboard();
                  break;
                case 'passenger':
                default:
                  print('DEBUG: Navigating to HomeShell');
                  nextScreen = const HomeShell();
                  break;
              }

              // Navigate to the appropriate screen
              if (mounted) {
                print('DEBUG: Performing navigation to ${nextScreen.runtimeType}');
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => nextScreen),
                );
                print('DEBUG: Navigation completed successfully');
              } else {
                print('DEBUG: Context not mounted, cannot navigate');
              }
            } else {
              print('DEBUG: No current user after session refresh, staying on current screen');
            }

          } catch (e) {
            print('DEBUG: Error during deep link processing: $e');
            print('DEBUG: Error type: ${e.runtimeType}');
          }
        } else {
          print('DEBUG: Missing access_token or refresh_token in fragment - cannot process auth');
        }
      } else {
        print('DEBUG: No fragment in deep link URI - invalid auth callback');
      }
    } else {
      print('DEBUG: Deep link is not auth callback (scheme: ${uri.scheme}, host: ${uri.host}), ignoring');
    }

    print('DEBUG: ===== DEEP LINK PROCESSING END =====');
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
