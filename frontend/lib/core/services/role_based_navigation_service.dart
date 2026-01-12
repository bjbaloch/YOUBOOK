import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/manager/Home/Data/manager_home_data.dart';
import '../../screens/manager/Home/UI/manager_home_ui.dart';
import '../../screens/passenger/Home/Data/passenger_home_data.dart';
import '../../screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../screens/manager/manager_waiting_screen/manager_waiting_screen.dart';
import '../../screens/manager/manager_company_details/manager_company_details_screen.dart';

class RoleBasedNavigationService {
  static final RoleBasedNavigationService _instance = RoleBasedNavigationService._internal();
  factory RoleBasedNavigationService() => _instance;
  RoleBasedNavigationService._internal();

  /// Navigate to the appropriate dashboard based on user role and application status
  Future<void> navigateToAppropriateDashboard(BuildContext context, {bool replace = false}) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        // Not authenticated, do nothing or navigate to login
        return;
      }

      // Check manager application status
      final applicationResponse = await Supabase.instance.client
          .from('manager_applications')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(1);

      Widget targetScreen;

      if (applicationResponse.isNotEmpty) {
        final application = applicationResponse.first;
        final status = application['status'];
        if (status == 'approved') {
          targetScreen = const ManagerHomeUI(data: ManagerHomeData());
        } else if (status == 'pending') {
          targetScreen = const ManagerWaitingScreen();
        } else {
          // rejected
          targetScreen = const PassengerHomeUI(data: PassengerHomeData());
        }
      } else {
        // Check profile role
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', currentUser.id)
            .single();

        final role = profileResponse['role'] as String?;
        if (role == 'manager') {
          targetScreen = const ManagerCompanyDetailsScreen();
        } else {
          targetScreen = const PassengerHomeUI(data: PassengerHomeData());
        }
      }

      if (replace) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => targetScreen),
          (route) => false, // Remove all routes
        );
      }
    } catch (e) {
      // Fallback to passenger dashboard on error
      final targetScreen = const PassengerHomeUI(data: PassengerHomeData());
      if (replace) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => targetScreen),
          (route) => false,
        );
      }
    }
  }

  /// Handle back press - navigate to appropriate dashboard instead of exiting
  Future<bool> handleBackPress(BuildContext context) async {
    await navigateToAppropriateDashboard(context, replace: true);
    return false; // Don't allow system back (don't exit app)
  }

  /// Check if current route is a dashboard/home screen
  bool isOnDashboard(BuildContext context) {
    final currentRoute = ModalRoute.of(context);
    if (currentRoute == null) return false;

    final routeName = currentRoute.settings.name;
    final widgetType = currentRoute.settings.arguments.runtimeType.toString();

    // Check if it's a home/dashboard screen
    return widgetType.contains('ManagerHomeUI') ||
           widgetType.contains('PassengerHomeUI') ||
           widgetType.contains('ManagerWaitingScreen') ||
           widgetType.contains('ManagerCompanyDetailsScreen');
  }
}
