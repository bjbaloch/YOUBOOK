library login_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../../passenger/home_shell.dart';
import '../../manager/manager_dashboard.dart';
import '../../driver/driver_home_screen.dart';
import '../signup/signup_screen.dart';
import '../forget_password/forget_password_popup.dart';

part 'login_data.dart';
part 'login_logic.dart';
part 'login_ui.dart';
