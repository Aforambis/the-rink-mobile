import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_menu_item.dart';
import 'sellerprofile.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const ProfileScreen({
    super.key,
    required this.isLoggedIn,
    required this.onSignOut,
    required this.onSignIn,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  String? _userType;
  bool _isLoading = true;

  // Edit profile form controllers
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _fetchUserData();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final request = context.read<CookieRequest>();
    try {
      // Fetch user data and user type in parallel
      final userDataResponse = request.get(
        'http://localhost:8000/auth_mob/user/',
      );
      final userTypeResponse = request.get(
        'http://localhost:8000/auth_mob/user-type/',
      );

      final results = await Future.wait([userDataResponse, userTypeResponse]);

      if (mounted) {
        setState(() {
          _userData = results[0];
          _userType = results[1]?['user_type'];
          _isLoading = false;
        });
        // Populate form controllers with current data
        _populateFormData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  void _populateFormData() {
    if (_userData != null) {
      _fullNameController.text = _userData!['full_name'] ?? '';
      _phoneController.text = _userData!['phone_number'] ?? '';
      _emailController.text = _userData!['email'] ?? '';
      _dateOfBirthController.text = _userData!['date_of_birth'] ?? '';
      _addressController.text = _userData!['address'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .post('http://localhost:8000/auth_mob/profile/', {
            'full_name': _fullNameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'date_of_birth': _dateOfBirthController.text.isNotEmpty
                ? _dateOfBirthController.text
                : null,
            'address': _addressController.text.trim(),
          });

      if (response != null && response['status'] == true && mounted) {
        // Refresh user data
        await _fetchUserData();
        if (mounted) {
          Navigator.of(context).pop(); // Close modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to update profile'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildFormField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _dateOfBirthController,
                      label: 'Date of Birth',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 365 * 18),
                          ),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _dateOfBirthController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: widget.isLoggedIn
            ? _buildLoggedInView(context)
            : _buildGuestView(context),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final username = _userData?['username'] ?? 'User';
    final fullName = _getDisplayValue(_userData?['full_name']);
    final phoneNumber = _getDisplayValue(_userData?['phone_number']);
    final email = _getDisplayValue(_userData?['email']);
    final dateOfBirth = _userData?['date_of_birth'];
    final address = _getDisplayValue(_userData?['address']);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100), // Account for app bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👋 Hello, $username!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your profile and make your skating experience more personal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showEditProfileModal,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                        if (_userType == 'seller') ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerProfileScreen(
                                    isLoggedIn: widget.isLoggedIn,
                                    onSignOut: widget.onSignOut,
                                    onSignIn: widget.onSignIn,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.store, size: 16),
                            label: const Text('Seller Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF28a745),
                              side: const BorderSide(color: Color(0xFF28a745)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Profile Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.person,
                        label: 'FULL NAME',
                        value: fullName,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.phone,
                        label: 'PHONE NUMBER',
                        value: phoneNumber,
                        color: const Color(0xFF28a745),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.email,
                        label: 'EMAIL',
                        value: email,
                        color: const Color(0xFF17a2b8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.calendar_today,
                        label: 'DATE OF BIRTH',
                        value: dateOfBirth != null
                            ? _formatDate(dateOfBirth)
                            : 'Not Provided',
                        color: const Color(0xFFffc107),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.location_on,
                  label: 'ADDRESS',
                  value: address,
                  color: const Color(0xFFdc3545),
                  fullWidth: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Menu Items
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Booking History',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ProfileMenuItem(
                  icon: Icons.payment,
                  title: 'Payment Methods',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ProfileMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            maxLines: fullWidth ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'Not Provided';
    if (value is String && value.trim().isEmpty) return 'Not Provided';
    return value.toString();
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to The Rink',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, bookings, and more',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
