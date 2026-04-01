import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../Logic/passenger_notifications_logic.dart';

class PassengerNotificationsPageUI extends StatelessWidget {
  const PassengerNotificationsPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => PassengerNotificationsLogic.handleBackPress(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            backgroundColor: cs.primary,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => PassengerNotificationsLogic.handleBackPress(context),
            ),
            centerTitle: true,
            title: Text(
              'Notifications',
              style: TextStyle(color: cs.onPrimary, fontSize: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => PassengerNotificationsLogic.showClearDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.accentOrange,
                        size: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _EmptyNotificationState(cs: cs),
      ),
    );
  }
}

/// ==============================
/// WIDGET: Empty Notification State
/// ==============================
class _EmptyNotificationState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyNotificationState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 120,
            color: cs.onBackground.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            "You don't have any notification at the moment",
            style: TextStyle(
              color: cs.onBackground.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}