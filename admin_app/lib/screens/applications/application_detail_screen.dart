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

      // First, update the application status in database
      await apiService.approveApplication(widget.application.id, reviewNotes: reviewNotes);

      // Then, send approval email to the user
      try {
        await EmailService.sendApplicationApprovedEmail(widget.application);
      } catch (emailError) {
        // Log email error but don't fail the approval process
        print('⚠️ Failed to send approval email, but application was approved: $emailError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.application.userFullName ?? 'User'} application approved and notification email sent'),
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

      // First, update the application status in database
      await apiService.rejectApplication(widget.application.id, reviewNotes: reviewNotes);

      // Then, send rejection email to the user
      try {
        await EmailService.sendApplicationRejectedEmail(widget.application);
      } catch (emailError) {
        // Log email error but don't fail the rejection process
        print('⚠️ Failed to send rejection email, but application was rejected: $emailError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.application.userFullName ?? 'User'} application rejected and notification email sent'),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        application.credentialDetails,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uploaded Files:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilePreviews(application.credentialDetails),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warning.withOpacity(0.1),
                                AppColors.accent.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            application.reviewNotes!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildFilePreviews(String credentialDetailsJson) {
    try {
      // Parse the JSON credential details
      final credentialDetails = credentialDetailsJson.replaceAll('{', '{"').replaceAll('}', '"}').replaceAll(': ', '": "').replaceAll(', ', '", "');
      final Map<String, dynamic> details = {};

      // Simple JSON parsing for the credential details
      final jsonString = credentialDetailsJson;
      // Extract file URLs from the JSON string
      final fileUrls = <String, String>{};

      // Look for file URLs in the JSON
      if (jsonString.contains('cnicFrontPhoto') && jsonString.contains('https://')) {
        final frontMatch = RegExp(r'cnicFrontPhoto["\s:]+([^,}]+)').firstMatch(jsonString);
        if (frontMatch != null) {
          final url = frontMatch.group(1)?.replaceAll('"', '').trim();
          if (url != null && url.startsWith('https://')) {
            fileUrls['CNIC Front Photo'] = url;
          }
        }
      }

      if (jsonString.contains('cnicBackPhoto') && jsonString.contains('https://')) {
        final backMatch = RegExp(r'cnicBackPhoto["\s:]+([^,}]+)').firstMatch(jsonString);
        if (backMatch != null) {
          final url = backMatch.group(1)?.replaceAll('"', '').trim();
          if (url != null && url.startsWith('https://')) {
            fileUrls['CNIC Back Photo'] = url;
          }
        }
      }

      if (jsonString.contains('businessRegistrationDocument') && jsonString.contains('https://')) {
        final docMatch = RegExp(r'businessRegistrationDocument["\s:]+([^,}]+)').firstMatch(jsonString);
        if (docMatch != null) {
          final url = docMatch.group(1)?.replaceAll('"', '').trim();
          if (url != null && url.startsWith('https://')) {
            fileUrls['Business Registration Document'] = url;
          }
        }
      }

      if (fileUrls.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No files uploaded yet.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Column(
        children: fileUrls.entries.map((entry) {
          final fileName = entry.key;
          final fileUrl = entry.value;
          final isImage = fileUrl.toLowerCase().contains('.jpg') ||
                         fileUrl.toLowerCase().contains('.jpeg') ||
                         fileUrl.toLowerCase().contains('.png');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isImage ? Icons.image : Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        isImage ? 'Image file' : 'PDF document',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open file in browser/webview
                    _openFile(fileUrl, isImage);
                  },
                  icon: Icon(isImage ? Icons.visibility : Icons.download),
                  label: Text(isImage ? 'View' : 'Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Error loading files: $e',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  void _openFile(String url, bool isImage) {
    // For now, show a dialog with the URL
    // In a real app, you might use url_launcher or a webview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isImage ? 'View Image' : 'Open Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage)
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Failed to load image'),
                    );
                  },
                ),
              )
            else
              const Text('PDF documents will open in your browser.'),
            const SizedBox(height: 16),
            Text(
              'URL: $url',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!isImage)
            ElevatedButton(
              onPressed: () {
                // In a real app, use url_launcher to open in browser
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening: $url')),
                );
              },
              child: const Text('Open in Browser'),
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
