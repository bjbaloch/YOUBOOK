library manager_waiting_screen;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../manager_dashboard.dart';

part 'manager_waiting_data.dart';
part 'manager_waiting_logic.dart';
part 'manager_waiting_ui.dart';

class ManagerWaitingScreen extends StatefulWidget {
  final String? companyName;
  final String? credentialDetails;

  const ManagerWaitingScreen({
    super.key,
    this.companyName,
    this.credentialDetails,
  });

  @override
  State<ManagerWaitingScreen> createState() => _ManagerWaitingScreenState();
}
