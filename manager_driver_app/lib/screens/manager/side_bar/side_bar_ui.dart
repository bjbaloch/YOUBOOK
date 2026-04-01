import 'package:flutter/material.dart';
import '../Home/UI/manager_home_ui.dart';
import '../Home/Data/manager_home_data.dart';
import '../Notification/Notific_page/UI/manager_notifications_ui.dart';
import '../wallet/manager_wallet_screen.dart';
import '../services/manager_services_screen.dart';
import '../schedules/manage_schedules_screen.dart';
import '../../driver/manager_drivers_screen.dart';
import '../manifests/passenger_manifests_screen.dart';
import '../vehicles/track_vehicles_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/logout_dialog.dart';
import '../../../../features/profile/account/account_page/UI/account_page_ui.dart';

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
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
    _localIsDark = widget.isDarkMode;
    _activeIndex = widget.selectedIndex;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_displayName != null) return;
    // TODO: Restore Supabase profile loading when connecting backend
    if (mounted) {
      setState(() {
        _displayName = 'Manager';
        _email = 'manager@youbook.com';
      });
    }
  }

  PageRouteBuilder _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  void _navigate(int index, Widget page) {
    setState(() => _activeIndex = index);
    Navigator.of(context).pop();
    Navigator.push(context, _smoothRoute(page));
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: theme toggle + close
          Row(
            children: [
              _ThemeToggle(
                isDark: _localIsDark,
                onChanged: (v) {
                  if (mounted) setState(() => _localIsDark = v);
                  widget.onThemeChanged(v);
                  AppTheme.setDark(v);
                },
              ),
              const Spacer(),
              Material(
                color: cs.onPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, color: cs.onPrimary, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Avatar + info
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.onPrimary.withOpacity(0.6), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: cs.onPrimary.withOpacity(0.2),
                      backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                          ? Icon(Icons.person_rounded, color: cs.onPrimary, size: 32)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.onPrimary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
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
                      style: TextStyle(color: cs.onPrimary.withOpacity(0.8), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.onPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Manager',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
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

  // ── Nav Item ─────────────────────────────────────────────────────────────────
  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    required Widget page,
    Color? iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _activeIndex == index;
    final color = iconColor ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isActive ? cs.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigate(index, page),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? cs.primary.withOpacity(0.15) : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? cs.primary : color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? cs.primary : cs.onBackground,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: cs.onBackground.withOpacity(0.45),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.15)),
      );

  Future<void> _showLogoutDialog() => LogoutDialog.show(context);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                children: [
                  _sectionLabel('Main'),
                  _navItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Dashboard',
                    page: ManagerHomeUI(data: const ManagerHomeData()),
                  ),
                  _divider(),
                  _sectionLabel('Management'),
                  _navItem(
                    index: 1,
                    icon: Icons.directions_bus_rounded,
                    label: 'Manage Services',
                    page: const ManagerServicesScreen(),
                  ),
                  _navItem(
                    index: 2,
                    icon: Icons.schedule_rounded,
                    label: 'Manage Schedules',
                    page: const ManageSchedulesScreen(),
                  ),
                  _navItem(
                    index: 3,
                    icon: Icons.people_alt_rounded,
                    label: 'Manage Drivers',
                    page: const ManagerDriversScreen(),
                  ),
                  _navItem(
                    index: 4,
                    icon: Icons.list_alt_rounded,
                    label: 'Passenger Manifests',
                    page: const PassengerManifestsScreen(),
                  ),
                  _navItem(
                    index: 5,
                    icon: Icons.location_on_rounded,
                    label: 'Track Vehicles',
                    page: const TrackVehiclesScreen(),
                  ),
                  _divider(),
                  _sectionLabel('Account'),
                  _navItem(
                    index: 6,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Manager Wallet',
                    page: const ManagerWalletScreen(),
                  ),
                  _navItem(
                    index: 7,
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    page: const ManagerNotificationsPageUI(),
                  ),
                  _navItem(
                    index: 8,
                    icon: Icons.person_rounded,
                    label: 'Account',
                    page: const AccountPageUI(),
                  ),
                  _navItem(
                    index: 9,
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    page: const PlaceholderManagerScreen(title: 'Support'),
                  ),
                  _divider(),
                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _showLogoutDialog,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cs.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.logout_rounded, color: cs.error, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: cs.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showVersion)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Text(
                  'Version',
                  style: TextStyle(
                    color: cs.onBackground.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Theme Toggle Widget ────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onChanged});
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cs.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.onPrimary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                color: cs.onPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            Switch.adaptive(
              value: isDark,
              activeColor: AppColors.logoYellow,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder Screen ─────────────────────────────────────────────────────────
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
