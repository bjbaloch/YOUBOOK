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
import 'screens/splash_screen/splash_screen.dart';
import 'screens/passenger/home_shell.dart';
import 'screens/manager/manager_dashboard.dart';
import 'screens/manager/manager_waiting_screen/manager_waiting_screen.dart';

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

      // Parse query parameters (format: ?access_token=...&refresh_token=...&type=signup)
      final queryParams = uri.queryParameters;
      final accessToken = queryParams['access_token'];
      final refreshToken = queryParams['refresh_token'];
      final type = queryParams['type'];

      print('DEBUG: Parsed query params:');
      print('DEBUG: - access_token: ${accessToken != null ? 'present (${accessToken.length} chars)' : 'null'}');
      print('DEBUG: - refresh_token: ${refreshToken != null ? 'present (${refreshToken.length} chars)' : 'null'}');
      print('DEBUG: - type: $type');

      if (accessToken != null && refreshToken != null) {
        print('DEBUG: Tokens found, setting session and navigating');

        try {
          // For email confirmation deep links, set the session with access token
          // Note: refresh token is available but setSession may only need access token
          await Supabase.instance.client.auth.setSession(accessToken);
          print('DEBUG: Session recovered successfully');

          // Clear any pending confirmation data since email is now confirmed
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('pending_email');
          await prefs.remove('pending_role');
          await prefs.remove('pending_company_name');
          await prefs.remove('pending_credential_details');
          print('DEBUG: Cleared pending confirmation data');

            // Get current user and profile
            final currentUser = Supabase.instance.client.auth.currentUser;
            print('DEBUG: Current user: ${currentUser?.email}');

            if (currentUser != null) {
              // Get user profile to determine role
              final profileResponse = await Supabase.instance.client
                  .from('profiles')
                  .select('role, company_name, credential_details')
                  .eq('id', currentUser.id)
                  .single();

              final userRole = profileResponse['role'] as String? ?? 'passenger';
              print('DEBUG: User role from profile: $userRole');

              Widget nextScreen;
              switch (userRole) {
                case 'manager':
                  print('DEBUG: User is manager, checking application status...');
                  // For managers, check if their application is approved
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final isApproved = await authProvider.isManagerApplicationApproved();
                  print('DEBUG: Manager application approved: $isApproved');

                  if (isApproved) {
                    print('DEBUG: Manager application approved, navigating to ManagerDashboard');
                    nextScreen = const ManagerDashboard();
                  } else {
                    print('DEBUG: Manager application pending, navigating to ManagerWaitingScreen');
                    final companyName = profileResponse['company_name'] as String?;
                    final credentialDetails = profileResponse['credential_details'] as String?;
                    nextScreen = ManagerWaitingScreen(
                      companyName: companyName,
                      credentialDetails: credentialDetails,
                    );
                  }
                  break;
                case 'passenger':
                default:
                  print('DEBUG: Navigating to HomeShell');
                  nextScreen = const HomeShell();
                  break;
              }

            // Navigate to the appropriate screen - use a more reliable navigation method
            if (mounted) {
              print('DEBUG: Performing navigation to ${nextScreen.runtimeType}');

              // Clear navigation stack and push to home screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => nextScreen),
                (route) => false, // Remove all previous routes
              );
              print('DEBUG: Navigation completed successfully');
            } else {
              print('DEBUG: Context not mounted, cannot navigate');
            }
          } else {
            print('DEBUG: No current user after session set, cannot navigate');
          }

        } catch (e) {
          print('DEBUG: Error during deep link processing: $e');
          print('DEBUG: Error type: ${e.runtimeType}');
          print('DEBUG: Stack trace: ${StackTrace.current}');

          // Fallback: try to navigate to login screen
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          }
        }
      } else {
        print('DEBUG: Missing access_token or refresh_token in query params - cannot process auth');
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
