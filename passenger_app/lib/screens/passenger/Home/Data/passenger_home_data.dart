import 'package:flutter/material.dart';

class PassengerHomeData {
  static const double defaultAppBarHeight = 45;
  static const String defaultDisplayName = "Guest";
  static const String defaultEmail = "guest@example.com";

  // Optional icons
  final Widget? busIcon;
  final Widget? vanIcon;
  final Widget? bottomHomeIcon;
  final Widget? bottomBookingIcon;
  final Widget? bottomSupportIcon;
  final Widget? bottomWalletIcon;

  const PassengerHomeData({
    this.busIcon,
    this.vanIcon,
    this.bottomHomeIcon,
    this.bottomBookingIcon,
    this.bottomSupportIcon,
    this.bottomWalletIcon,
  });
}