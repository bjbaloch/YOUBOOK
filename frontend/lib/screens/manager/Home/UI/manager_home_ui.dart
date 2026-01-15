import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/add_service/UI/add_service_ui.dart';
import 'package:youbook/screens/manager/Notification/Notific_page/UI/manager_notifications_ui.dart';
import 'package:youbook/screens/manager/services/manager_services_screen.dart';
import 'package:youbook/screens/manager/schedules/manage_schedules_screen.dart';
import 'package:youbook/screens/manager/drivers/manager_drivers_screen.dart';
import 'package:youbook/screens/manager/manifests/passenger_manifests_screen.dart';
import 'package:youbook/screens/manager/vehicles/track_vehicles_screen.dart';
import 'package:youbook/screens/manager/side_bar/side_bar_ui.dart';
import '../Logic/manager_home_logic.dart';
import '../Data/manager_home_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/user.dart';
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
        return _ManagerHomeContent(
          data: data,
          appBarHeight: appBarHeight,
          currentUser: authProvider.user,
        );
      },
    );
  }
}

class _ManagerHomeContent extends StatefulWidget {
  final ManagerHomeData data;
  final double appBarHeight;
  final UserModel? currentUser;

  const _ManagerHomeContent({
    required this.data,
    this.appBarHeight = ManagerHomeData.defaultAppBarHeight,
    this.currentUser,
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
      duration: const Duration(milliseconds: 280),
    );
    _introFade = CurvedAnimation(
      parent: _introCtrl,
      curve: Curves.easeOutCubic,
    );
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic));
    _introCtrl.forward();
    _loadUserProfile();
  }

  @override
  void didUpdateWidget(_ManagerHomeContent oldWidget) {
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
            _displayName = currentUser.fullName ?? 'Manager';
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
      debugPrint('Error loading user profile for manager dashboard: $e');
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  PreferredSizeWidget _editableAppBar() {
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
          icon: Icon(Icons.menu, color: cs.onPrimary, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        title: _youBookTitle(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: cs.onPrimary, size: 27),
            onPressed: () {
              Navigator.push(
                context,
                ManagerHomeLogic.smoothTransition(
                  const ManagerNotificationsPageUI(),
                ),
              );
            },
          ),
          const SizedBox(width: 3),
        ],
      ),
    );
  }

  Widget _youBookTitle() {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 20),
        children: [
          TextSpan(
            text: "Y",
            style: TextStyle(color: cs.onPrimary),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "U",
            style: TextStyle(color: cs.onPrimary),
          ),
          TextSpan(
            text: "B",
            style: TextStyle(color: cs.onPrimary),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "K",
            style: TextStyle(color: cs.onPrimary),
          ),
        ],
      ),
    );
  }

  // Quick Action Card
  Widget _quickActionCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  ManagerHomeLogic.smoothTransition(const AccountPageUI()),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.onPrimary,
                    backgroundImage:
                        (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Icon(Icons.person, color: cs.primary, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loadingProfile ? 'Loading...' : (_displayName ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adsCarousel() => const SizedBox();

  Widget _categoryTile({
    required String title,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon ?? Icon(Icons.directions_bus, color: cs.primary, size: 40),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
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
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          ManagerHomeLogic.smoothTransition(const ServicesPage()),
        );
      },
      backgroundColor: cs.primary,
      child: Icon(Icons.add, color: cs.onPrimary),
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
        onWillPop: () =>
            ManagerHomeLogic.handleBackPress(_lastBackPress, context),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: cs.background,
          drawer: ManagerSidebarDrawer(
            isDarkMode: false, // TODO: Get from theme provider
            onThemeChanged: (isDark) {
              // TODO: Handle theme change
            },
          ),
          appBar: _editableAppBar(),
          body: SafeArea(
            child: FadeTransition(
              opacity: _introFade,
              child: SlideTransition(
                position: _introSlide,
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    _quickActionCard(),
                    const SizedBox(height: 15),
                    _adsCarousel(),
                    const SizedBox(height: 15),
                    // Row 1: Manage Services | Manage Schedules
                    Row(
                      children: [
                        Expanded(
                          child: _categoryTile(
                            title: "Manage Services",
                            onTap: () {
                              Navigator.push(
                                context,
                                ManagerHomeLogic.smoothTransition(
                                  const ManagerServicesScreen(),
                                ),
                              );
                            },
                            icon: widget.data.busIcon,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _categoryTile(
                            title: "Manage Schedules",
                            onTap: () {
                              Navigator.push(
                                context,
                                ManagerHomeLogic.smoothTransition(
                                  const ManageSchedulesScreen(),
                                ),
                              );
                            },
                            icon:
                                widget.data.vanIcon ??
                                Icon(
                                  Icons.schedule,
                                  color: cs.primary,
                                  size: 40,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Row 2: Manager Drivers | Passenger Manifests
                    Row(
                      children: [
                        Expanded(
                          child: _categoryTile(
                            title: "Manager Drivers",
                            onTap: () {
                              Navigator.push(
                                context,
                                ManagerHomeLogic.smoothTransition(
                                  const ManagerDriversScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.person,
                              color: cs.primary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _categoryTile(
                            title: "Passenger Manifests",
                            onTap: () {
                              Navigator.push(
                                context,
                                ManagerHomeLogic.smoothTransition(
                                  const PassengerManifestsScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.list_alt,
                              color: cs.primary,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Row 3: Track Vehicles
                    Row(
                      children: [
                        Expanded(
                          child: _categoryTile(
                            title: "Track Vehicles",
                            onTap: () {
                              Navigator.push(
                                context,
                                ManagerHomeLogic.smoothTransition(
                                  const TrackVehiclesScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: cs.primary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(), // Empty space for balance
                        ),
                      ],
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
