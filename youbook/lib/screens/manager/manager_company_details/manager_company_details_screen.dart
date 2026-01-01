library manager_company_details_screen;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'
    as flutter_image_compress;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/snackbar_utils.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../manager_waiting_screen/manager_waiting_screen.dart';

part 'manager_company_details_data.dart';
part 'manager_company_details_logic.dart';
part 'manager_company_details_ui.dart';

class ManagerCompanyDetailsScreen extends StatefulWidget {
  const ManagerCompanyDetailsScreen({super.key});

  @override
  State<ManagerCompanyDetailsScreen> createState() =>
      _ManagerCompanyDetailsScreenState();
}
