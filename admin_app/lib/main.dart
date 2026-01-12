import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/core.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/main_layout.dart';
import 'screens/auth/auth.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/users/users_screen.dart';
import 'screens/applications/applications_screen.dart';
import 'screens/applications/application_detail_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize notification service
  await NotificationService.initialize();

  // Initialize the auth provider
  final authProvider = AdminAuthProvider();
  await authProvider.initializeAuth();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatefulWidget {
  final AdminAuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLinks? _appLinks;
  bool _isProcessingLink = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial link that opened the app
    final initialLink = await _appLinks!.getInitialLink();
    if (initialLink != null) {
      await _handleDeepLink(initialLink);
    }

    // Handle links opened while app is running
    _appLinks!.uriLinkStream.listen((link) {
      _handleDeepLink(link);
    });
  }

  Future<void> _handleDeepLink(Uri link) async {
    if (_isProcessingLink) return;

    setState(() {
      _isProcessingLink = true;
    });

    try {
      // Handle Supabase auth callback URLs
      if (link.scheme == 'youbookadmin' && link.host == 'auth') {
        await _handleAuthCallback(link);
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingLink = false;
        });
      }
    }
  }

  Future<void> _handleAuthCallback(Uri link) async {
    try {
      debugPrint('Processing auth callback with URL: $link');
      debugPrint('Query parameters: ${link.queryParameters}');

      // Extract query parameters
      final accessToken = link.queryParameters['access_token'];
      final refreshToken = link.queryParameters['refresh_token'];
      final type = link.queryParameters['type'];
      final error = link.queryParameters['error'];

      // Check for errors
      if (error != null) {
        debugPrint('Auth callback error: $error');
        throw Exception('Authentication error: $error');
      }

      if (accessToken != null && type == 'signup') {
        debugPrint('Setting session with access token...');
        // Set the session using the access token from the URL
        await Supabase.instance.client.auth.setSession(accessToken);

        // Wait a moment for the session to be established
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to dashboard after successful verification
        if (mounted) {
          debugPrint('Navigating to dashboard...');
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else {
        debugPrint('Missing required parameters: access_token=$accessToken, type=$type');
        throw Exception('Missing required authentication parameters');
      }
    } catch (e) {
      debugPrint('Error processing auth callback: $e');
      // Show error and navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'YOUBOOK Admin',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AdminSplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/confirmation': (context) => const ConfirmationScreen(),
          '/dashboard': (context) => MainLayout(
            title: 'Dashboard',
            child: const DashboardScreen(),
          ),
          '/users': (context) => MainLayout(
            title: 'Users',
            child: const UsersScreen(),
          ),
          '/applications': (context) => MainLayout(
            title: 'Applications',
            child: const ApplicationsScreen(),
          ),
          '/notifications': (context) => MainLayout(
            title: 'Notifications',
            child: const NotificationsScreen(),
          ),
          '/profile': (context) => MainLayout(
            title: 'Profile',
            child: const ProfileScreen(),
          ),
          '/settings': (context) => MainLayout(
            title: 'Settings',
            child: const SettingsScreen(),
          ),
        },
        onUnknownRoute: (settings) {
          // Fallback to login if route not found
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}
