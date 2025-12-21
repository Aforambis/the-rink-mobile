import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/users/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response['users']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load users')));
      }
    }
  }

  Future<void> _updateUser(Map<String, dynamic> user) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/users/${user['id']}/',
        {
          'first_name': user['first_name'] ?? '',
          'last_name': user['last_name'] ?? '',
          'email': user['email'] ?? '',
          'is_active': user['is_active'] ?? true,
          'user_type': user['user_type'] ?? 'customer',
          'full_name': user['full_name'] ?? '',
          'phone_number': user['phone_number'] ?? '',
          'address': user['address'] ?? '',
        },
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
        _fetchUsers(); // Refresh the list
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update user')));
    }
  }

  Future<void> _deleteUser(int userId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/users/$userId/delete/',
        {}, // Empty body for delete
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _fetchUsers(); // Refresh the list
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete user')));
    }
  }

  void _showUserEditDialog(Map<String, dynamic> user) {
    final firstNameController = TextEditingController(
      text: user['first_name'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: user['last_name'] ?? '',
    );
    final emailController = TextEditingController(text: user['email'] ?? '');
    final fullNameController = TextEditingController(
      text: user['full_name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: user['phone_number'] ?? '',
    );
    final addressController = TextEditingController(
      text: user['address'] ?? '',
    );
    String selectedUserType = user['user_type'] ?? 'customer';
    bool isActive = user['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User: ${user['username']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              DropdownButtonFormField<String>(
                value: selectedUserType,
                decoration: const InputDecoration(labelText: 'User Type'),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'seller', child: Text('Seller')),
                ],
                onChanged: (value) {
                  selectedUserType = value!;
                },
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) {
                  isActive = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUser = Map<String, dynamic>.from(user);
              updatedUser['first_name'] = firstNameController.text;
              updatedUser['last_name'] = lastNameController.text;
              updatedUser['email'] = emailController.text;
              updatedUser['full_name'] = fullNameController.text;
              updatedUser['phone_number'] = phoneController.text;
              updatedUser['address'] = addressController.text;
              updatedUser['user_type'] = selectedUserType;
              updatedUser['is_active'] = isActive;

              _updateUser(updatedUser);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete user "$username"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(userId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUsers),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _users.isEmpty
            ? const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user['is_superuser'] == true
                            ? Colors.red
                            : user['user_type'] == 'seller'
                            ? Colors.green
                            : Colors.blue,
                        child: Icon(
                          user['is_superuser'] == true
                              ? Icons.admin_panel_settings
                              : user['user_type'] == 'seller'
                              ? Icons.store
                              : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        user['full_name']?.isNotEmpty == true
                            ? user['full_name']
                            : user['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${user['username']}'),
                          Text(user['email'] ?? 'No email'),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: user['user_type'] == 'seller'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user['user_type'] == 'seller'
                                      ? 'Seller'
                                      : 'Customer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user['user_type'] == 'seller'
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: user['is_active'] == true
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user['is_active'] == true
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user['is_active'] == true
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                              if (user['is_superuser'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showUserEditDialog(user);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(
                              user['id'],
                              user['username'],
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
