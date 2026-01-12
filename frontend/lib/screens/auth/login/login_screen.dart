library login_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbook/screens/manager/Home/Data/manager_home_data.dart';
import 'package:youbook/screens/manager/Home/UI/manager_home_ui.dart';
import 'package:youbook/screens/passenger/Home/Data/passenger_home_data.dart';
import 'package:youbook/screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../../../core/services/auth_service.dart';
import '../../driver/driver_home_screen.dart';
import '../../manager/manager_waiting_screen/manager_waiting_screen.dart';
import '../../manager/manager_company_details/manager_company_details_screen.dart';
import '../signup/signup_screen.dart';
import '../forget_password/forget_password_popup.dart';

part 'login_data.dart';
part 'login_logic.dart';
part 'login_ui.dart';
