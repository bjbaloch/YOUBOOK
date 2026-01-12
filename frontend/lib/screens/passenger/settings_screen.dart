import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/profile_storage_service.dart';
import '../auth/login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationServices = true;
  bool _biometricAuth = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'PKR';

  final List<String> _languages = ['English', 'Urdu', 'Arabic'];
  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load user preferences from storage
      // For now, using default values
      setState(() {
        // These would be loaded from shared preferences or API
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      // Save settings to storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save settings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: cs.primary,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          title: Text(
            "Settings",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account Settings'),
              const SizedBox(height: 16),
              _buildSettingCard([
                _buildListTile(
                  icon: Icons.person,
                  title: 'Profile Information',
                  subtitle: 'Update your personal details',
                  onTap: () => _navigateToProfile(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _navigateToChangePassword(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.email,
                  title: 'Change Email',
                  subtitle: 'Update your email address',
                  onTap: () => _navigateToChangeEmail(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.phone,
                  title: 'Change Phone Number',
                  subtitle: 'Update your phone number',
                  onTap: () => _navigateToChangePhone(),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('Preferences'),
              const SizedBox(height: 16),
              _buildSettingCard([
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  subtitle: 'Receive booking updates and alerts',
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.location_on,
                  title: 'Location Services',
                  subtitle: 'Allow access to location for better service',
                  value: _locationServices,
                  onChanged: (value) => setState(() => _locationServices = value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint/face unlock',
                  value: _biometricAuth,
                  onChanged: (value) => setState(() => _biometricAuth = value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('Regional Settings'),
              const SizedBox(height: 16),
              _buildSettingCard([
                _buildDropdownTile(
                  icon: Icons.language,
                  title: 'Language',
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) => setState(() => _selectedLanguage = value!),
                ),
                _buildDivider(),
                _buildDropdownTile(
                  icon: Icons.currency_exchange,
                  title: 'Currency',
                  value: _selectedCurrency,
                  items: _currencies,
                  onChanged: (value) => setState(() => _selectedCurrency = value!),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('Support & Legal'),
              const SizedBox(height: 16),
              _buildSettingCard([
                _buildListTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _navigateToSupport(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _openPrivacyPolicy(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => _openTermsOfService(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.info,
                  title: 'About YOUBOOK',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('Account Actions'),
              const SizedBox(height: 16),
              _buildSettingCard([
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  textColor: Colors.red,
                  onTap: () => _confirmLogout(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  textColor: Colors.red,
                  onTap: () => _confirmDeleteAccount(),
                ),
              ]),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textColor?.withOpacity(0.7) ?? cs.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: cs.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: cs.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: cs.primary),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
    );
  }

  void _navigateToProfile() {
    // TODO: Navigate to profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile screen - Coming soon')),
    );
  }

  void _navigateToChangePassword() {
    // TODO: Navigate to change password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password screen - Coming soon')),
    );
  }

  void _navigateToChangeEmail() {
    // TODO: Navigate to change email screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change email screen - Coming soon')),
    );
  }

  void _navigateToChangePhone() {
    // TODO: Navigate to change phone screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change phone screen - Coming soon')),
    );
  }

  void _navigateToSupport() {
    // TODO: Navigate to support screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support screen - Coming soon')),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy - Coming soon')),
    );
  }

  void _openTermsOfService() {
    // TODO: Open terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service - Coming soon')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About YOUBOOK'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('YOUBOOK is your trusted transportation partner, '
                 'connecting passengers with reliable bus and van services '
                 'across Pakistan.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone and all your data will be permanently removed.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performAccountDeletion();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    try {
      // TODO: Clear user session and navigate to login
      await ProfileStorageService.clearProfileData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  void _performAccountDeletion() {
    // TODO: Implement account deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deletion - Coming soon')),
    );
  }
}
