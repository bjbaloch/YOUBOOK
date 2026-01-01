library signup_screen;

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../login/login_screen.dart';
import '../email_confirmation_screen/email_confirmation_screen.dart';

part 'signup_data.dart';
part 'signup_logic.dart';
part 'signup_ui.dart';
