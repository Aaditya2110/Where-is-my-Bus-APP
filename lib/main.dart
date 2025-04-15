import 'package:flutter/material.dart';
import 'package:wimb/pages/Notification.dart';
import 'pages/landing_page.dart';
import 'pages/LoginPage.dart';
import 'pages/SignInSelectionPage.dart';
import 'pages/LocationPermissionPage.dart';
import 'pages/RoutesPage.dart';
import 'pages/Profile.dart';
import 'pages/FeedbackPage.dart';
import 'pages/RouteTrack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(226, 207, 132, 1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial page

      // ✅ Integrated routes
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignInSelectionPage(),
        '/location-permission': (context) => const LocationPermissionScreen(),
        '/landing': (context) => const LandingPage(),
        '/route': (context) => const RoutesPage(),
        '/feed': (context) => const FeedbackPage(),
        '/profile': (context) => const Profile(),
        '/notifications': (context) => NotificationsScreen(), // Replace with your actual notification page
        '/track/:id': (context) => RouteDetailsPage(
          routeId: ModalRoute.of(context)?.settings.arguments as String,
        ),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    // Create animation (fade in and scale)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Start animation
    _controller.forward();
    
    // Navigate to LandingPage after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color.fromARGB(255, 253, 210, 146), 

      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset('../assets/Logo2.png', width: 150, height: 150) // Replace with your app logo
          ),
        ),
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Page'),
      ),
      body: Center(
        child: const Text(
          'Welcome to the Start Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
