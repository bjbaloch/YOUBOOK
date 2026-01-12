import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/wallet_section/youbook_wallet/UI/wallet_ui.dart';
import 'Home/UI/passenger_home_ui.dart';
import 'Home/Data/passenger_home_data.dart';
import 'side_bar/side_bar_ui.dart';
import 'booking_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;

  DateTime? _lastBackPress;

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
            selectedIndex: 5, // Support tab selected
            onLogout: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          appBar: AppBar(
            toolbarHeight: 45,
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
            title: const Text(
              'Support Center',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: const [],
          ),
          body: const SafeArea(
            child: SupportContent(),
          ),
          bottomNavigationBar: _bottomNav(),
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
        currentIndex: 2, // Support tab selected
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                PassengerHomeLogic.smoothTransition(PassengerHomeUI(
                  data: const PassengerHomeData(),
                )),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PassengerHomeLogic.smoothTransition(const BookingScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PassengerHomeLogic.smoothTransition(const WalletPage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 3,
              width: 25,
              decoration: BoxDecoration(
                color: cs.onPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
        ],
      ),
    );
  }
}

class SupportContent extends StatelessWidget {
  const SupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
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
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Screen')),
    );
  }
}

class PassengerHomeLogic {
  static Future<bool> handleBackPress(DateTime? lastBackPress, BuildContext context) async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);

    if (lastBackPress == null || now.difference(lastBackPress) > maxDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      lastBackPress = now;
      return false;
    }
    return true;
  }

  static PageRouteBuilder smoothTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final slide = Tween<Offset>(
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
}
