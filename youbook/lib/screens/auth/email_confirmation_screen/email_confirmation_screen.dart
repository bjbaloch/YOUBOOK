library email_confirmation_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../passenger/home_shell.dart';
import '../../manager/manager_company_details/manager_company_details_screen.dart';
import '../login/login_screen.dart';

part 'email_confirmation_data.dart';
part 'email_confirmation_logic.dart';
part 'email_confirmation_ui.dart';
