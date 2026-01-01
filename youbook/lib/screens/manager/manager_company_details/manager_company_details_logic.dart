part of manager_company_details_screen;

class _ManagerCompanyDetailsScreenState
    extends State<ManagerCompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Company Information
  final _companyNameController = TextEditingController();
  String? _selectedBusinessType;
  String? _selectedBusinessStatus;
  final _businessStartYearController = TextEditingController();

  // Business Registration Details
  final _registeredBusinessNameController = TextEditingController();
  String? _selectedRegistrationAuthority;
  final _registrationNumberController = TextEditingController();

  // Office Address
  final _officeAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _countryController = TextEditingController(text: 'Pakistan');

  // Operating Information
  String? _selectedServiceType;

  // Tax Information
  final _ntnController = TextEditingController();
  String? _selectedTaxRegistered;

  // Company Owner Details
  final _ownerNameController = TextEditingController();
  final _ownerCnicController = TextEditingController();
  File? _cnicFrontPhoto;
  File? _cnicBackPhoto;
  bool _isPickingFrontImage = false;
  bool _isPickingBackImage = false;

  // Company Documents
  File? _businessRegistrationDocument;

  // Agreements
  bool _confirmInformation = false;
  bool _understandConsequences = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessStartYearController.dispose();
    _registeredBusinessNameController.dispose();
    _registrationNumberController.dispose();
    _officeAddressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _ntnController.dispose();
    _ownerNameController.dispose();
    _ownerCnicController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    // Prevent multiple simultaneous image picks
    if ((isFront && _isPickingFrontImage) ||
        (!isFront && _isPickingBackImage)) {
      SnackBarUtils.showSnackBar(
        context,
        'Please wait for the current image to finish processing.',
        type: SnackBarType.other,
      );
      return;
    }

    setState(() {
      if (isFront) {
        _isPickingFrontImage = true;
      } else {
        _isPickingBackImage = true;
      }
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Show processing progress
        SnackBarUtils.showSnackBar(
          context,
          'Processing image...',
          type: SnackBarType.other,
        );

        // Compress the image
        final compressedFile = await _compressImage(File(image.path));

        setState(() {
          if (isFront) {
            _cnicFrontPhoto = compressedFile;
          } else {
            _cnicBackPhoto = compressedFile;
          }
        });

        // Show success message
        SnackBarUtils.showSnackBar(
          context,
          'Image compressed and selected successfully!',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        'Error picking image: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isFront) {
            _isPickingFrontImage = false;
          } else {
            _isPickingBackImage = false;
          }
        });
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);

        // Check file size and show warning if too large
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSizeMB > 10) {
          SnackBarUtils.showSnackBar(
            context,
            'Warning: File size is ${fileSizeMB.toStringAsFixed(1)}MB. Large files may cause issues.',
            type: SnackBarType.other,
          );
        }

        setState(() {
          _businessRegistrationDocument = file;
        });
      }
    } catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        'Error picking document: $e',
        type: SnackBarType.error,
      );
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    if (_selectedBusinessType == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please select business type',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_selectedBusinessStatus == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please select business status',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_selectedRegistrationAuthority == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please select registration authority',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_selectedServiceType == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please select service type',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_cnicFrontPhoto == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please upload CNIC front photo',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_cnicBackPhoto == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please upload CNIC back photo',
        type: SnackBarType.error,
      );
      return false;
    }
    if (_businessRegistrationDocument == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please upload business registration document',
        type: SnackBarType.error,
      );
      return false;
    }
    if (!_confirmInformation) {
      SnackBarUtils.showSnackBar(
        context,
        'Please confirm that the information provided is true',
        type: SnackBarType.error,
      );
      return false;
    }
    if (!_understandConsequences) {
      SnackBarUtils.showSnackBar(
        context,
        'Please confirm that you understand the consequences',
        type: SnackBarType.error,
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService();

      // Compile company details as JSON string
      final companyDetails = {
        'companyName': _companyNameController.text.trim(),
        'businessType': _selectedBusinessType,
        'businessStatus': _selectedBusinessStatus,
        'businessStartYear': _businessStartYearController.text.trim(),
        'registeredBusinessName': _registeredBusinessNameController.text.trim(),
        'registrationAuthority': _selectedRegistrationAuthority,
        'registrationNumber': _registrationNumberController.text.trim(),
        'officeAddress': _officeAddressController.text.trim(),
        'city': _cityController.text.trim(),
        'province': _provinceController.text.trim(),
        'country': _countryController.text.trim(),
        'serviceType': _selectedServiceType,
        'ntn': _ntnController.text.trim(),
        'taxRegistered': _selectedTaxRegistered,
        'ownerName': _ownerNameController.text.trim(),
        'ownerCnic': _ownerCnicController.text.trim(),
        'cnicFrontPhoto': _cnicFrontPhoto?.path,
        'cnicBackPhoto': _cnicBackPhoto?.path,
        'businessRegistrationDocument': _businessRegistrationDocument?.path,
      };

      // Apply for manager role with company details
      final success = await authProvider.applyForManager(
        _companyNameController.text.trim(),
        companyDetails.toString(),
      );

      if (success) {
        SnackBarUtils.showSnackBar(
          context,
          'Business details submitted successfully!',
          type: SnackBarType.success,
        );

        // Navigate to waiting screen with company details
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerWaitingScreen(
                companyName: _companyNameController.text.trim(),
                credentialDetails: companyDetails.toString(),
              ),
            ),
          );
        }
      } else {
        // Log the error for debugging
        print(
          'DEBUG: applyForManager returned false - check database setup and RLS policies',
        );
        SnackBarUtils.showSnackBar(
          context,
          'Failed to submit business details. Please check database setup and try again.',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      // Show more specific error messages
      String errorMessage = 'Error submitting company details';
      if (e.toString().contains('already have a pending application')) {
        errorMessage =
            'You already have a pending application. Please wait for approval.';
      } else if (e.toString().contains('JWT')) {
        errorMessage = 'Authentication error. Please log out and log back in.';
      } else if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        errorMessage =
            'Database not set up properly. Please run the SQL setup script.';
      } else if (e.toString().contains('permission denied')) {
        errorMessage = 'Permission denied. Please check database policies.';
      }

      SnackBarUtils.showSnackBar(
        context,
        '$errorMessage: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildManagerCompanyDetailsUI(this);
}
