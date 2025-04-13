import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'SideNavBar.dart'; // Ensure this file exists and is implemented correctly

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool isSidebarOpen = false;
  Map<String, String> userDetails = {
    'name': 'Aaditya',
    'email': 'xyz123@gmail.com',
    'contact': '+91 00000 00000',
  };
  int rating = 3;
  String comment = '';
  bool isSubmitting = false;
  bool isSubmitted = false;
  String selectedCategory = 'bus_service';
  final Random random = Random();

  final emojis = [
    {'id': 1, 'icon': '😡', 'label': 'Terrible'},
    {'id': 2, 'icon': '😞', 'label': 'Poor'},
    {'id': 3, 'icon': '😐', 'label': 'Okay'},
    {'id': 4, 'icon': '😊', 'label': 'Good'},
    {'id': 5, 'icon': '😎', 'label': 'Excellent'},
  ];

  final categories = [
    {
      'id': 'bus_service',
      'label': 'Bus Service',
      'icon': Icons.local_shipping_outlined
    },
    {
      'id': 'app_experience',
      'label': 'App Experience',
      'icon': Icons.person_outline
    },
    {
      'id': 'driver_behavior',
      'label': 'Driver Behavior',
      'icon': Icons.person_outline
    },
    {'id': 'route_timing', 'label': 'Route Timing', 'icon': Icons.arrow_back},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      if (userData != null) {
        final data = Map<String, dynamic>.from(jsonDecode(userData));
        setState(() {
          userDetails = {
            'name': data['fullName']?.toString() ?? userDetails['name']!,
            'email': data['email']?.toString() ?? userDetails['email']!,
            'contact': data['phoneNumber']?.toString() ?? userDetails['contact']!,
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  void handleSubmit() {
    setState(() {
      isSubmitting = true;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          isSubmitted = true;
        });

        Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            // Check if '/routes' exists in the navigator before pushing
            Navigator.of(context)
                .pushReplacementNamed('/routes')
                .catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Route not found')),
              );
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
              ),
            ),
          ),
          ..._buildAnimatedBackgroundElements(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildFeedbackForm(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSidebarOpen)
            SideNavBar(
              isOpen: isSidebarOpen,
              setIsOpen: (value) => setState(() => isSidebarOpen = value), onLogout: () {  },
            ),
          if (isSubmitted)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Feedback Submitted!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedBackgroundElements() {
    return List.generate(3, (i) {
      final top = random.nextDouble() * 100;
      final left = random.nextDouble() * 100;
      final size = random.nextDouble() * 200 + 50;

      return TweenAnimationBuilder(
        key: ValueKey(i), // Add unique key for each animation
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(seconds: random.nextInt(5) + 5),
        builder: (context, double value, child) {
          return Positioned(
            top: top + (random.nextDouble() * 20 - 10) * value,
            left: left + (random.nextDouble() * 20 - 10) * value,
            child: Container(
              width: size * (0.9 + random.nextDouble() * 0.2 * value),
              height: size * (0.9 + random.nextDouble() * 0.2 * value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.03),
                    Colors.amber.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D2).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 24, color: Colors.black87),
            onPressed: () => setState(() => isSidebarOpen = true),
            tooltip: 'Open menu', // Accessibility improvement
          ),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 24, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Go back', // Accessibility improvement
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Share Your Experience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildUserInfoField(
                Icons.person_outline,
                'Your Name',
                userDetails['name'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              _buildUserInfoField(
                Icons.email_outlined,
                'Email',
                userDetails['email'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              _buildUserInfoField(
                Icons.phone_outlined,
                'Contact Number',
                userDetails['contact'] ?? 'Unknown',
              ),
              const SizedBox(height: 24),
              const Text(
                'Feedback Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category['id'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['id'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              size: 20,
                              color: isSelected ? Colors.blue : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.blue : Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
),
              const SizedBox(height: 24),
              const Text(
                'Rate Your Experience',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: emojis.map((emoji) {
                    final isSelected = rating == emoji['id'];
                    return GestureDetector(
                      onTap: () => setState(() => rating = emoji['id'] as int),
                      child: Column(
                        children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: isSelected ? Matrix4.diagonal3Values(1.25, 1.25, 1.0) : Matrix4.identity(),
                                  child: Text(
                                    emoji['icon'] as String,
                                    style: TextStyle(
                                      fontSize: 28,
                                      // opacity: isSelected ? 1.0 : 0.6,
                                    ),
                                    semanticsLabel: emoji['label'] as String, // Accessibility
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            emoji['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.blue : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Slider(
                      value: rating.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) =>
                          setState(() => rating = value.toInt()),
                      label: emojis
                          .firstWhere((e) => e['id'] == rating)['label']
                          .toString(), // Accessibility
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: emojis
                            .map((e) => Text(
                                  e['label'] as String,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Additional Comments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: (value) => comment = value,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Write your comments here...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting || isSubmitted ? null : handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSubmitted ? Colors.green : Colors.blue, // Updated
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSubmitting) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Submitting...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ] else if (isSubmitted) ...[
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Submitted!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.send, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Submit Feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Thank you for helping us improve our services!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildUserInfoField(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}