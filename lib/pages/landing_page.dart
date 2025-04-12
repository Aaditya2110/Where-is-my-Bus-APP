import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'SignInSelectionPage.dart';
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showScrollIndicator = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showScrollIndicator) {
        setState(() {
          _showScrollIndicator = false;
        });
      } else if (_scrollController.offset <= 100 && !_showScrollIndicator) {
        setState(() {
          _showScrollIndicator = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background with Jaipur Theme
          JaipurBackgroundSilhouette(),
          
          // Animated Background Bubbles
          AnimatedBackgroundBubbles(controller: _animationController),
          
          // Main Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
              ),
            ),
            child: SafeArea(
              child: ListView(
                controller: _scrollController,
                children: [
                  const SizedBox(height: 20),

                  // Header with Logo and App Name
                  JaipurHeader(),
                  
                  const SizedBox(height: 60),

                  // Hero Content with Animations
                  JaipurHeroContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Phone Mockup with Map
                  PhoneMockup(controller: _animationController),
                  
                  const SizedBox(height: 60),
                  
                  // Features Section
                  FeaturesSection(),
                  
                  const SizedBox(height: 60),
                  
                  // CTA Section
                  CTASection(),
                  
                  const SizedBox(height: 60),
                  
                  // Footer
                  JaipurFooter(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Scroll Indicator
          if (_showScrollIndicator)
            ScrollIndicator(controller: _animationController),
        ],
      ),
    );
  }
}

// Jaipur-themed Background Silhouette
class JaipurBackgroundSilhouette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.07,
        child: CustomPaint(
          painter: HawaMahalPainter(),
        ),
      ),
    );
  }
}

// Hawa Mahal Silhouette Painter
class HawaMahalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.shade800
      ..style = PaintingStyle.fill;
      
    // Main structure path
    final mainPath = Path()
      ..moveTo(size.width * 0.6, size.height)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height)
      ..close();
    canvas.drawPath(mainPath, paint);
    
    // Left section path
    final leftPath = Path()
      ..moveTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height)
      ..close();
    canvas.drawPath(leftPath, paint);
    
    // Towers and details
    final tower1 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.15)
      ..lineTo(size.width * 0.45, size.height * 0.1)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..close();
    canvas.drawPath(tower1, paint);
    
    final tower2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.1)
      ..lineTo(size.width * 0.75, size.height * 0.05)
      ..lineTo(size.width * 0.8, size.height * 0.1)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..close();
    canvas.drawPath(tower2, paint);
    
    final tower3 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.2)
      ..lineTo(size.width * 0.55, size.height * 0.12)
      ..lineTo(size.width * 0.6, size.height * 0.07)
      ..lineTo(size.width * 0.65, size.height * 0.12)
      ..lineTo(size.width * 0.65, size.height * 0.2)
      ..close();
    canvas.drawPath(tower3, paint);
    
    // Windows and arches - simplified for Flutter
    _drawArchWindow(canvas, paint, size, 0.32, 0.35);
    _drawArchWindow(canvas, paint, size, 0.38, 0.35);
    _drawArchWindow(canvas, paint, size, 0.44, 0.35);
    _drawArchWindow(canvas, paint, size, 0.50, 0.35);
    _drawArchWindow(canvas, paint, size, 0.56, 0.35);
    
    _drawArchWindow(canvas, paint, size, 0.62, 0.35);
    _drawArchWindow(canvas, paint, size, 0.68, 0.35);
    _drawArchWindow(canvas, paint, size, 0.74, 0.35);
    _drawArchWindow(canvas, paint, size, 0.80, 0.35);
    _drawArchWindow(canvas, paint, size, 0.86, 0.35);
    
    _drawArchWindow(canvas, paint, size, 0.32, 0.42);
    _drawArchWindow(canvas, paint, size, 0.38, 0.42);
    _drawArchWindow(canvas, paint, size, 0.44, 0.42);
    _drawArchWindow(canvas, paint, size, 0.50, 0.42);
    _drawArchWindow(canvas, paint, size, 0.56, 0.42);
  }
  
  void _drawArchWindow(Canvas canvas, Paint paint, Size size, double x, double y) {
    final center = Offset(size.width * x, size.height * y);
    final rect = Rect.fromCenter(center: center, width: size.width * 0.03, height: size.height * 0.03);
    final path = Path()
      ..addArc(rect, 0, math.pi);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Background Bubbles - Enhanced
class AnimatedBackgroundBubbles extends StatelessWidget {
  final AnimationController controller;
  
  const AnimatedBackgroundBubbles({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final size = 20.0 + (index * 15.0);
            final offset = index * 0.1;
            final position = controller.value + offset;
            final x = math.sin(position * math.pi * 2) * 150;
            final y = math.cos(position * math.pi * 2) * 150;
            
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - size / 2,
              top: MediaQuery.of(context).size.height / 2 + y - size / 2,
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: index % 2 == 0 
                          ? [Colors.pink.withOpacity(0.5), Colors.amber.withOpacity(0.5)]
                          : [Colors.amber.withOpacity(0.5), Colors.pink.withOpacity(0.5)],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Jaipur-themed Header
class JaipurHeader extends StatefulWidget {
  const JaipurHeader({super.key});

  @override
  State<JaipurHeader> createState() => _JaipurHeaderState();
}

class _JaipurHeaderState extends State<JaipurHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.pink.shade100,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              )
            ],
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and title
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_bus, color: Colors.pink),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.7, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.pink.shade600, Colors.amber.shade600],
                        ).createShader(bounds),
                        child: const Text(
                          "JaipurBus",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 246, 145, 145),
                          ),
                        ),
                      ),
                      Text(
                        "Explore the Pink City",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Navigation menu
              Row(
                children: [
                 
                
                 
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SignInSelectionPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 8,
                      shadowColor: Colors.pink.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignInSelectionPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Sign In →",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
),
                  ),
                ],
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Jaipur Hero Content
class JaipurHeroContent extends StatefulWidget {
  const JaipurHeroContent({super.key});

  @override
  State<JaipurHeroContent> createState() => _JaipurHeroContentState();
}

class _JaipurHeroContentState extends State<JaipurHeroContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.pink.shade600, Colors.amber.shade600],
                ).createShader(bounds),
                child: const Text(
                  "Where is My Bus",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const Text(
                "in Jaipur",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 63, 61, 61),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Track your bus in real-time across the Pink City and never miss a ride",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 63, 61, 61),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  PulsingButton(
                    // text: "Get Started",
                    label: "Get Started",
                    icon: Icons.arrow_forward,
                    color: Color.fromARGB(255, 255, 224, 235),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SignInSelectionPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: BorderSide(color: Colors.pink.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Find Routes",
                      style: TextStyle(
                        color: Colors.pink.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Phone Mockup with Animated Map
class PhoneMockup extends StatelessWidget {
  final AnimationController controller;
  
  const PhoneMockup({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background decorative elements
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade400.withOpacity(0.3),
                            Colors.amber.shade300.withOpacity(0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade200.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400.withOpacity(0.3),
                            Colors.pink.shade300.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Phone mockup
                  Container(
                    width: 300,
                    height: 600,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.black,
                        width: 14,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Stack(
                        children: [
                          // Phone screen background
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFDF2E9), Color(0xFFFCE4D6)],
                              ),
                            ),
                          ),
                          
                          // Notch
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 120,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          
                          // Map grid lines
                          Positioned.fill(
                            child: CustomPaint(
                              painter: MapGridPainter(),
                            ),
                          ),
                          
                          // Map roads
                          Positioned.fill(
                            child: CustomPaint(
                              painter: MapRoadsPainter(),
                            ),
                          ),
                          
                          // Map content - animated route
                          AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: AnimatedRoutePainter(progress: controller.value),
                                child: const SizedBox(
                                  width: 300,
                                  height: 600,
                                ),
                              );
                            },
                          ),
                          
                          // Landmark icons
                          const HawaMahalIcon(),
                          const JalMahalIcon(),
                          
                          // App UI elements
                          const MapUIElements(),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Map Grid Painter
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.shade200.withOpacity(0.3)
      ..strokeWidth = 0.5;
      
    // Horizontal grid lines
    for (int i = 0; i <= 12; i++) {
      final y = size.height * (i / 12);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Vertical grid lines
    for (int i = 0; i <= 8; i++) {
      final x = size.width * (i / 8);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Map Roads Painter
class MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade100.withOpacity(0.8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
      
    // Main horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    
    // Vertical roads
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.85, 0),
      Offset(size.width * 0.85, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Route Painter
class AnimatedRoutePainter extends CustomPainter {
  final double progress;
  
  AnimatedRoutePainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Route path
    final path = Path()
      ..moveTo(0, size.height * 0.25)
      ..cubicTo(
        size.width * 0.3, size.height * 0.22,
        size.width * 0.6, size.height * 0.24,
        size.width, size.height * 0.20,
      );
    
    // Draw route
    final routePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final dashPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    // Draw route with dash effect
    final pathMetrics = path.computeMetrics().first;
    final extractPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );
    
    canvas.drawPath(extractPath, dashPaint);
    canvas.drawPath(extractPath, routePaint);
    
    // Draw animated bus
    if (progress > 0.1) {
      final busPosition = pathMetrics.length * math.min(0.8, progress);
      final tangent = pathMetrics.getTangentForOffset(busPosition);
      
      if (tangent != null) {
        final busPosition = tangent.position;
        final busAngle = tangent.angle;
        
        canvas.save();
        canvas.translate(busPosition.dx, busPosition.dy);
        canvas.rotate(busAngle);
        
        // Bus with pulsating effect
        final pulseValue = 0.8 + 0.2 * math.sin(progress * math.pi * 10);
        final busPaint = Paint()
          ..color = Colors.pink.shade600
          ..style = PaintingStyle.fill;
          
        final pulsePaint = Paint()
          ..color = Colors.pink.shade400.withOpacity(0.5 * pulseValue)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset.zero, 16 * pulseValue, pulsePaint);
        canvas.drawCircle(Offset.zero, 12, busPaint);
        
     // Completing AnimatedRoutePainter class
        // Bus icon
        final iconPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
          
        // Draw bus icon (simplified)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
            const Radius.circular(1),
          ),
          iconPaint,
        );
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Hawa Mahal Icon (Landmark)
class HawaMahalIcon extends StatelessWidget {
  const HawaMahalIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 180,
      left: 100,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.pink.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.castle,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Jal Mahal Icon (Landmark)
class JalMahalIcon extends StatelessWidget {
  const JalMahalIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      right: 60,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.shade200.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.water,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Map UI Elements
class MapUIElements extends StatelessWidget {
  const MapUIElements({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Search bar
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.pink.shade600),
                const SizedBox(width: 10),
                Text(
                  "Search Jaipur landmarks",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Zoom controls
        Positioned(
          top: 130,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.add, color: Colors.pink.shade600),
                const SizedBox(height: 15),
                Container(
                  height: 1,
                  width: 20,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 15),
                Icon(Icons.remove, color: Colors.pink.shade600),
              ],
            ),
          ),
        ),
        
        // Bottom location indicator
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Your location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // North indicator
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "N",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        // Bus popup
        Positioned(
          top: 250,
          left: 50,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.castle, color: Colors.pink.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Hawa Mahal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_bus, color: Colors.pink.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Departing soon",
                        style: TextStyle(
                          color: Colors.pink.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Scroll Indicator
class ScrollIndicator extends StatelessWidget {
  final AnimationController controller;
  
  const ScrollIndicator({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final offset = math.sin(controller.value * math.pi * 2) * 5;
            
            return Transform.translate(
              offset: Offset(0, offset),
              child: Column(
                children: [
                  Text(
                    "Scroll to explore",
                    style: TextStyle(
                      color: Colors.pink.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.pink.shade600,
                    size: 28,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Features Section
class FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Discover how JaipurBus makes your daily commute easier, more reliable, and stress-free",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: FeatureCard(
                  icon: Icons.location_on,
                  iconColor: Colors.blue,
                  title: "Real-time Tracking",
                  description: "Track buses on the map in real-time with accurate GPS positioning",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FeatureCard(
                  icon: Icons.access_time,
                  iconColor: Colors.orange,
                  title: "ETA Updates",
                  description: "Get precise arrival time estimates updated in real-time",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FeatureCard(
                  icon: Icons.notifications,
                  iconColor: Colors.green,
                  title: "Notifications",
                  description: "Receive alerts about delays, route changes, and arrivals",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FeatureCard(
                  icon: Icons.smartphone,
                  iconColor: Colors.purple,
                  title: "Mobile Tickets",
                  description: "Purchase and store tickets directly on your phone",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Feature Card
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  
  const FeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// CTA Section
class CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Ready to never miss your bus again?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Join thousands of commuters who have made their daily travel more efficient and stress-free with JaipurBus",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade50,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PulsingButton(
            label: "Get Started - It's Free",
            icon: Icons.arrow_forward,
            color: Colors.white,
            backgroundColor: Colors.pink,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SignInSelectionPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Jaipur Footer
class JaipurFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.pink.shade100,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_bus, color: Colors.pink),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.pink.shade600, Colors.amber.shade600],
                ).createShader(bounds),
                child: const Text(
                  "JaipurBus",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FooterLink(title: "About Us", onTap: () {}),
              FooterLink(title: "Contact", onTap: () {}),
              FooterLink(title: "Privacy Policy", onTap: () {}),
              FooterLink(title: "Terms", onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialIcon(icon: Icons.facebook, onTap: () {}),
              SocialIcon(icon: Icons.telegram, onTap: () {}),
              SocialIcon(icon: Icons.camera_alt, onTap: () {}),
              SocialIcon(icon: Icons.psychology, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "© ${DateTime.now().year} JaipurBus. All rights reserved.",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Footer Link
class FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const FooterLink({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.pink.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Social Icon
class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const SocialIcon({
    super.key,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.pink.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// Pulsing Button
class PulsingButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  
  const PulsingButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor ?? widget.color,
              foregroundColor: widget.backgroundColor != null ? Colors.white : Colors.pink.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 10,
              shadowColor: (widget.backgroundColor ?? widget.color).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(widget.icon),
              ],
            ),
          ),
        );
      },
    );
  }
}