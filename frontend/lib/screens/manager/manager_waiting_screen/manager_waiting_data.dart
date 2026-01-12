part of manager_waiting_screen;

// Utility method to check internet connectivity
Future<bool> _hasInternet() async {
  try {
    final res = await InternetAddress.lookup(
      'example.com',
    ).timeout(const Duration(seconds: 2));
    return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
