import 'LoginPage.dart' as login_page;
// import 'DriverLoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;
 // Add this import at the top

class SignInSelectionPage extends StatefulWidget {
  const SignInSelectionPage({super.key});

  @override
  State<SignInSelectionPage> createState() => _SignInSelectionPageState();
}

class _SignInSelectionPageState extends State<SignInSelectionPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _hoveredRole;
  String? _selectedRole;
  bool _showFeatures = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Show features with a slight delay for a staggered animation effect
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _showFeatures = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void _handleRoleSelect(String role, BuildContext context) {
  //   setState(() => _selectedRole = role);
    
  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     Navigator.pushNamed(
  //       context, 
  //       role == "user" ? "/signup" : "/driver-login"
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(icon: Icons.map, text: "Real-time Tracking"),
      _Feature(icon: Icons.access_time, text: "ETA Updates"),
      _Feature(icon: Icons.notifications, text: "Notifications"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8), // Warm beige background matching photo
      body: Stack(
        children: [
          // Subtle background gradients
          Positioned.fill(
            child: _AnimatedBackground(controller: _controller),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 16),
                    child: _AnimatedButton(
                     onPressed: () => Navigator.pushNamed(context, '/landing'),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                ),
                
                // Language selector (from photo)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "GB",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "English",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          
                          // Bus icon animation
                          _BusIconAnimation(),
                          
                          const SizedBox(height: 16),
                          
                          // Welcome text
                          const Text(
                            "Welcome",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2138),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          const Text(
                            "Choose how you want to sign in",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Role selection cards - matching photo layout
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _RoleCard(
                                    role: "user",
                                    title: "Passenger",
                                    description: "Track buses and book tickets",
                                    icon: Icons.person,
                                    color: Colors.blue,
                                    isSelected: _selectedRole == "user",
                                    isHovered: _hoveredRole == "user",
                                    onHover: (hovering) => setState(() => _hoveredRole = hovering ? "user" : null),
                                    onSelect: () {
                                      setState(() => _selectedRole = "user");
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const login_page.LoginPage(), // Passenger goes to LoginPage
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _RoleCard(
                                    role: "driver",
                                    title: "Driver",
                                    description: "Manage routes and shifts",
                                    icon: Icons.directions_bus,
                                    color: Colors.orange,
                                    isSelected: _selectedRole == "driver",
                                    isHovered: _hoveredRole == "driver",
                                    onHover: (hovering) => setState(() => _hoveredRole = hovering ? "driver" : null),
                                    onSelect: () {
           
                                    },
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Features section - matching photo layout
                          AnimatedOpacity(
                            opacity: _showFeatures ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Key Features",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      for (int i = 0; i < features.length; i++)
                                        _FeatureItem(
                                          feature: features[i],
                                          index: i,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Sign up text
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Sign up",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  // recognizer: GestureRecognizer()
                                
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String text;

  _Feature({required this.icon, required this.text});
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  
  const _AnimatedBackground({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(animationValue: controller.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  
  _BackgroundPainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Top left warm gradient circle
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE0D5C1).withOpacity(0.4),
          const Color(0xFFE0D5C1).withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.2),
          radius: size.width * 0.6 + (math.sin(animationValue * math.pi) * 20),
        ),
      );
      
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 0.6 + (math.sin(animationValue * math.pi) * 20),
      paint1,
    );
    
    // Bottom right warm gradient circle
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDBC8A9).withOpacity(0.3),
          const Color(0xFFDBC8A9).withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.8),
          radius: size.width * 0.5 + (math.cos(animationValue * math.pi) * 20),
        ),
      );
      
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      size.width * 0.5 + (math.cos(animationValue * math.pi) * 20),
      paint2,
    );
    
    // Additional subtle floating circles
    for (int i = 0; i < 3; i++) {
      final circleSize = size.width * (0.1 + (i * 0.05));
      final xOffset = math.sin((animationValue + (i * 0.3)) * math.pi * 2) * 30;
      final yOffset = math.cos((animationValue + (i * 0.3)) * math.pi * 2) * 30;
      
      final paint = Paint()
        ..color = Color(0xFFDBC8A9).withOpacity(0.1);
      
      canvas.drawCircle(
        Offset(
          size.width * (0.3 + (i * 0.2)) + xOffset,
          size.height * (0.3 + (i * 0.2)) + yOffset,
        ),
        circleSize,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  
  const _AnimatedButton({
    required this.child,
    required this.onPressed,
  });
  
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _hovering = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovering ? Colors.white : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.1 : 0.05),
                blurRadius: _hovering ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _BusIconAnimation extends StatefulWidget {
  const _BusIconAnimation();

  @override
  State<_BusIconAnimation> createState() => _BusIconAnimationState();
}

class _BusIconAnimationState extends State<_BusIconAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EC),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.8, // Slight scale adjustment for the emoji
                  child: const Text(
                    "🚌",
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isHovered;
  final Function(bool) onHover;
  final VoidCallback onSelect;
  
  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isHovered,
    required this.onHover,
    required this.onSelect,
  });
  
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          transform: Matrix4.identity()
            ..scale(widget.isHovered ? 1.02 : 1.0)
            ..translate(
              0.0, 
              widget.isSelected ? -8.0 : 0.0,
            ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(widget.isHovered ? 0.3 : 0.2),
                blurRadius: widget.isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  transform: Matrix4.identity()
                    ..translate(
                      widget.isHovered ? 0.0 : -10.0,
                      0.0,
                    ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: widget.isHovered ? 1.0 : 0.0,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
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

class _FeatureItem extends StatelessWidget {
  final _Feature feature;
  final int index;
  
  const _FeatureItem({
    required this.feature,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature.icon,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  feature.text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

