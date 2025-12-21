import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_menu_item.dart';

class FullProfileScreen extends StatefulWidget {
  const FullProfileScreen({super.key});

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen> {
  Map<String, dynamic>? _userData;
  String _userType = 'customer';
  bool _isLoading = true;
  List<dynamic> _products = [];

  // Edit profile form controllers
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();

  // Seller-specific controllers
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Add product form controllers
  final _productFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productStockController = TextEditingController();
  final _productImageUrlController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  String _selectedCategory = 'hockey';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productStockController.dispose();
    _productImageUrlController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final request = context.read<CookieRequest>();
    try {
      final userDataResponse = request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/user/',
      );

      final userData = await userDataResponse;

      if (mounted && userData != null) {
        setState(() {
          _userData = userData;
          _userType = userData['user_type'] ?? 'customer';
          _isLoading = false;
        });

        _populateFormData();

        if (_userType == 'seller') {
          _fetchProducts();
        }
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

  Future<void> _fetchProducts() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/rental_gear/api/flutter/seller/gears/',
      );
      print('Products API Response: $response'); // Debug logging
      if (response != null && mounted) {
        // Handle different response formats
        if (response is List) {
          setState(() {
            _products = response;
          });
        } else if (response['gears'] != null) {
          setState(() {
            _products = response['gears'];
          });
        } else if (response['products'] != null) {
          setState(() {
            _products = response['products'];
          });
        } else {
          print('Unexpected response format: $response');
        }
      }
    } catch (e) {
      print('Error fetching products: $e'); // Debug logging
      // Products loading failure doesn't break the profile
    }
  }

  void _populateFormData() {
    if (_userData != null) {
      _fullNameController.text = _userData!['full_name'] ?? '';
      _phoneController.text = _userData!['phone_number'] ?? '';
      _emailController.text = _userData!['email'] ?? '';
      _dateOfBirthController.text = _userData!['date_of_birth'] ?? '';
      _addressController.text = _userData!['address'] ?? '';

      if (_userType == 'seller') {
        _businessNameController.text = _userData!['business_name'] ?? '';
        _businessAddressController.text = _userData!['business_address'] ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    try {
      final profileResponse = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/profile/',
        {
          'full_name': _fullNameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'date_of_birth': _dateOfBirthController.text.isNotEmpty
              ? _dateOfBirthController.text
              : null,
          'address': _addressController.text.trim(),
        },
      );

      if (_userType == 'seller') {
        await request.post(
          'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth/seller-profile/update/',
          {
            'business_name': _businessNameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'business_address': _businessAddressController.text.trim(),
          },
        );
      }

      if (profileResponse != null &&
          profileResponse['status'] == true &&
          mounted) {
        await _fetchUserData();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileResponse?['message'] ?? 'Failed to update profile',
            ),
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

  Future<void> _createProduct() async {
    if (!_productFormKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/rental_gear/create-gear/',
        {
          'name': _productNameController.text.trim(),
          'category': _selectedCategory,
          'price_per_day': double.parse(_productPriceController.text),
          'stock': int.parse(_productStockController.text),
          'description': _productDescriptionController.text.trim(),
          'image_url': _productImageUrlController.text.trim(),
        },
      );

      if (response != null && response['success'] == true && mounted) {
        await _fetchProducts();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully')),
          );
          _clearProductForm();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to create product'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create product')),
        );
      }
    }
  }

  void _clearProductForm() {
    _productNameController.clear();
    _productPriceController.clear();
    _productStockController.clear();
    _productImageUrlController.clear();
    _productDescriptionController.clear();
    _selectedCategory = 'hockey';
  }

  void _showAddProductModal() {
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
                  colors: [Color(0xFF28a745), Color(0xFF20c997)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Product',
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
                key: _productFormKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildFormField(
                      controller: _productNameController,
                      label: 'Product Name',
                      icon: Icons.shopping_bag,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter product name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: _productPriceController,
                            label: 'Price per Day',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Please enter price';
                              if (double.tryParse(value!) == null)
                                return 'Please enter valid price';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: _productStockController,
                            label: 'Stock',
                            icon: Icons.inventory,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Please enter stock';
                              if (int.tryParse(value!) == null)
                                return 'Please enter valid stock';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(
                          Icons.category,
                          color: Color(0xFFffc107),
                        ),
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
                      items: const [
                        DropdownMenuItem(
                          value: 'hockey',
                          child: Text('Hockey'),
                        ),
                        DropdownMenuItem(
                          value: 'curling',
                          child: Text('Curling'),
                        ),
                        DropdownMenuItem(
                          value: 'ice_skating',
                          child: Text('Ice Skating'),
                        ),
                        DropdownMenuItem(
                          value: 'apparel',
                          child: Text('Apparel'),
                        ),
                        DropdownMenuItem(
                          value: 'accessories',
                          child: Text('Accessories'),
                        ),
                        DropdownMenuItem(
                          value: 'protective_gear',
                          child: Text('Protective Gear'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _productImageUrlController,
                      label: 'Image URL',
                      icon: Icons.image,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _productDescriptionController,
                      label: 'Description',
                      icon: Icons.description,
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
                            onPressed: _createProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28a745),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Create Product'),
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

                    if (_userType == 'seller') ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.store, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Seller Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              controller: _businessNameController,
                              label: 'Store Name',
                              icon: Icons.store,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter your store name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              controller: _businessAddressController,
                              label: 'Store Address',
                              icon: Icons.location_on,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final username = _userData?['username'] ?? 'User';
    final fullName = _getDisplayValue(_userData?['full_name']);
    final phoneNumber = _getDisplayValue(_userData?['phone_number']);
    final email = _getDisplayValue(_userData?['email']);
    final dateOfBirth = _userData?['date_of_birth'];
    final address = _getDisplayValue(_userData?['address']);

    final businessName = _userType == 'seller'
        ? _getDisplayValue(_userData?['business_name'])
        : '';
    final businessAddress = _userType == 'seller'
        ? _getDisplayValue(_userData?['business_address'])
        : '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Profile'),
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
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Profile Info Cards
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
                    // Greeting Section
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
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
                            size: 25,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userType == 'seller'
                                    ? 'Manage your seller profile and the products you sell'
                                    : 'Manage your profile and make your skating experience more personal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_userType == 'seller') ...[
                      // Seller Layout: Full Name + Store Name
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
                              icon: Icons.store,
                              label: 'STORE NAME',
                              value: businessName,
                              color: const Color(0xFF28a745),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Phone Number + Email
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.phone,
                              label: 'PHONE NUMBER',
                              value: phoneNumber,
                              color: const Color(0xFF17a2b8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.email,
                              label: 'EMAIL',
                              value: email,
                              color: const Color(0xFFffc107),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date of Birth + Address
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.calendar_today,
                              label: 'DATE OF BIRTH',
                              value: dateOfBirth != null
                                  ? _formatDate(dateOfBirth)
                                  : 'Not Provided',
                              color: const Color(0xFFdc3545),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.location_on,
                              label: 'ADDRESS',
                              value: address,
                              color: const Color(0xFF6f42c1),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Customer Layout: Full Name + Phone Number
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
                      // Email + Date of Birth
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
                      // Address (full width)
                      _buildInfoCard(
                        icon: Icons.location_on,
                        label: 'ADDRESS',
                        value: address,
                        color: const Color(0xFFdc3545),
                        fullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),

              // Products Section (only for sellers)
              if (_userType == 'seller') ...[
                const SizedBox(height: 24),
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
                      // Products Header
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF28a745), Color(0xFF20c997)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.inventory,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Products',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  'Manage the products you sell',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddProductModal,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28a745),
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Products List
                      if (_products.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You don\'t have any products yet. Click "Add Product" to create your first one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._products.map(
                          (product) => _buildProductCard(product),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product['image_url']?.isNotEmpty ?? false
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['category']
                          ?.toString()
                          .replaceAll('_', ' ')
                          .toUpperCase() ??
                      'Unknown Category',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product['price_per_day']?.toStringAsFixed(2) ?? '0.00'}/day • Stock: ${product['stock'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF28a745),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit product feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Color(0xFF17a2b8)),
                tooltip: 'Edit Product',
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete product feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Product',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'Not Provided';
    if (value is String && value.trim().isEmpty) return 'Not Provided';
    return value.toString();
  }
}
