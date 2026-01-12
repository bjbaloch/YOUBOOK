import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  String _notificationMode = 'broadcast'; // 'broadcast' or 'user'
  String? _selectedUserId;
  List<User> _users = [];
  bool _isLoadingUsers = false;

  final List<String> _notificationTypes = ['info', 'success', 'warning', 'error'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_notificationMode == 'user') {
      _loadUsers();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      final users = await apiService.getUsers(limit: 1000); // Load all users for selection
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_notificationMode == 'user' && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      final notification = NotificationCreate(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
      );

      if (_notificationMode == 'broadcast') {
        await apiService.sendBroadcastNotification(notification);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Broadcast notification sent successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await apiService.sendUserNotification(_selectedUserId!, notification);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User notification sent successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      // Clear form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedType = 'info';
        _selectedUserId = null;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onModeChanged(String? mode) {
    if (mode != null) {
      setState(() {
        _notificationMode = mode;
        _selectedUserId = null;
        if (mode == 'user' && _users.isEmpty) {
          _loadUsers();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(
                text: 'Send Notifications',
                icon: Icon(Icons.send),
              ),
              Tab(
                text: 'Received',
                icon: Icon(Icons.notifications),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Send Notifications Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selection
                      const Text(
                        'Notification Mode',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Broadcast'),
                              subtitle: const Text('Send to all users'),
                              value: 'broadcast',
                              groupValue: _notificationMode,
                              onChanged: _onModeChanged,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Specific User'),
                              subtitle: const Text('Send to one user'),
                              value: 'user',
                              groupValue: _notificationMode,
                              onChanged: _onModeChanged,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // User Selection (only for user mode)
                      if (_notificationMode == 'user') ...[
                        const Text(
                          'Select User',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isLoadingUsers
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                value: _selectedUserId,
                                decoration: const InputDecoration(
                                  hintText: 'Choose a user...',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                items: _users.map((user) {
                                  return DropdownMenuItem<String>(
                                    value: user.id,
                                    child: Text('${user.fullName} (${user.email})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedUserId = value);
                                },
                                validator: (value) {
                                  if (_notificationMode == 'user' && value == null) {
                                    return 'Please select a user';
                                  }
                                  return null;
                                },
                              ),
                        const SizedBox(height: 24),
                      ],

                      // Notification Type
                      const Text(
                        'Notification Type',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _notificationTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(type), color: _getTypeColor(type)),
                                const SizedBox(width: 8),
                                Text(type.toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Notification Title',
                          hintText: 'Enter a clear, concise title...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Message Field
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText: 'Enter the notification message...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        maxLength: 500,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a message';
                          }
                          if (value.length < 10) {
                            return 'Message must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Preview Card
                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getTypeIcon(_selectedType),
                                    color: _getTypeColor(_selectedType),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Preview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _titleController.text.isEmpty ? 'Notification Title' : _titleController.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _messageController.text.isEmpty ? 'Notification message will appear here...' : _messageController.text,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _sendNotification,
                          icon: const Icon(Icons.send),
                          label: Text(
                            _notificationMode == 'broadcast'
                                ? 'Send to All Users'
                                : 'Send to User',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _notificationMode == 'broadcast'
                                ? AppColors.primary
                                : AppColors.success,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Card
                      Card(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Notification Tips',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Keep titles short and clear\n'
                                '• Use appropriate notification types\n'
                                '• Broadcast notifications reach all users\n'
                                '• User-specific notifications are more targeted',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Received Notifications Tab
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final notifications = notificationProvider.notifications;

                  return RefreshIndicator(
                    onRefresh: () => notificationProvider.loadNotifications(),
                    child: notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You\'ll receive notifications when new applications arrive',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationItem(notification, notificationProvider);
                            },
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, NotificationProvider provider) {
    final isRead = notification.isRead ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type ?? 'info').withOpacity(0.1),
          child: Icon(
            _getTypeIcon(notification.type ?? 'info'),
            color: _getTypeColor(notification.type ?? 'info'),
          ),
        ),
        title: Text(
          notification.title ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message ?? ''),
            const SizedBox(height: 4),
            Text(
              notification.createdAt != null
                  ? DateFormat('MMM dd, HH:mm').format(notification.createdAt!)
                  : '',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!isRead && notification.id != null) {
            provider.markAsRead(notification.id!);
          }
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'info':
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }
}
