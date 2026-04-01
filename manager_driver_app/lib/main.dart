import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:app_links/app_links.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
// import 'core/services/background_service.dart';
import 'core/theme/app_colors.dart';
import 'screens/splash_screen/splash_screen.dart';
// import 'screens/auth/login/login_screen.dart';
// import 'screens/driver/driver_home_screen.dart';
// import 'screens/manager/Home/UI/manager_home_ui.dart';
// import 'screens/manager/manager_waiting_screen/manager_waiting_screen.dart';
// import 'screens/manager/manager_company_details/manager_company_details_screen.dart';
// import 'core/services/app_router.dart';
// import 'screens/manager/Home/Data/manager_home_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Uncomment when connecting backend
  // await Hive.initFlutter();
  // await Hive.openBox(AppConstants.offlineBox);
  // await BackgroundService.initialize();

  await AppTheme.init();
  await AuthProvider().initializeAuth();

  runApp(const ManagerDriverApp());
}

class ManagerDriverApp extends StatelessWidget {
  const ManagerDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: AppTheme.themedApp((context, themeMode) {
        return MaterialApp(
          title: 'YOUBOOK Manager & Driver',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
