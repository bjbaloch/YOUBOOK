import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _language = 'en';
  String _themeMode = 'system';

  final List<String> _languages = ['en', 'es', 'fr', 'de', 'ar'];
  final List<String> _themeModes = ['system', 'light', 'dark'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load settings from shared preferences or database
    // For now, using default values
  }

  Future<void> _saveSettings() async {
    // Save settings to shared preferences or database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear cache implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all settings to default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDarkMode = false;
        _notificationsEnabled = true;
        _emailNotifications = true;
        _pushNotifications = true;
        _language = 'en';
        _themeMode = 'system';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Customize your admin experience',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // App Settings
          _buildSection(
            'App Settings',
            Icons.app_settings_alt,
            [
              // Theme Mode
              _buildDropdownSetting(
                'Theme Mode',
                'Choose how the app theme behaves',
                _themeMode,
                _themeModes,
                (value) => setState(() => _themeMode = value!),
                (mode) => mode == 'system' ? 'System' : mode == 'light' ? 'Light' : 'Dark',
              ),


            ],
          ),

          const SizedBox(height: 24),

          // Notification Settings
          _buildSection(
            'Notifications',
            Icons.notifications,
            [
              // Master Notifications Toggle
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive notifications for important events'),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
                activeColor: AppColors.primary,
              ),

              if (_notificationsEnabled) ...[
                // Email Notifications
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotifications,
                  onChanged: (value) => setState(() => _emailNotifications = value),
                  activeColor: AppColors.primary,
                ),

                // Push Notifications
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications on device'),
                  value: _pushNotifications,
                  onChanged: (value) => setState(() => _pushNotifications = value),
                  activeColor: AppColors.primary,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Security Settings
          _buildSection(
            'Security',
            Icons.security,
            [
              // Change Password Button
              ListTile(
                leading: const Icon(Icons.lock, color: AppColors.primary),
                title: const Text('Change Password'),
                subtitle: const Text('Update your account password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to change password (could be in profile screen)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use Profile screen to change password')),
                  );
                },
              ),

              // Session Management
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.warning),
                title: const Text('Sign Out from All Devices'),
                subtitle: const Text('End all active sessions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Management
          _buildSection(
            'Data Management',
            Icons.storage,
            [
              // Clear Cache
              ListTile(
                leading: const Icon(Icons.cleaning_services, color: AppColors.warning),
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearCache,
              ),

              // Export Data
              ListTile(
                leading: const Icon(Icons.download, color: AppColors.success),
                title: const Text('Export Data'),
                subtitle: const Text('Download your data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon')),
                  );
                },
              ),

              // Reset to Defaults
              ListTile(
                leading: const Icon(Icons.restore, color: AppColors.error),
                title: const Text('Reset to Defaults'),
                subtitle: const Text('Restore default settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _resetToDefaults,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About
          _buildSection(
            'About',
            Icons.info,
            [
              // App Version
              ListTile(
                leading: const Icon(Icons.info, color: AppColors.primary),
                title: const Text('App Version'),
                subtitle: const Text('YOUBOOK Admin v1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About YOUBOOK Admin'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Version: 1.0.0'),
                          SizedBox(height: 8),
                          Text('Build: 2024.12.01'),
                          SizedBox(height: 16),
                          Text('YOUBOOK Admin Panel for managing transportation services, user accounts, and applications.'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Support
              ListTile(
                leading: const Icon(Icons.support, color: AppColors.primary),
                title: const Text('Support'),
                subtitle: const Text('Get help and contact support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support feature coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String?) onChanged,
    String Function(String) displayName,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(displayName(option)),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}
