import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:math';
import 'SideNavBar.dart';

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

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type;
  bool read;
  final IconData icon;
  final Color color;
  final String route;
  final bool actionable;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
    required this.icon,
    required this.color,
    required this.route,
    required this.actionable,
  });
}

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NotificationItem> notifications = [];
  bool isLoading = true;
  String activeFilter = 'all';
  NotificationItem? selectedNotification;
  late AnimationController _animationController;
  bool isSidebarOpen = false;
  UserProfile? currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
    _loadNotifications();
    
    currentUser = UserProfile(
      name: "John Doe",
      email: "john.doe@example.com",
      avatar: null,
    );
  }

  void _loadNotifications() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      notifications = [
        NotificationItem(
          id: 1,
          title: "Bus 101 Delayed",
          message: "Your bus is running 5 minutes late due to traffic...",
          time: "5 min ago",
          type: "alert",
          read: false,
          icon: FontAwesome.exclamation_triangle,
          color: Colors.red,
          route: "101",
          actionable: true,
        ),
        NotificationItem(
          id: 2,
          title: "Route Change Alert",
          message: "Route 203 has been temporarily diverted...",
          time: "20 min ago",
          type: "alert",
          read: false,
          icon: FontAwesome.map_signs,
          color: Colors.orange,
          route: "203",
          actionable: true,
        ),
        NotificationItem(
          id: 3,
          title: "Ticket Purchased",
          message: "Your monthly pass has been successfully purchased...",
          time: "2 hours ago",
          type: "info",
          read: true,
          icon: FontAwesome.ticket,
          color: Colors.green,
          route: "",
          actionable: false,
        ),
      ];
      isLoading = false;
    });
  }

  void _markAsRead(int id) {
    setState(() {
      notifications = notifications.map((n) => 
        n.id == id ? NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          time: n.time,
          type: n.type,
          read: true,
          icon: n.icon,
          color: n.color,
          route: n.route,
          actionable: n.actionable,
        ) : n
      ).toList();
    });
  }

  void _deleteNotification(int id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((n) => NotificationItem(
        id: n.id,
        title: n.title,
        message: n.message,
        time: n.time,
        type: n.type,
        read: true,
        icon: n.icon,
        color: n.color,
        route: n.route,
        actionable: n.actionable,
      )).toList();
    });
  }

  List<NotificationItem> get filteredNotifications {
    switch (activeFilter) {
      case 'unread': return notifications.where((n) => !n.read).toList();
      case 'alerts': return notifications.where((n) => n.type == 'alert').toList();
      default: return notifications;
    }
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Added missing method
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          painter: BackgroundPainter(_animationController.value),
        );
      },
    );
  }

  List<Widget> _buildAnimatedBackgroundElements() {
    final random = Random();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                PreferredSize(
                  preferredSize: Size.fromHeight(48),
                  child: _buildFilterTabs(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildAnimatedBackground(),
                      isLoading ? _buildLoadingIndicator() 
                        : filteredNotifications.isEmpty 
                          ? _buildEmptyState() 
                          : _buildNotificationList(),
                      if (selectedNotification != null) _buildDetailsModal(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(top: BorderSide(color: Color(0xFFD9C9A8))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.map, "Routes", false, () => Navigator.pushReplacementNamed(context, '/route')),
                  _buildBottomNavItem(Icons.directions_bus, "Track", false, 
                    () => Navigator.pushReplacementNamed(context, '/track/1')),
                  _buildBottomNavItem(Icons.notifications, "Alerts", true, 
                    () => Navigator.pushReplacementNamed(context, '/notifications')),
                  _buildBottomNavItem(Icons.bookmark_border, "Saved", false, 
                    () => Navigator.pushReplacementNamed(context, '/saved-routes')),
                ],
              ),
            ),
          ),

          // Side Navigation
          if (isSidebarOpen)
            SideNavBar(
              isOpen: isSidebarOpen,
              setIsOpen: (value) => setState(() => isSidebarOpen = value),
              // currentUser: currentUser,
              onLogout: _handleLogout,
              activeRoute: "notifications",
            ),
        ],
      ),
    );
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
              Icon(FontAwesome.bell, size: 24, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, size: 24, color: Colors.black87),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _buildFilterMenu(),
            ),
            tooltip: 'Filter notifications', // Accessibility improvement
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon, 
    String label, 
    bool isActive, 
    VoidCallback onTap
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isActive ? Colors.blue : Colors.black54),
          SizedBox(height: 4),
          Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab('All', 'all'),
          _buildFilterTab('Unread', 'unread'),
          _buildFilterTab('Alerts', 'alerts'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, String filter) {
    final isActive = activeFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => activeFilter = filter),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text, style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.blue : Colors.black87,
                )),
                if (filter == 'unread' && notifications.any((n) => !n.read))
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.blue,
                      child: Text(
                        notifications.where((n) => !n.read).length.toString(),
                        style: TextStyle(fontSize: 10, color: Colors.white),
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

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: notification.read ? Colors.grey[200]! : Colors.blue[300]!,
            ),
          ),
          child: InkWell(
            onTap: () {
              _markAsRead(notification.id);
              setState(() => selectedNotification = notification);
            },
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.color.withOpacity(0.1),
                    child: Icon(notification.icon, color: notification.color),
                  ),
                  title: Row(
                    children: [
                      Text(notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notification.read ? Colors.grey[700] : Colors.grey[900],
                        )),
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(FontAwesome.trash, color: Colors.grey),
                    onPressed: () => _deleteNotification(notification.id),
                  ),
                ),
                Container(
                  height: 4,
                  color: notification.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsModal() {
    final n = selectedNotification!;
    return Stack(
      children: [
        ModalBarrier(
          dismissible: true,
          onDismiss: () => setState(() => selectedNotification = null),
        ),
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: n.color,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: Text(n.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => selectedNotification = null),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(n.icon, color: n.color),
                            SizedBox(width: 16),
                            Text(n.time, style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 8), // Added spacing
                            Chip(
                              label: Text('Route ${n.route}'),
                              backgroundColor: n.color.withOpacity(0.1),
                              labelStyle: TextStyle(color: n.color),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(n.message),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text('Close'),
                              onPressed: () => setState(() => selectedNotification = null),
                            ),
                            if (n.actionable)
                              ElevatedButton(
                                child: Text('View Route'),
                                onPressed: () {
                                  setState(() => selectedNotification = null);
                                  Navigator.pushNamed(context, '/track/${n.route}');
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterMenu() {
    return AlertDialog(
      title: Text("Filter Notifications"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...['all', 'unread', 'alerts'].map((filter) => ListTile(
            title: Text(filter == 'all' ? 'All Notifications' 
              : filter == 'unread' ? 'Unread Only' : 'Alerts Only'),
            leading: activeFilter == filter ? Icon(Icons.check, color: Colors.blue) : null,
            onTap: () {
              setState(() => activeFilter = filter);
              Navigator.pop(context);
            },
          )),
          Divider(),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.blue),
            title: Text("Mark all as read"),
            onTap: () {
              _markAllAsRead();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Clear all notifications"),
            onTap: () {
              setState(() => notifications.clear());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _animationController,
            child: Icon(FontAwesome.bell, size: 40, color: Colors.blue),
          ),
          SizedBox(height: 16),
          Text("Loading notifications...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesome.bell, size: 40, color: Colors.grey),
          SizedBox(height: 16),
          Text("No notifications", style: TextStyle(color: Colors.grey[800])),
          SizedBox(height: 8),
          if (activeFilter != 'all')
            ElevatedButton(
              child: Text("View all notifications"),
              onPressed: () => setState(() => activeFilter = 'all'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  
  BackgroundPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    for (int i = 0; i < 3; i++) {
      final startX = size.width * 0.1;
      final startY = size.height * (0.2 + 0.2 * i) + sin(animationValue * 2 * pi + i) * 20;
      
      path.moveTo(startX, startY);
      
      for (int j = 1; j <= 5; j++) {
        final x = startX + size.width * 0.18 * j;
        final y = startY + sin(animationValue * 2 * pi + j * 0.5 + i) * 30;
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}