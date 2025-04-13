import 'package:flutter/material.dart';
import 'dart:math';

class UserProfile {
  final String name;
  final String email;
  final String? avatar;

  UserProfile({
    required this.name,
    required this.email,
    this.avatar,
  });
}

class SideNavBar extends StatefulWidget {
  final bool isOpen;
  final Function(bool) setIsOpen;
  final UserProfile? currentUser;
  final VoidCallback onLogout;
  final String activeRoute;

  const SideNavBar({
    Key? key,
    required this.isOpen,
    required this.setIsOpen,
    this.currentUser,
    required this.onLogout,
    this.activeRoute = "home",
  }) : super(key: key);

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Color avatarColor = const Color(0xFF3B82F6);
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialize with default values
    userProfile = widget.currentUser ?? 
      UserProfile(
        name: "User", 
        email: "user@example.com", 
        avatar: null
      );

    _updateAvatarColor();

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(SideNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    if (widget.currentUser != oldWidget.currentUser) {
      setState(() {
        userProfile = widget.currentUser ?? 
          UserProfile(
            name: "User", 
            email: "user@example.com", 
            avatar: null
          );
        _updateAvatarColor();
      });
    }
  }

  void _updateAvatarColor() {
    if (userProfile.name != "User") {
      // Generate avatar color based on name (similar to React version)
      int hash = 0;
      for (int i = 0; i < userProfile.name.length; i++) {
        hash = userProfile.name.codeUnitAt(i) + ((hash << 5) - hash);
      }
      final int hue = (hash % 360).abs();
      setState(() {
        avatarColor = HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.5).toColor();
      });
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return "U";
    
    final parts = name.split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop overlay
        if (widget.isOpen)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => widget.setIsOpen(false),
                child: Container(
                  color: Colors.black.withOpacity(0.4 * _fadeAnimation.value),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              );
            },
          ),

        // Sidebar
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * _slideAnimation.value, 0),
              child: child,
            );
          },
          child: Container(
            width: 280,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with user profile
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // User avatar or initials
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: userProfile.avatar != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.network(
                                      userProfile.avatar!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      getInitials(userProfile.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // User name and email
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  userProfile.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4B5563),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          InkWell(
                            onTap: () => widget.setIsOpen(false),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // App logo
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Where's My Bus?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFC4B393), height: 1),

                // Navigation links
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Menu Section
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            "MAIN MENU",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home,
                          label: "Home",
                          id: "home",
                          onTap: () => _navigateTo('/route'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.person_outline,
                          selectedIcon: Icons.person,
                          label: "Profile",
                          id: "profile",
                          onTap: () => _navigateTo('/profile'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.description_outlined,
                          selectedIcon: Icons.description,
                          label: "My Tickets",
                          id: "tickets",
                          onTap: () => _navigateTo('/tickets'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.notifications_outlined,
                          selectedIcon: Icons.notifications,
                          label: "Notifications",
                          id: "notifications",
                          badge: 3,
                          onTap: () => _navigateTo('/notifications'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.bookmark_outline,
                          selectedIcon: Icons.bookmark,
                          label: "Saved Routes",
                          id: "saved",
                          onTap: () => _navigateTo('/saved-routes'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.chat_bubble_outline,
                          selectedIcon: Icons.chat_bubble,
                          label: "Feedback",
                          id: "feedback",
                          onTap: () => _navigateTo('/feed'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.contact_mail_outlined,
                          selectedIcon: Icons.contact_mail,
                          label: "Contact Us",
                          id: "contact",
                          onTap: () => _navigateTo('/contact'),
                        ),

                        const SizedBox(height: 24),
                        
                        // Quick Access Section
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
                          child: Text(
                            "QUICK ACCESS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickAccessButton(
                                icon: Icons.map,
                                label: "Live Map",
                                color: Colors.blue,
                                onTap: () => _navigateTo('/map-view'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickAccessButton(
                                icon: Icons.airport_shuttle,
                                label: "Track Bus",
                                color: Colors.amber,
                                onTap: () => _navigateTo('/track'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        
                        // Support Section
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
                          child: Text(
                            "SUPPORT",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.help_outline,
                          selectedIcon: Icons.help,
                          label: "Help & Support",
                          id: "help",
                          onTap: () => _navigateTo('/help'),
                        ),
                        
                        _buildNavItem(
                          icon: Icons.settings_outlined,
                          selectedIcon: Icons.settings,
                          label: "Settings",
                          id: "settings",
                          onTap: () => _navigateTo('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFC4B393), width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Version 1.0.0",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String id,
    int? badge,
    required VoidCallback onTap,
  }) {
    final bool isActive = widget.activeRoute == id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          onTap();
          widget.setIsOpen(false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? selectedIcon : icon,
                size: 20,
                color: isActive ? Colors.white : const Color(0xFF4B5563),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF4B5563),
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.blue : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        widget.setIsOpen(false);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    // This would typically use a navigation method from your app
    // For example, using GetX, Navigator 2.0, or regular Navigator
    Navigator.of(context).pushNamed(route);
  }
}

// Example usage:
// SideNavBar(
//   isOpen: _isNavOpen,
//   setIsOpen: (value) => setState(() => _isNavOpen = value),
//   currentUser: UserProfile(
//     name: "John Doe",
//     email: "john.doe@example.com",
//     avatar: null, // or URL to avatar image
//   ),
//   onLogout: () {
//     // Logout logic
//     Navigator.of(context).pushReplacementNamed('/login');
//   },
//   activeRoute: "home", // Current active route
// )