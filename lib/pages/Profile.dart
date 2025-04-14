import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SideNavBar.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  bool isSidebarOpen = false;
  bool isEditing = false;
  bool showPassword = false;
  bool isLoading = false;
  String successMessage = "";
  Color avatarColor = const Color(0xFF3B82F6); // Default blue color
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Form data
  late Map<String, dynamic> formData;
  late Map<String, dynamic> originalData;

  // Animation controllers
  late AnimationController _backgroundAnimController;
  late List<Animation<Offset>> _backgroundAnimations;
  late List<Animation<double>> _backgroundScaleAnimations;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Create multiple animations for background elements
    _backgroundAnimations = List.generate(
      4,
      (i) => Tween<Offset>(
        begin: Offset.zero,
        end: Offset(
          Random().nextDouble() * 0.3 - 0.15,
          Random().nextDouble() * 0.3 - 0.15,
        ),
      ).animate(
        CurvedAnimation(
          parent: _backgroundAnimController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _backgroundScaleAnimations = List.generate(
      4,
      (i) => Tween<double>(
        begin: 1.0,
        end: Random().nextDouble() * 0.3 + 0.9,
      ).animate(
        CurvedAnimation(
          parent: _backgroundAnimController,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');

    if (userData != null) {
      final parsedData = json.decode(userData);
      setState(() {
        formData = {
          'fullName': parsedData['fullName'] ?? 'User Name',
          'email': parsedData['email'] ?? 'user@example.com',
          'phoneNumber': parsedData['phoneNumber'] ?? '',
          'password': '********',
          'profileImage': parsedData['profileImage'],
        };
        originalData = Map.from(formData);
        _generateAvatarColor(formData['fullName']);
      });
    } else {
      setState(() {
        formData = {
          'fullName': 'User Name',
          'email': 'user@example.com',
          'phoneNumber': '',
          'password': '********',
          'profileImage': null,
        };
        originalData = Map.from(formData);
      });
    }
  }

  void _generateAvatarColor(String name) {
    if (name.isNotEmpty) {
      int hash = name.codeUnits.fold(0, (acc, charCode) {
        return charCode + ((acc << 5) - acc);
      });
      int hue = hash.abs() % 360;
      setState(() {
        avatarColor = HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.5).toColor();
      });
    }
  }

  void _handleChange(String field, String value) {
    setState(() {
      formData[field] = value;
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');

      if (userData == null) {
        _showMessage('Please login again to update your profile');
        setState(() {
          isLoading = false;
        });
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final parsedData = json.decode(userData);
      final token = parsedData['token'];

      if (token == null) {
        _showMessage('Please login again to update your profile');
        setState(() {
          isLoading = false;
        });
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Prepare request body
      final requestBody = {
        'fullName': formData['fullName'],
        'email': formData['email'],
        'phoneNumber': formData['phoneNumber'],
      };

      // Only include password if it has been changed
      if (formData['password'] != '********') {
        requestBody['password'] = formData['password'];
      }

      // Send update request
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Update localStorage with new data
        await prefs.setString('userData', json.encode({
          ...parsedData,
          'fullName': responseData['fullName'],
          'email': responseData['email'],
          'phoneNumber': responseData['phoneNumber'],
          'token': responseData['token'],
        }));

        setState(() {
          originalData = Map.from(formData);
          isLoading = false;
          isEditing = false;
        });
        
        _showMessage('Profile updated successfully!');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Something went wrong!');
      }
    } catch (error) {
      print('Update profile error: $error');
      setState(() {
        isLoading = false;
      });
      _showMessage('Error: ${error.toString()}');
    }
  }

  void _handleCancel() {
    setState(() {
      formData = Map.from(originalData);
      isEditing = false;
    });
  }

  void _showMessage(String message) {
    setState(() {
      successMessage = message;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          successMessage = "";
        });
      }
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "U";
    
    final nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _backgroundAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a UserProfile object for SideNavBar
    UserProfile userProfile = UserProfile(
      name: formData['fullName'],
      email: formData['email'],
      avatar: formData['profileImage'],
    );

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
              ),
            ),
          ),

          // Animated background elements
          ..._buildAnimatedBackgroundElements(),

          // Main content
          Column(
            children: [
              // App Bar with Glassmorphism
              _buildAppBar(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          // Profile header with avatar
                          _buildProfileHeader(),

                          const SizedBox(height: 16),

                          // Profile form
                          _buildProfileForm(),

                          const SizedBox(height: 16),

                          // Account actions
                          _buildAccountActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Success message
          if (successMessage.isNotEmpty) _buildSuccessMessage(),

          // Side navigation when open
          if (isSidebarOpen)
            SideNavBar(
              isOpen: isSidebarOpen,
              setIsOpen: (value) {
                setState(() {
                  isSidebarOpen = value;
                });
              },
              currentUser: userProfile,
              onLogout: _handleLogout,
              activeRoute: "profile",
            ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedBackgroundElements() {
    return List.generate(
      4,
      (i) => AnimatedBuilder(
        animation: _backgroundAnimController,
        builder: (context, child) {
          return Positioned(
            top: Random().nextDouble() * MediaQuery.of(context).size.height,
            left: Random().nextDouble() * MediaQuery.of(context).size.width,
            child: Transform.translate(
              offset: _backgroundAnimations[i].value,
              child: Transform.scale(
                scale: _backgroundScaleAnimations[i].value,
                child: Container(
                  width: Random().nextDouble() * 200 + 50,
                  height: Random().nextDouble() * 200 + 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(59, 130, 246, 0.05),
                        Color.fromRGBO(245, 158, 11, 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D2).withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, size: 24),
                onPressed: () {
                  setState(() {
                    isSidebarOpen = true;
                  });
                },
              ),
              Row(
                children: [
                  const Icon(Icons.account_circle, size: 24),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF4B5563)],
                    ).createShader(bounds),
                    child: const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Avatar with camera button
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Avatar or initials
                  formData['profileImage'] != null
                      ? Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(formData['profileImage']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(formData['fullName']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                  // Camera button
                  Material(
                    color: Colors.blue,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement image picking
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User info
              Text(
                formData['fullName'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formData['email'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),

          // Edit button
          if (!isEditing)
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              const Icon(
                Icons.shield,
                size: 20,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form fields
          _buildTextField(
            label: 'Full Name',
            icon: Icons.person_outline,
            value: formData['fullName'],
            onChanged: (value) => _handleChange('fullName', value),
            enabled: isEditing,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Email Address',
            icon: Icons.email_outlined,
            value: formData['email'],
            onChanged: (value) => _handleChange('email', value),
            enabled: isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            value: formData['phoneNumber'],
            onChanged: (value) => _handleChange('phoneNumber', value),
            enabled: isEditing,
            placeholder: !isEditing && formData['phoneNumber'].isEmpty ? 'Not provided' : '',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          _buildPasswordField(
            label: 'Password',
            icon: Icons.lock_outline,
            value: formData['password'],
            onChanged: (value) => _handleChange('password', value),
            enabled: isEditing,
          ),

          const SizedBox(height: 24),

          // Action buttons
          if (isEditing)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4B5563),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
    bool enabled = true,
    String placeholder = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white.withOpacity(0.8) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.blue.withOpacity(0.3) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white.withOpacity(0.8) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.blue.withOpacity(0.3) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            enabled: enabled,
            obscureText: !showPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              suffixIcon: enabled
                  ? IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1FAE5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  successMessage,
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}