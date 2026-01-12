import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/core.dart';
import '../../core/widgets/main_layout.dart';
import '../applications/applications_screen.dart';
import '../users/users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  StreamSubscription? _applicationsSubscription;
  StreamSubscription? _usersSubscription;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;

    // Listen for application changes
    _applicationsSubscription = supabase
        .from('manager_applications')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadStats(); // Refresh stats when applications change
          }
        });

    // Listen for user changes
    _usersSubscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadStats(); // Refresh stats when users change
          }
        });
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      );
      final apiService = authProvider.getApiService();
      final stats = await apiService.getStats();

      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stats: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'YOUBOOK Admin Dashboard',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Real-time manager application management',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            'View Applications',
                            Icons.file_present,
                            AppColors.primary,
                            () => Navigator.of(context).pushNamed('/applications'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            'Manage Users',
                            Icons.people,
                            AppColors.accent,
                            () => Navigator.of(context).pushNamed('/users'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Live Stats
                    Row(
                      children: [
                        Text(
                          'Live Statistics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Real-time',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_stats != null) ...[
                      // Application Stats (Priority)
                      Row(
                        children: [
                          Expanded(
                            child: _buildClickableStatCard(
                              context,
                              'Pending Applications',
                              (_stats!['manager_applications'] as Map<String, dynamic>?)?['pending'] ?? 0,
                              Icons.pending_actions,
                              AppColors.warning,
                              'Requires attention',
                              () => _navigateToApplications('pending'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildClickableStatCard(
                              context,
                              'Approved Today',
                              (_stats!['manager_applications'] as Map<String, dynamic>?)?['approved'] ?? 0,
                              Icons.check_circle,
                              AppColors.success,
                              'Processed',
                              () => _navigateToApplications('approved'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // User Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildClickableStatCard(
                              context,
                              'Total Managers',
                              (_stats!['users_by_role'] as Map<String, dynamic>?)?['manager'] ?? 0,
                              Icons.business,
                              AppColors.success,
                              'Active managers',
                              () => _navigateToUsers('manager'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildClickableStatCard(
                              context,
                              'Total Users',
                              (_stats!['users_by_role'] as Map<String, dynamic>?)?.values.fold<int>(
                                0,
                                (sum, count) => sum + ((count as int?) ?? 0),
                              ) ?? 0,
                              Icons.people,
                              AppColors.primary,
                              'All registered users',
                              () => _navigateToUsers('all'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Recent Activity
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildActivityItem(
                              'System initialized',
                              'Dashboard loaded successfully',
                              Icons.info,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Real-time connected',
                              'Live data streaming active',
                              Icons.wifi,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Applications monitoring',
                              'Tracking ${(_stats!['manager_applications'] as Map<String, dynamic>?)?['pending'] ?? 0} pending applications',
                              Icons.visibility,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatCard(
    BuildContext context,
    String title,
    dynamic value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableStatCard(
    BuildContext context,
    String title,
    dynamic value,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToApplications(String status) {
    // Navigate to applications screen with the specified status filter
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainLayout(
          title: 'Applications',
          child: ApplicationsScreen(initialStatus: status),
        ),
      ),
    );
  }

  void _navigateToUsers(String role) {
    // Navigate to users screen with the specified role filter
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainLayout(
          title: 'Users',
          child: UsersScreen(initialRole: role),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }
}
