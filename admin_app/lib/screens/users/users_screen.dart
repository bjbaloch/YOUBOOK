import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';

class UsersScreen extends StatefulWidget {
  final String? initialRole;

  const UsersScreen({super.key, this.initialRole});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'all';
  int _currentPage = 0;
  final int _pageSize = 50;
  bool _hasMoreData = true;

  final List<String> _roles = ['all', 'passenger', 'driver', 'manager', 'admin'];

  @override
  void initState() {
    super.initState();
    // Set initial role if provided
    if (widget.initialRole != null && _roles.contains(widget.initialRole)) {
      _selectedRole = widget.initialRole!;
    }
    _loadUsers();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _users.clear();
    }

    if (!_hasMoreData && !refresh) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      final role = _selectedRole == 'all' ? null : _selectedRole;
      final search = _searchQuery.isEmpty ? null : _searchQuery;

      final newUsers = await apiService.getUsers(
        skip: _currentPage * _pageSize,
        limit: _pageSize,
        role: role,
        search: search,
      );

      setState(() {
        if (refresh) {
          _users = newUsers;
        } else {
          _users.addAll(newUsers);
        }
        _currentPage++;
        _hasMoreData = newUsers.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _updateUserRole(User user, String newRole) async {
    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.updateUserRole(user.id, newRole);

      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user.copyWith(
            role: newRole,
            updatedAt: DateTime.now(),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} role updated to $newRole'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _suspendUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user.fullName}? They will not be able to log in until reactivated.'),
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
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.suspendUser(user.id);

      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user.copyWith(
            isActive: false,
            updatedAt: DateTime.now(),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} has been suspended'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to suspend user: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _activateUser(User user) async {
    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.activateUser(user.id);

      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user.copyWith(
            isActive: true,
            updatedAt: DateTime.now(),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} has been activated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate user: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user.fullName}? This action cannot be undone and will remove all associated data.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.deleteUser(user.id);

      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} has been deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resetUserPassword(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send password reset email to ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      await apiService.resetUserPassword(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${user.email}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.fullName} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Role', user.role.toUpperCase()),
            _buildDetailRow('Status', user.isActive ? 'Active' : 'Suspended'),
            if (user.phoneNumber != null) _buildDetailRow('Phone', user.phoneNumber!),
            if (user.createdAt != null) _buildDetailRow('Joined', user.createdAt!.toString().split(' ')[0]),
            if (user.updatedAt != null) _buildDetailRow('Last Updated', user.updatedAt!.toString().split(' ')[0]),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Column(
            children: [
              // Search Bar
              TextField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search users by name or email...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _loadUsers(refresh: true);
                },
              ),
              const SizedBox(height: 8),
              // Role Filter
              DropdownButtonFormField<String>(
                value: _selectedRole,
                style: const TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role == 'all' ? 'All Roles' : role.toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectedRole = value;
                    _loadUsers(refresh: true);
                  }
                },
              ),
            ],
          ),
        ),
        // Body Content
        Expanded(
          child: Stack(
            children: [
              _isLoading && _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadUsers(refresh: true),
                    child: ListView.builder(
                      itemCount: _users.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _users.length) {
                          // Load more indicator
                          _loadUsers();
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final user = _users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRoleColor(user.role),
                              child: Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                if (user.phoneNumber != null) Text(user.phoneNumber!),
                                Text(
                                  'Role: ${user.role.toUpperCase()}',
                                  style: TextStyle(
                                    color: _getRoleColor(user.role),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) => _handleUserAction(user, action),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view_details',
                                  child: ListTile(
                                    leading: Icon(Icons.visibility, color: Colors.white),
                                    title: Text('View Details', style: TextStyle(color: Colors.white)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'change_role',
                                  child: ListTile(
                                    leading: Icon(Icons.edit, color: Colors.green),
                                    title: Text('Change Role'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                if (user.isActive)
                                  const PopupMenuItem(
                                    value: 'suspend',
                                    child: ListTile(
                                      leading: Icon(Icons.pause, color: Colors.orange),
                                      title: Text('Suspend User'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                else
                                  const PopupMenuItem(
                                    value: 'activate',
                                    child: ListTile(
                                      leading: Icon(Icons.play_arrow, color: Colors.green),
                                      title: Text('Activate User'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'reset_password',
                                  child: ListTile(
                                    leading: Icon(Icons.lock_reset, color: Colors.blue),
                                    title: Text('Reset Password'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text('Delete User'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _loadUsers(refresh: true),
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleUserAction(User user, String action) {
    switch (action) {
      case 'view_details':
        _viewUserDetails(user);
        break;
      case 'change_role':
        _showRoleChangeDialog(user);
        break;
      case 'suspend':
        _suspendUser(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showRoleChangeDialog(User user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Role for ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select new role:'),
              const SizedBox(height: 16),
              ..._roles.where((role) => role != 'all').map((role) {
                return RadioListTile<String>(
                  title: Text(role.toUpperCase()),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                  dense: true,
                );
              }),
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
                if (selectedRole != user.role) {
                  _updateUserRole(user, selectedRole);
                }
              },
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'manager':
        return AppColors.success;
      case 'driver':
        return AppColors.warning;
      case 'passenger':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
