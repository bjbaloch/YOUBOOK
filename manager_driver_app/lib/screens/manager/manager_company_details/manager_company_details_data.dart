part of manager_company_details_screen;

// Business type options
final List<String> _businessTypes = [
  'Bus Service',
  'Van Service',
  'Bus & Van Service',
];

// Business status options
final List<String> _businessStatuses = [
  'Currently Running',
  'Newly Registered',
];

// Registration authority options
final List<String> _registrationAuthorities = [
  'SECP',
  'Local Trade Office',
  'Transport Union',
];

// Service type options
final List<String> _serviceTypes = [
  'City to City (Intercity)',
  'Within City (Local)',
  'Both',
];

// Tax registration options
final List<String> _taxOptions = ['Yes', 'No'];

// Helper method to compress images
Future<File> _compressImage(File file) async {
  // TEMPORARILY DISABLE COMPRESSION TO FIX UI FREEZING
  // TODO: Re-enable compression with proper async handling when needed
  print('Image compression disabled - using original file');
  return file;
}

// Helper method to format CNIC input
void _formatCnic(String value, TextEditingController controller) {
  String numbers = value.replaceAll(RegExp(r'\D'), '');
  String formatted = '';
  if (numbers.length > 5) {
    formatted = numbers.substring(0, 5) + '-';
    if (numbers.length > 12) {
      formatted += numbers.substring(5, 12) + '-' + numbers.substring(12);
    } else if (numbers.length > 5) {
      formatted += numbers.substring(5);
    }
  } else {
    formatted = numbers;
  }
  if (formatted != value) {
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
