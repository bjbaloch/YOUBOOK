import 'package:flutter/material.dart';

class ManagerHomeData {
  static const double defaultAppBarHeight = 45;
  static const String defaultDisplayName = "Manager";
  static const String defaultEmail = "manager@example.com";

  // Optional icons
  final Widget? busIcon;
  final Widget? vanIcon;
  final Widget? bottomHomeIcon;
  final Widget? bottomBookingIcon;
  final Widget? bottomSupportIcon;
  final Widget? bottomWalletIcon;

  const ManagerHomeData({
    this.busIcon,
    this.vanIcon,
    this.bottomHomeIcon,
    this.bottomBookingIcon,
    this.bottomSupportIcon,
    this.bottomWalletIcon,
  });
}