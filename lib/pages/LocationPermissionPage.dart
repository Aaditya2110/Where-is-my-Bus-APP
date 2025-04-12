import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with TickerProviderStateMixin {
  String permissionState = "idle"; // idle, loading, success, error
  String errorMessage = "";
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> handleEnableLocation() async {
    setState(() {
      permissionState = "loading";
      _rotateController.repeat();
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          permissionState = "error";
          errorMessage = "Location access permanently denied. Please enable location services in your device settings.";
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          permissionState = "error";
          errorMessage = "Location access was denied. Please enable location services to continue.";
        });
        return;
      }

      // Get position to verify it works
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        permissionState = "success";
      });

      // Navigate after delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pushReplacementNamed('/route');
      });
    } catch (e) {
      setState(() {
        permissionState = "error";
        if (e is LocationServiceDisabledException) {
          errorMessage = "Location services are disabled. Please enable location in your device settings.";
        }else {
          errorMessage = "An error occurred while trying to access your location: $e";
        }
      });
    } finally {
      if (permissionState != "loading") {
        _rotateController.stop();
      }
    }
  }

  void resetPermissionState() {
    setState(() {
      permissionState = "idle";
      errorMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'icon': Icons.public,
        'iconColor': Colors.blue,
        'title': 'Real-Time Tracking',
        'description': 'See buses moving on the map in real-time',
      },
      {
        'icon': Icons.shield,
        'iconColor': Colors.green,
        'title': 'Privacy Protected',
        'description': 'Your location data is only used while using the app',
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
          ),
        ),
        child: Stack(
          children: [
            // Background animated elements
            ..._buildBackgroundElements(),
            
            // Main gradient overlays
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.1,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.shrink(),
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.1,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.shrink(),
              ),
            ),
            
            // Back button
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -20, end: 0),
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildMainCard(),
                      const SizedBox(height: 20),
                      _buildBenefitsCard(benefits),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                ),
              ),
            ),
            
            // Bottom route line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 1,
                child: Stack(
                  children: [
                    Container(color: Colors.grey.withOpacity(0.3)),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Positioned(
                          left: _pulseController.value * MediaQuery.of(context).size.width * 1.2 - MediaQuery.of(context).size.width * 0.2,
                          child: Container(
                            width: 80,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  List<Widget> _buildBackgroundElements() {
    List<Widget> elements = [];
    for (int i = 0; i < 4; i++) {
      double top = 100.0 * i;
      double left = 50.0 * i + 40;
      
      elements.add(
        Positioned(
          top: top,
          left: left,
          child: Container(
            width: 100 + (i * 30),
            height: 100 + (i * 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.amber.withOpacity(0.1),
                ],
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: const Offset(1, 1),
            end: Offset(1 + (i * 0.05), 1 + (i * 0.05)),
            duration: Duration(seconds: 3 + i),
            curve: Curves.easeInOut,
          ).moveY(
            begin: 0,
            end: 15,
            duration: Duration(seconds: 4 + i),
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
    return elements;
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Blob background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                // Animated rings
                ...List.generate(2, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final value = index == 0
                          ? _pulseController.value
                          : ((_pulseController.value + 0.5) % 1.0);
                          
                      return Opacity(
                        opacity: 1.0 - value,
                        child: Container(
                          width: 80 + (value * 40),
                          height: 80 + (value * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == 0
                                  ? Colors.blue.shade400
                                  : Colors.blue.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 800),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Enable Location',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 20, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            'We need your location to show nearby buses and provide accurate arrival times',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 20, end: 0),
          
          const SizedBox(height: 24),
          
          _buildActionWidget(),
        ],
      ),
    );
  }

  Widget _buildActionWidget() {
    switch (permissionState) {
      case "idle":
        return ElevatedButton(
          onPressed: handleEnableLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text(
            'Enable Location Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 20, end: 0);
      
      case "loading":
        return Column(
          children: [
            AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.refresh,
                    size: 32,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ).animate().fadeIn();
      
      case "success":
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 32,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Location Access Granted',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Redirecting to map...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ).animate()
          .fadeIn()
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            curve: Curves.elasticOut,
          );
      
      case "error":
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: resetPermissionState,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ).animate().fadeIn();
      
      default:
        return const SizedBox();
    }
  }

  Widget _buildBenefitsCard(List<Map<String, dynamic>> benefits) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Why We Need Your Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF505050),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.asMap().entries.map((entry) {
            final index = entry.key;
            final benefit = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      benefit['icon'] as IconData,
                      size: 20,
                      color: benefit['iconColor'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF303030),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          benefit['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (500 + (index * 100)).ms).slideY(begin: 10, end: 0);
          }).toList(),
        ],
      ),
    );
  }
}