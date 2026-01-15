import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbook/features/booking/UI/booking_ui.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:youbook/features/wallet_section/youbook_wallet/UI/wallet_ui.dart';
import '../Home/UI/passenger_home_ui.dart';
import '../Home/Data/passenger_home_data.dart';
import '../Notification/Notific_page/UI/passenger_notifications_ui.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/models/user.dart';
import '../../../../../core/services/profile_storage_service.dart';
import '../../../../../core/widgets/logout_dialog.dart';

class AppSidebarDrawer extends StatelessWidget {
  const AppSidebarDrawer({
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
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return _AppSidebarDrawerContent(
          isDarkMode: isDarkMode,
          onThemeChanged: onThemeChanged,
          selectedIndex: selectedIndex,
          onLogout: onLogout,
          showVersion: showVersion,
          currentUser: authProvider.user,
        );
      },
    );
  }
}

class _AppSidebarDrawerContent extends StatefulWidget {
  const _AppSidebarDrawerContent({
    required this.isDarkMode,
    required this.onThemeChanged,
    this.selectedIndex = 0,
    this.onLogout,
    this.showVersion = true,
    this.currentUser,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final int selectedIndex;
  final VoidCallback? onLogout;
  final bool showVersion;
  final UserModel? currentUser;

  @override
  State<_AppSidebarDrawerContent> createState() => _AppSidebarDrawerContentState();
}

class _AppSidebarDrawerContentState extends State<_AppSidebarDrawerContent> {
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

  @override
  void didUpdateWidget(_AppSidebarDrawerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload user profile if the current user changed
    if (oldWidget.currentUser != widget.currentUser) {
      _loadUserProfile();
    }
  }



  Future<void> _loadUserProfile() async {
    try {
      // First try to get data from widget (authenticated user)
      final currentUser = widget.currentUser;

      if (currentUser != null) {
        // Use authenticated user data
        if (mounted) {
          setState(() {
            _displayName = currentUser.fullName ?? 'User';
            _email = currentUser.email;
            _avatarUrl = currentUser.avatarUrl;
          });
        }
      } else {
        // Fall back to local storage data
        final accountData = await ProfileStorageService.getCombinedProfileData();
        if (mounted) {
          setState(() {
            _displayName = accountData.displayName;
            _email = accountData.email;
            _avatarUrl = accountData.avatarUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile for sidebar: $e');
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
                backgroundImage:
                    (_avatarUrl != null && _avatarUrl!.isNotEmpty)
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
                      _displayName ?? 'User',
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
                      _email ?? 'email@example.com',
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
                            label: 'Home',
                            page: PassengerHomeUI(
                              data: const PassengerHomeData(),
                            ),
                          ),
                          _navItem(
                            icon: Icons.person_rounded,
                            label: 'Account',
                            page: const AccountPageUI(),
                          ),
                          _navItem(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            page: const PassengerNotificationsPageUI(),
                          ),
                          _navItem(
                            icon: Icons.card_travel_rounded,
                            label: 'Booking',
                            page: const MyBookingPageUI(),
                          ),
                          _navItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Wallet',
                            page: const WalletPage(),
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
                          LogoutDialog.show(
                            context,
                            currentScreen: 'passenger',
                          );
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

class SupportPlaceholderScreen extends StatelessWidget {
  const SupportPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Support'), backgroundColor: cs.primary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 80, color: cs.primary),
            const SizedBox(height: 20),
            Text(
              'Support Center',
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
