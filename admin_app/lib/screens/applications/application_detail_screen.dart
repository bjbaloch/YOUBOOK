import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final ManagerApplication application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isProcessing = false;

  Future<void> _approveApplication({String? reviewNotes}) async {
    setState(() => _isProcessing = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.approveApplication(widget.application.id, reviewNotes: reviewNotes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.application.userFullName ?? 'User'} application approved'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate status changed
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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

  Future<void> _rejectApplication({String? reviewNotes}) async {
    setState(() => _isProcessing = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.rejectApplication(widget.application.id, reviewNotes: reviewNotes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.application.userFullName ?? 'User'} application rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate status changed
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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

  void _showReviewDialog(bool approve) {
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Application' : 'Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add review notes for ${widget.application.userFullName ?? 'user'} application (optional):',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                hintText: 'Enter review notes...',
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
                _approveApplication(reviewNotes: notes);
              } else {
                _rejectApplication(reviewNotes: notes);
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;

    return Scaffold(
      appBar: AppBar(
        title: Text('${application.userFullName ?? 'Unknown User'} Application'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: _getStatusColor(application.status),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(application.status),
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Status: ${application.status.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // User Information
                _buildDetailSection(
                  'User Information',
                  [
                    _buildDetailRow('Full Name', application.userFullName ?? 'N/A'),
                    _buildDetailRow('Email', application.userEmail ?? 'N/A'),
                  ],
                ),

                // Company Information
                _buildDetailSection(
                  'Company Information',
                  [
                    _buildDetailRow('Company Name', application.companyName),
                  ],
                ),

                // Application Details
                _buildDetailSection(
                  'Application Details',
                  [
                    _buildDetailRow('Applied Date', DateFormat('MMMM dd, yyyy').format(application.createdAt)),
                    if (application.updatedAt != null)
                      _buildDetailRow('Reviewed Date', DateFormat('MMMM dd, yyyy').format(application.updatedAt!)),
                    const SizedBox(height: 16),
                    const Text(
                      'Credential Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        application.credentialDetails,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),

                // Review Information (if exists)
                if (application.reviewNotes != null || application.reviewedBy != null)
                  _buildDetailSection(
                    'Review Information',
                    [
                      if (application.reviewedBy != null)
                        _buildDetailRow('Reviewed By', application.reviewedBy!),
                      if (application.reviewNotes != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Review Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            application.reviewNotes!,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),

          // Bottom Action Buttons (only for pending applications)
          if (application.status == 'pending')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _showReviewDialog(false),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _showReviewDialog(true),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }
}
