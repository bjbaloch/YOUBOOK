library manager_splash_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login/login_screen.dart';
import '../manager/Home/Data/manager_home_data.dart';
import '../manager/Home/UI/manager_home_ui.dart';
import '../manager/manager_waiting_screen/manager_waiting_screen.dart';
import '../manager/manager_company_details/manager_company_details_screen.dart';
import '../../core/services/app_router.dart';

part 'manager_splash_data.dart';
part 'manager_splash_logic.dart';

class ManagerSplashScreen extends StatefulWidget {
  const ManagerSplashScreen({super.key});

  @override
  State<ManagerSplashScreen> createState() => _ManagerSplashScreenState();
}
