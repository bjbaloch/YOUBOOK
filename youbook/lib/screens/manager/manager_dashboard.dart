import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/logout_dialog.dart';
import '../auth/login/login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  void initState() {
    super.initState();
    // Store screen preference for navigation persistence
    _storeScreenPreference();
  }

  Future<void> _storeScreenPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_manager_screen', 'dashboard');
    } catch (e) {
      // Silently handle SharedPreferences errors
      print('Error storing screen preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              LogoutDialog.show(context, currentScreen: 'manager');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Manager Dashboard - TODO')),
    );
  }
}
