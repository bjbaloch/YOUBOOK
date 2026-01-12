import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../core.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      color: AppColors.primary,
    ),
    _NavigationItem(
      title: 'Applications',
      icon: Icons.file_present,
      route: '/applications',
      color: AppColors.warning,
    ),
    _NavigationItem(
      title: 'Users',
      icon: Icons.people,
      route: '/users',
      color: AppColors.success,
    ),
    _NavigationItem(
      title: 'Notifications',
      icon: Icons.notifications,
      route: '/notifications',
      color: AppColors.accent,
    ),
    _NavigationItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
      color: AppColors.primary,
    ),
    _NavigationItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
      color: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load notifications when layout is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Notification Icon with Badge
          badges.Badge(
            badgeContent: Text(
              notificationProvider.unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            showBadge: notificationProvider.unreadCount > 0,
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifications');
              },
            ),
          ),

          // Profile Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed('/profile');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'logout':
                  _showLogoutDialog(context, authProvider);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ),
          ),

          // Additional actions from parent
          ...?widget.actions,
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.surface,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: AppColors.primary,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'YOUBOOK Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrator Panel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _navigationItems.map((item) {
                    final isSelected = ModalRoute.of(context)?.settings.name == item.route;
                    return Container(
                      color: isSelected ? AppColors.primary : null,
                      child: ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          if (!isSelected) {
                            Navigator.of(context).pushReplacementNamed(item.route);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'YOUBOOK v1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }

  void _showLogoutDialog(BuildContext context, AdminAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  const _NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}
