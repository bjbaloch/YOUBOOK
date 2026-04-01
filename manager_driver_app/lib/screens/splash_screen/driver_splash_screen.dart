library driver_splash_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manager_driver_app/screens/auth/login/login_screen.dart';
import 'package:manager_driver_app/screens/driver/driver_home_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_router.dart';

part 'driver_splash_data.dart';
part 'driver_splash_logic.dart';

class DriverSplashScreen extends StatefulWidget {
  const DriverSplashScreen({super.key});

  @override
  State<DriverSplashScreen> createState() => _DriverSplashScreenState();
}
