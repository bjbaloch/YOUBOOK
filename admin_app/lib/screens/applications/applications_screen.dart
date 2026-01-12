import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/core.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  final String? initialStatus;

  const ApplicationsScreen({super.key, this.initialStatus});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<ManagerApplication> _applications = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  final List<String> _statuses = ['all', 'pending', 'approved', 'rejected'];
  StreamSubscription? _applicationsSubscription;

  @override
  void initState() {
    super.initState();
    // Set initial status if provided
    if (widget.initialStatus != null && _statuses.contains(widget.initialStatus)) {
      _selectedStatus = widget.initialStatus!;
    }
    _loadApplications();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    final supabase = Supabase.instance.client;

    _applicationsSubscription = supabase
        .from('manager_applications')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadApplications(); // Refresh data when changes occur
          }
        });
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      final status = _selectedStatus == 'all' ? null : _selectedStatus;
      final applications = await apiService.getManagerApplications(status: status);

      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load applications: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _approveApplication(ManagerApplication application, {String? reviewNotes}) async {
    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.approveApplication(application.id, reviewNotes: reviewNotes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${application.userFullName ?? 'User'} application approved'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectApplication(ManagerApplication application, {String? reviewNotes}) async {
    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.rejectApplication(application.id, reviewNotes: reviewNotes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${application.userFullName ?? 'User'} application rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showApplicationDetails(ManagerApplication application) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ApplicationDetailScreen(application: application),
      ),
    );

    // If result is true, status was changed, refresh the list
    if (result == true) {
      _loadApplications();
    }
  }

  void _showReviewDialog(ManagerApplication application, bool approve) {
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Application' : 'Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Review notes for ${application.userFullName ?? 'user'} application:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                hintText: 'Optional review notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final notes = reviewController.text.trim().isEmpty ? null : reviewController.text.trim();
              if (approve) {
                _approveApplication(application, reviewNotes: notes);
              } else {
                _rejectApplication(application, reviewNotes: notes);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.success : AppColors.error,
            ),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _applications.where((app) => app.status == 'pending').length;

    return Column(
      children: [
        // Header with stats
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Manager Applications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: pendingCount > 0 ? AppColors.warning.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pending,
                          size: 16,
                          color: pendingCount > 0 ? AppColors.warning : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$pendingCount Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: pendingCount > 0 ? AppColors.warning : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter tabs
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: _statuses.map((status) {
                    final isSelected = _selectedStatus == status;
                    final count = status == 'all'
                        ? _applications.length
                        : _applications.where((app) => app.status == status).length;

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedStatus = status);
                          _loadApplications();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${status == 'all' ? 'All' : status.capitalize()} ($count)',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Applications table
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_present,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No applications found',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadApplications,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _applications.length,
                        itemBuilder: (context, index) {
                          final application = _applications[index];
                          return _buildApplicationRow(application);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildApplicationRow(ManagerApplication application) {
    final statusColor = _getStatusColor(application.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[100],
                    child: Text(
                      (application.userFullName ?? application.userEmail ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.userFullName ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          application.userEmail ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Company info
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      application.companyName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date and actions
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(application.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (application.status == 'pending') ...[
                    TextButton.icon(
                      onPressed: () => _approveApplication(application),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _rejectApplication(application),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ] else ...[
                    TextButton.icon(
                      onPressed: () => _showApplicationDetails(application),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
