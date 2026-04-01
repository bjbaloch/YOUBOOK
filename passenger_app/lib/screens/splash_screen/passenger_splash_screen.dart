library passenger_splash_screen;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../passenger/Home/Data/passenger_home_data.dart';
import '../passenger/Home/UI/passenger_home_ui.dart';
import '../auth/login/login_screen.dart';

part 'passenger_splash_data.dart';
part 'passenger_splash_logic.dart';
part 'passenger_splash_ui.dart';

class PassengerSplashScreen extends StatefulWidget {
  const PassengerSplashScreen({super.key});

  @override
  State<PassengerSplashScreen> createState() => _PassengerSplashScreenState();
}
