import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youbook/features/booking/UI/booking_ui.dart';
import 'package:youbook/features/wallet_section/youbook_wallet/UI/wallet_ui.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:youbook/features/bus_service/Logic/bus_service_logic.dart';
import 'package:youbook/features/van_service/Logic/van_service_logic.dart';
import '../Logic/passenger_home_logic.dart';
import '../Data/passenger_home_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/profile_storage_service.dart';
import '../../Notification/Notific_page/UI/passenger_notifications_ui.dart';
import '../../../../core/widgets/ads_carousel_widget.dart';
import '../../side_bar/side_bar_ui.dart';
import '../../../../screens/auth/login/login_screen.dart';

class PassengerHomeUI extends StatelessWidget {
  final PassengerHomeData data;
  final double appBarHeight;

  const PassengerHomeUI({
    super.key,
    this.appBarHeight = PassengerHomeData.defaultAppBarHeight,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return _PassengerHomeContent(
          data: data,
          appBarHeight: appBarHeight,
          currentUser: authProvider.user,
        );
      },
    );
  }
}

class _PassengerHomeContent extends StatefulWidget {
  final PassengerHomeData data;
  final double appBarHeight;
  final UserModel? currentUser;

  const _PassengerHomeContent({
    required this.data,
    this.appBarHeight = PassengerHomeData.defaultAppBarHeight,
    this.currentUser,
  });

  @override
  State<_PassengerHomeContent> createState() => _PassengerHomeUIState();
}

class _PassengerHomeUIState extends State<_PassengerHomeContent>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _displayName = PassengerHomeData.defaultDisplayName;
  String? _email = PassengerHomeData.defaultEmail;
  String? _avatarUrl;
  bool _isDarkMode = false;

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
  void didUpdateWidget(_PassengerHomeContent oldWidget) {
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
      debugPrint('Error loading user profile for dashboard: $e');
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
                PassengerHomeLogic.smoothTransition(const PassengerNotificationsPageUI()),
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
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  PassengerHomeLogic.smoothTransition(const AccountPageUI()),
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
                          _displayName ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _email ?? 'email@example.com',
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

  Widget _adsCarousel() => const AdsCarouselWidget();

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

  Widget _bottomNav() {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: BottomNavigationBar(
        backgroundColor: cs.primary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.onPrimary,
        unselectedItemColor: cs.onPrimary.withOpacity(0.9),
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1:
              Navigator.push(
                context,
                PassengerHomeLogic.smoothTransition(const MyBookingPageUI()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                PassengerHomeLogic.smoothTransition(const HelpSupportPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                PassengerHomeLogic.smoothTransition(const WalletPage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Container(
                  height: 3,
                  width: 25,
                  decoration: BoxDecoration(
                    color: cs.onPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                widget.data.bottomHomeIcon ?? const Icon(Icons.home_rounded),
              ],
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon:
                widget.data.bottomBookingIcon ?? const Icon(Icons.receipt_long),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon:
                widget.data.bottomSupportIcon ??
                const Icon(Icons.support_agent),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon:
                widget.data.bottomWalletIcon ??
                const Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
        ],
      ),
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
            PassengerHomeLogic.handleBackPress(_lastBackPress, context),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: cs.background,
          drawer: AppSidebarDrawer(
            isDarkMode: _isDarkMode,
            onThemeChanged: (isDark) {
              setState(() => _isDarkMode = isDark);
            },
            onLogout: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
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
                    Row(
                      children: [
                        Expanded(
                          child: _categoryTile(
                            title: "Bus Tickets",
                            onTap: () => BusServiceLogic.navigateToBusService(context),
                            icon: widget.data.busIcon,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: _categoryTile(
                            title: "Van Tickets",
                            onTap: () => VanServiceLogic.navigateToVanService(context),
                            icon:
                                widget.data.vanIcon ??
                                Icon(
                                  Icons.airport_shuttle,
                                  color: cs.primary,
                                  size: 40,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _bottomNav(),
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
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: cs.primary,
      ),
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
