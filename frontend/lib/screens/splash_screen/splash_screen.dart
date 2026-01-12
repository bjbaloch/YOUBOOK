library splash_screen;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youbook/screens/manager/Home/Data/manager_home_data.dart';
import 'package:youbook/screens/manager/Home/UI/manager_home_ui.dart';
import 'package:youbook/screens/passenger/Home/Data/passenger_home_data.dart';
import 'package:youbook/screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login/login_screen.dart';
import '../auth/email_confirmation_screen/email_confirmation_screen.dart';
import '../manager/manager_waiting_screen/manager_waiting_screen.dart';
import '../manager/manager_company_details/manager_company_details_screen.dart';
import '../driver/driver_home_screen.dart';

part 'splash_data.dart';
part 'splash_logic.dart';
part 'splash_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
