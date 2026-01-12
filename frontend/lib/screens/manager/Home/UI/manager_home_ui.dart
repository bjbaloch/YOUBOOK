import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/features/booking/UI/booking_ui.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/wallet_section/youbook_wallet/UI/wallet_ui.dart';
import 'package:youbook/screens/manager/Notification/Notific_page/UI/manager_notifications_ui.dart';
import 'package:youbook/screens/manager/side_bar/side_bar_ui.dart';
import '../Logic/manager_home_logic.dart';
import '../Data/manager_home_data.dart';
import '../../../../core/theme/app_colors.dart';

class ManagerHomeUI extends StatefulWidget {
  final ManagerHomeData data;
  final double appBarHeight;

  const ManagerHomeUI({
    super.key,
    this.appBarHeight = ManagerHomeData.defaultAppBarHeight,
    required this.data,
  });

  @override
  State<ManagerHomeUI> createState() => _ManagerHomeUIState();
}

class _ManagerHomeUIState extends State<ManagerHomeUI>
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
            icon: Icon(Icons.account_balance_wallet, color: cs.onPrimary, size: 27),
            onPressed: () {
              Navigator.push(
                context,
                ManagerHomeLogic.smoothTransition(
                  const PlaceholderManagerScreen(title: 'Manager Wallet'),
                ),
              );
            },
            tooltip: 'Manager Wallet',
          ),
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
        // TODO: Navigate to Add Service screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Service - Coming Soon!')),
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
                    Row(
                      children: [
                        Expanded(
                          child: _categoryTile(
                            title: "Manage Services",
                            onTap: () {},
                            icon: widget.data.busIcon,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: _categoryTile(
                            title: "Manage Schedules",
                            onTap: () {},
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
