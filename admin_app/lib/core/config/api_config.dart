class ApiConfig {
  // Base API URL - change this to your backend URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // API endpoints
  static const String login = '/admin/login';
  static const String signup = '/admin/signup';
  static const String resendConfirmation = '/admin/resend-confirmation';
  static const String stats = '/admin/stats';
  static const String users = '/admin/users';
  static const String managerApplications = '/admin/manager-applications';
  static const String notificationsBroadcast = '/admin/notifications/broadcast';
  static String notificationUser(String userId) => '/admin/notifications/user/$userId';
  static String updateUserRole(String userId) => '/admin/users/$userId/role';
  static String approveApplication(String applicationId) => '/admin/manager-applications/$applicationId/approve';
  static String rejectApplication(String applicationId) => '/admin/manager-applications/$applicationId/reject';

  // HTTP headers
  static Map<String, String> getHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}