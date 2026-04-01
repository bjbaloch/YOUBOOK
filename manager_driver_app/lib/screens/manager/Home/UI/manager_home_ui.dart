import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:manager_driver_app/screens/manager/Notification/Notific_page/UI/manager_notifications_ui.dart';
import 'package:manager_driver_app/screens/manager/services/manager_services_screen.dart';
import 'package:manager_driver_app/screens/manager/schedules/manage_schedules_screen.dart';
import 'package:manager_driver_app/screens/driver/manager_drivers_screen.dart';
import 'package:manager_driver_app/screens/manager/manifests/passenger_manifests_screen.dart';
import 'package:manager_driver_app/screens/manager/vehicles/track_vehicles_screen.dart';
import 'package:manager_driver_app/screens/manager/side_bar/side_bar_ui.dart';
import '../Logic/manager_home_logic.dart';
import '../Data/manager_home_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/profile_storage_service.dart';

class ManagerHomeUI extends StatelessWidget {
  final ManagerHomeData data;
  final double appBarHeight;

  const ManagerHomeUI({
    super.key,
    this.appBarHeight = ManagerHomeData.defaultAppBarHeight,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return _ManagerHomeContent(data: data, appBarHeight: appBarHeight);
      },
    );
  }
}

class _ManagerHomeContent extends StatefulWidget {
  final ManagerHomeData data;
  final double appBarHeight;

  const _ManagerHomeContent({
    required this.data,
    this.appBarHeight = ManagerHomeData.defaultAppBarHeight,
  });

  @override
  State<_ManagerHomeContent> createState() => _ManagerHomeUIState();
}

class _ManagerHomeUIState extends State<_ManagerHomeContent>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _displayName = ManagerHomeData.defaultDisplayName;
  String? _email = ManagerHomeData.defaultEmail;
  String? _avatarUrl;
  bool _loadingProfile = false;

  DateTime? _lastBackPress;
  late final AnimationController _introCtrl;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _introFade = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic);
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic));
    _introCtrl.forward();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      if (currentUser != null) {
        if (mounted) {
          setState(() {
            _displayName = currentUser.fullName.isNotEmpty ? currentUser.fullName : 'Manager';
            _email = currentUser.email;
            _avatarUrl = null;
          });
        }
      } else {
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
      debugPrint('Error loading user profile for manager dashboard: $e');
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final cs = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: Size.fromHeight(widget.appBarHeight),
      child: AppBar(
        toolbarHeight: widget.appBarHeight,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: cs.onPrimary, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        title: _youBookTitle(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: cs.onPrimary, size: 26),
            onPressed: () => Navigator.push(
              context,
              ManagerHomeLogic.smoothTransition(const ManagerNotificationsPageUI()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _youBookTitle() {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: 'Y', style: TextStyle(color: cs.onPrimary)),
          const TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
          TextSpan(text: 'U', style: TextStyle(color: cs.onPrimary)),
          TextSpan(text: 'B', style: TextStyle(color: cs.onPrimary)),
          const TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
          const TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
          TextSpan(text: 'K', style: TextStyle(color: cs.onPrimary)),
        ],
      ),
    );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final cs = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: cs.onPrimary.withOpacity(0.2),
            backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ? NetworkImage(_avatarUrl!)
                : null,
            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                ? Icon(Icons.person_rounded, color: cs.onPrimary, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _loadingProfile ? 'Loading...' : (_displayName ?? 'Manager'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onPrimary.withOpacity(0.75), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.onPrimary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: cs.onPrimary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Manager',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onBackground,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Feature Card ─────────────────────────────────────────────────────────────
  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconBgColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bg = iconBgColor ?? cs.primary.withOpacity(0.1);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: cs.primary.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: cs.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.55),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingActionButton() {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        ManagerHomeLogic.smoothTransition(const ManagerServicesScreen()),
      ),
      backgroundColor: cs.primary,
      icon: Icon(Icons.add_rounded, color: cs.onPrimary),
      label: Text('Add Service', style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600)),
      tooltip: 'Add Service',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: cs.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: () => ManagerHomeLogic.handleBackPress(_lastBackPress, context),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: cs.background,
          drawer: ManagerSidebarDrawer(
            isDarkMode: false,
            onThemeChanged: (isDark) {},
          ),
          appBar: _buildAppBar(),
          body: SafeArea(
            child: FadeTransition(
              opacity: _introFade,
              child: SlideTransition(
                position: _introSlide,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeroHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Quick Actions'),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.15,
                            children: [
                              _featureCard(
                                icon: Icons.directions_bus_rounded,
                                title: 'Manage Services',
                                subtitle: 'View & edit bus services',
                                onTap: () => Navigator.push(
                                  context,
                                  ManagerHomeLogic.smoothTransition(const ManagerServicesScreen()),
                                ),
                              ),
                              _featureCard(
                                icon: Icons.schedule_rounded,
                                title: 'Manage Schedules',
                                subtitle: 'Set departure times',
                                onTap: () => Navigator.push(
                                  context,
                                  ManagerHomeLogic.smoothTransition(const ManageSchedulesScreen()),
                                ),
                              ),
                              _featureCard(
                                icon: Icons.people_alt_rounded,
                                title: 'Manage Drivers',
                                subtitle: 'Driver assignments',
                                onTap: () => Navigator.push(
                                  context,
                                  ManagerHomeLogic.smoothTransition(const ManagerDriversScreen()),
                                ),
                              ),
                              _featureCard(
                                icon: Icons.list_alt_rounded,
                                title: 'Passenger Manifests',
                                subtitle: 'Booking records',
                                onTap: () => Navigator.push(
                                  context,
                                  ManagerHomeLogic.smoothTransition(const PassengerManifestsScreen()),
                                ),
                              ),
                              _featureCard(
                                icon: Icons.location_on_rounded,
                                title: 'Track Vehicles',
                                subtitle: 'Live vehicle tracking',
                                onTap: () => Navigator.push(
                                  context,
                                  ManagerHomeLogic.smoothTransition(const TrackVehiclesScreen()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _floatingActionButton(),
        ),
      ),
    );
  }
}
