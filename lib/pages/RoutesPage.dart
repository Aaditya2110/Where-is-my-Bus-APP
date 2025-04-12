import 'dart:convert';
import 'SideNavBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key? key}) : super(key: key);

  @override
  _RoutesPageState createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool isSidebarOpen = false;
  List<Map<String, dynamic>> savedRoutes = [];
  String activeTab = "all"; // "all" or "saved"
  bool isFilterOpen = false;
  bool isLoading = true;
  String selectedFilter = "all"; // "all", "popular", "nearest", "fastest"
  bool showSearchClear = false;
  
  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _loadingAnimationController;
  
  // Routes with stops (waypoints)
  final List<Map<String, dynamic>> routes = [
    {
      'id': 1,
      'number': "101",
      'name': "JKLU-Mansarover",
      'eta': "5 min",
      'destination': [26.891839, 75.743184], // Final destination
      'stops': [[26.85117, 75.641325]], // Stop 1
      'color': "#4F46E5", // Indigo
      'popularity': 4.8,
      'distance': "2.3 km",
      'departureTime': "10:15 AM",
      'arrivalTime': "10:45 AM",
      'fare': "₹25",
      'busType': "AC",
    },
    {
      'id': 2,
      'number': "102",
      'name': "JKLU-Tonk Phatak",
      'eta': "10 min",
      'destination': [27.00047, 75.770244],
      'stops': [
        [26.9012, 75.7556],
        [26.9208, 75.765],
      ],
      'color': "#0EA5E9", // Sky blue
      'popularity': 4.5,
      'distance': "3.7 km",
      'departureTime': "10:30 AM",
      'arrivalTime': "11:15 AM",
      'fare': "₹30",
      'busType': "Non-AC",
    },
    {
      'id': 3,
      'number': "303",
      'name': "Amer Fort",
      'eta': "15 min",
      'destination': [26.988241, 75.962551],
      'stops': [
        [26.9356, 75.8754],
        [26.9608, 75.93],
      ],
      'color': "#10B981", // Emerald
      'popularity': 4.2,
      'distance': "5.1 km",
      'departureTime': "11:00 AM",
      'arrivalTime': "11:45 AM",
      'fare': "₹35",
      'busType': "AC",
    },
    {
      'id': 4,
      'number': "205",
      'name': "City Palace",
      'eta': "8 min",
      'destination': [26.925771, 75.826735],
      'stops': [
        [26.9012, 75.7556],
        [26.9208, 75.765],
      ],
      'color': "#F59E0B", // Amber
      'popularity': 4.6,
      'distance': "4.2 km",
      'departureTime': "10:45 AM",
      'arrivalTime': "11:20 AM",
      'fare': "₹28",
      'busType': "AC",
    },
    {
      'id': 5,
      'number': "404",
      'name': "Hawa Mahal",
      'eta': "12 min",
      'destination': [26.923936, 75.826744],
      'stops': [[26.9012, 75.7556]],
      'color': "#EC4899", // Pink
      'popularity': 4.3,
      'distance': "3.9 km",
      'departureTime': "11:15 AM",
      'arrivalTime': "11:50 AM",
      'fare': "₹32",
      'busType': "Non-AC",
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    // Load saved routes from local storage
    _loadSavedRoutes();
    
    // Setup search controller listener
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
        showSearchClear = searchQuery.isNotEmpty;
      });
    });
    
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _backgroundAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  // Load saved routes from SharedPreferences
  Future<void> _loadSavedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedRoutesJson = prefs.getString('savedRoutes');
    
    if (savedRoutesJson != null) {
      setState(() {
        savedRoutes = List<Map<String, dynamic>>.from(
          json.decode(savedRoutesJson).map((x) => Map<String, dynamic>.from(x))
        );
      });
    }
  }

  // Save routes to SharedPreferences
  Future<void> _saveSavedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedRoutes', json.encode(savedRoutes));
  }

  // Toggle saving a route
  void toggleSaveRoute(Map<String, dynamic> route) {
    setState(() {
      final routeIndex = savedRoutes.indexWhere((r) => r['id'] == route['id']);
      
      if (routeIndex >= 0) {
        savedRoutes.removeAt(routeIndex);
      } else {
        savedRoutes.add(Map<String, dynamic>.from(route));
      }
    });
    
    _saveSavedRoutes();
  }

  // Get filtered routes based on search query, active tab, and selected filter
  List<Map<String, dynamic>> getFilteredRoutes() {
    List<Map<String, dynamic>> filtered = routes.where((route) {
      final matchesSearch = 
        route['number'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        route['name'].toLowerCase().contains(searchQuery.toLowerCase());
      
      if (activeTab == "all") return matchesSearch;
      return matchesSearch && savedRoutes.any((saved) => saved['id'] == route['id']);
    }).toList();

    // Apply sorting based on selected filter
    if (selectedFilter == "popular") {
      filtered.sort((a, b) => (b['popularity'] as double).compareTo(a['popularity'] as double));
    } else if (selectedFilter == "nearest") {
      filtered.sort((a, b) {
        final distanceA = double.parse((a['distance'] as String).split(' ')[0]);
        final distanceB = double.parse((b['distance'] as String).split(' ')[0]);
        return distanceA.compareTo(distanceB);
      });
    } else if (selectedFilter == "fastest") {
      filtered.sort((a, b) {
        final etaA = int.parse((a['eta'] as String).split(' ')[0]);
        final etaB = int.parse((b['eta'] as String).split(' ')[0]);
        return etaA.compareTo(etaB);
      });
    }

    return filtered;
  }

  // Clear search field
  void clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = "";
      showSearchClear = false;
    });
  }

  // Parse hex color
  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = getFilteredRoutes();
    
return Scaffold(
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
      ...List.generate(4, (i) {
        final random = AnimationController(
          vsync: this, 
          duration: Duration(seconds: 5 + i * 2),
        )..repeat(reverse: true);
        
        return AnimatedBuilder(
          animation: random,
          builder: (context, child) {
            return Positioned(
              top: 100.0 + (random.value * 30) + (i * 150),
              left: 50.0 + (random.value * 30) + (i * 80),
              child: Container(
                width: 100.0 + (i * 50),
                height: 100.0 + (i * 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.05),
                      Colors.amber.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      
      // Main content
      SafeArea(
        child: Column(
          children: [
            // Header with Glassmorphism
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6D2).withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu button
                  InkWell(
                    onTap: () {
                      setState(() {
                        isSidebarOpen = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: const Icon(Icons.menu, size: 24),
                    ),
                  ),
                  
                  // Title
                  Text(
                    "Find Your Bus",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF212121),
                            Color(0xFF616161),
                          ],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                  
                  // Filter button
                  InkWell(
                    onTap: () {
                      setState(() {
                        isFilterOpen = !isFilterOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isFilterOpen 
                            ? Colors.blue 
                            : Colors.transparent,
                      ),
                      child: Icon(
                        Icons.tune,
                        size: 24,
                        color: isFilterOpen ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content scrollable area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Search bar
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD9C9A8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search by route number or name",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: showSearchClear 
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  // Filter section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isFilterOpen ? 100 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD9C9A8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: isFilterOpen 
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sort Routes By:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    for (final filter in [
                                      {"id": "all", "label": "Default"},
                                      {"id": "popular", "label": "Most Popular"},
                                      {"id": "nearest", "label": "Nearest"},
                                      {"id": "fastest", "label": "Fastest"},
                                    ])
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFilter = filter["id"]!;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selectedFilter == filter["id"]
                                                ? Colors.blue
                                                : const Color(0xFFE8DCC8),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: selectedFilter == filter["id"]
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Text(
                                            filter["label"]!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: selectedFilter == filter["id"]
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  // Tab Navigation
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFD9C9A8),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTab("All Routes", "all"),
                        _buildTab(
                          "Saved Routes ${savedRoutes.isNotEmpty ? '(${savedRoutes.length})' : ''}",
                          "saved",
                        ),
                      ],
                    ),
                  ),
                  
                  // Routes List
                  if (isLoading)
                    // Loading indicator
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          RotationTransition(
                            turns: _loadingAnimationController,
                            child: const Icon(
                              Icons.refresh,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Finding the best routes for you...",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (filteredRoutes.isNotEmpty)
                    // Routes list
                    Column(
                      children: filteredRoutes.map((route) {
                        final isSaved = savedRoutes.any((saved) => saved['id'] == route['id']);
                        
                        return _buildRouteCard(route, isSaved);
                      }).toList(),
                    )
                  else
                    // No routes found
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD9C9A8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E6D2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 32,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No routes found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeTab == "saved"
                                ? "You haven't saved any routes yet"
                                : "Try adjusting your search criteria",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          if (activeTab == "saved") ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  activeTab = "all";
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Browse all routes"),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                  // Extra space at bottom for bottom navigation
                  const SizedBox(height: 80),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: const Border(
              top: BorderSide(color: Color(0xFFD9C9A8)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.map, "Routes", true, () {}),
              _buildBottomNavItem(Icons.directions_bus, "Track", false, 
                () => Navigator.pushNamed(context, '/track/1')),
              _buildBottomNavItem(Icons.notifications_none, "Alerts", false, 
                () => Navigator.pushNamed(context, '/notifications')),
              _buildBottomNavItem(Icons.bookmark_border, "Saved", false, 
                () => Navigator.pushNamed(context, '/saved-routes')),
            ],
          ),
        ),
      ),
      
      // SideNavBar should be the LAST child in the Stack to ensure it appears on top of everything
      SideNavBar(
        isOpen: isSidebarOpen,
        setIsOpen: (value) {
          setState(() {
            isSidebarOpen = value;
          });
        },
        currentUser: UserProfile(
          name: "Guest User", // Replace with actual user data when available
          email: "user@example.com", // Replace with actual user data
          avatar: null, // Add avatar URL if available
        ),
        onLogout: () {
          // Add your logout logic here
          Navigator.of(context).pushReplacementNamed('/login');
        },
        activeRoute: "home", // Set this to match the current route
      ),
    ],
  ),
);
    
  }

  // Build a tab button
  Widget _buildTab(String title, String tabId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = tabId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: activeTab == tabId ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: activeTab == tabId ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  // Build a route card
  Widget _buildRouteCard(Map<String, dynamic> route, bool isSaved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9C9A8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Color bar at top
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: hexToColor(route['color']),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          
          // Route content
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/track/${route['id']}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route number badge and bookmark button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hexToColor(route['color']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              route['number'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Bookmark button
                      InkWell(
                        onTap: () => toggleSaveRoute(route),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 24,
                            color: isSaved ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Route name and info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Stops and ETA
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${(route['stops'] as List).length} stops",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    route['eta'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Stars rating
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < (route['popularity'] as double).floor()
                                      ? Icons.star
                                      : index < route['popularity']
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                              const SizedBox(width: 4),
                              Text(
                                "(${route['popularity']})",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Arrow button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E6D2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  
                  // Additional route details
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRouteInfoItem("Distance", route['distance']),
                        _buildRouteInfoItem("Distance", route['distance']),
_buildRouteInfoItem("Fare", route['fare']),
_buildRouteInfoItem("Type", route['busType']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a route info item
  Widget _buildRouteInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Build a bottom navigation item
  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 24, 
            color: isActive ? Colors.blue : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
