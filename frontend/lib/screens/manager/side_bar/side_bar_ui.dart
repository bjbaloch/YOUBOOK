import 'package:flutter/material.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:youbook/features/wallet_section/youbook_wallet/UI/wallet_ui.dart';
import '../Home/UI/manager_home_ui.dart';
import '../Home/Data/manager_home_data.dart';
import '../Notification/Notific_page/UI/manager_notifications_ui.dart';
import '../wallet/manager_wallet_screen.dart';
import '../services/manager_services_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/profile_storage_service.dart';
import '../../../../core/widgets/logout_dialog.dart';

class ManagerSidebarDrawer extends StatefulWidget {
  const ManagerSidebarDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.selectedIndex = 0,
    this.onLogout,
    this.showVersion = true,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final int selectedIndex;
  final VoidCallback? onLogout;
  final bool showVersion;

  @override
  State<ManagerSidebarDrawer> createState() => _ManagerSidebarDrawerState();
}

class _ManagerSidebarDrawerState extends State<ManagerSidebarDrawer> {
  late bool _localIsDark;
  String? _displayName;
  String? _email;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _localIsDark = widget.isDarkMode;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final accountData = await ProfileStorageService.getCombinedProfileData();
      if (mounted) {
        setState(() {
          _displayName = accountData.displayName;
          _email = accountData.email;
          _avatarUrl = accountData.avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile for manager sidebar: $e');
    }
  }

  PageRouteBuilder _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final slide =
            Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  Widget _header() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 170),
      color: cs.primary,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (mounted) {
                    setState(() => _localIsDark = !_localIsDark);
                  }
                  widget.onThemeChanged(_localIsDark);
                  AppTheme.setDark(_localIsDark);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      _localIsDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(_localIsDark),
                      color: cs.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Switch.adaptive(
                  key: ValueKey(_localIsDark),
                  value: _localIsDark,
                  activeColor: cs.secondary,
                  onChanged: (v) {
                    if (mounted) {
                      setState(() => _localIsDark = v);
                    }
                    widget.onThemeChanged(v);
                    AppTheme.setDark(v);
                  },
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: cs.onPrimary,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: cs.onPrimary,
                backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? NetworkImage(_avatarUrl!)
                    : null,
                child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                    ? Icon(Icons.person, color: cs.primary, size: 40)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName ?? 'Manager',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email ?? 'manager@email.com',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushReplacement(context, _smoothRoute(page));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: cs.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Drawer(
        backgroundColor: cs.background,
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Column(
                        children: [
                          _navItem(
                            icon: Icons.home_rounded,
                            label: 'Dashboard',
                            page: ManagerHomeUI(data: const ManagerHomeData()),
                          ),
                          _navItem(
                            icon: Icons.business_rounded,
                            label: 'Manage Services',
                            page: const ManagerServicesScreen(),
                          ),
                          _navItem(
                            icon: Icons.schedule_rounded,
                            label: 'Manage Schedules',
                            page: const PlaceholderManagerScreen(
                              title: 'Manage Schedules',
                            ),
                          ),
                          _navItem(
                            icon: Icons.people_rounded,
                            label: 'Manage Drivers',
                            page: const PlaceholderManagerScreen(
                              title: 'Manage Drivers',
                            ),
                          ),
                          _navItem(
                            icon: Icons.list_alt_rounded,
                            label: 'Passenger Manifests',
                            page: const PlaceholderManagerScreen(
                              title: 'Passenger Manifests',
                            ),
                          ),
                          _navItem(
                            icon: Icons.location_on_rounded,
                            label: 'Track Vehicles',
                            page: const PlaceholderManagerScreen(
                              title: 'Track Vehicles',
                            ),
                          ),
                          _navItem(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Manager Wallet',
                            page: const ManagerWalletScreen(),
                          ),
                          _navItem(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            page: const ManagerNotificationsPageUI(),
                          ),
                          _navItem(
                            icon: Icons.person_rounded,
                            label: 'Account',
                            page: const AccountPageUI(),
                          ),
                          _navItem(
                            icon: Icons.support_agent_rounded,
                            label: 'Support',
                            page: const HelpSupportPage(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          LogoutDialog.show(context, currentScreen: 'manager');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: cs.error),
                              const SizedBox(width: 14),
                              Text('Logout', style: TextStyle(color: cs.error)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showVersion)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 6),
                  child: Text(
                    'Version',
                    style: TextStyle(
                      color: cs.onBackground.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderManagerScreen extends StatelessWidget {
  const PlaceholderManagerScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: cs.primary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: cs.primary),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
