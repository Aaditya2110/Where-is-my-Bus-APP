import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RouteDetailsPage extends StatefulWidget {
  final String routeId;

  const RouteDetailsPage({Key? key, required this.routeId}) : super(key: key);

  @override
  _RouteDetailsPageState createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> with TickerProviderStateMixin {
  int currentStopIndex = 0;
  double progressPercent = 0;
  String busStatus = "Moving";
  bool isAnimating = true;
  Timer? animationTimer;
  late AnimationController busAnimationController;
  
  // Seat data
  Map<String, dynamic> seatData = {
    "totalSeats": 42,
    "occupiedSeats": 0,
  };

  // Stops data
  final List<Map<String, dynamic>> stops = [
    {
      "name": "JKLU",
      "time": "14:30",
      "distance": "Start",
      "type": "start",
      "status": "completed",
    },
    {
      "name": "Bhakrota",
      "time": "14:45",
      "distance": "5 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Keshopura",
      "time": "15:00",
      "distance": "10 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Kamla Nehru Nagar",
      "time": "15:15",
      "distance": "15 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Gajsinghpur",
      "time": "15:30",
      "distance": "20 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "RSEB Colony",
      "time": "15:45",
      "distance": "25 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Vardhman Nagar",
      "time": "16:00",
      "distance": "30 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "200ft Bus Stand",
      "time": "16:15",
      "distance": "35 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Element Mall",
      "time": "16:30",
      "distance": "40 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Vidyut Nagar",
      "time": "16:45",
      "distance": "45 Km",
      "type": "normal",
      "status": "upcoming",
    },
    {
      "name": "Mansarover",
      "time": "17:00",
      "distance": "50 Km",
      "type": "destination",
      "status": "upcoming",
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize bus animation controller
    busAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Start animation
    startAnimation();
    
    // Fetch seat data
    fetchSeatData();
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    busAnimationController.dispose();
    super.dispose();
  }

  // Calculate total progress percentage across the entire route
  double calculateTotalProgress() {
    if (currentStopIndex >= stops.length - 1) return 100;
    
    final double segmentSize = 100 / (stops.length - 1);
    return (currentStopIndex * segmentSize) + (progressPercent / 100) * segmentSize;
  }

  void startAnimation() async {
    setState(() {
      currentStopIndex = 0;
      progressPercent = 0;
      busStatus = "Moving to ${stops[0]['name']}";
    });

    animateBusMovement();
  }

  void animateBusMovement() async {
    for (int i = 0; i < stops.length - 1; i++) {
      if (!isAnimating) return;
      
      setState(() {
        currentStopIndex = i;
        busStatus = "Moving to ${stops[i + 1]['name']}";
      });

      for (int p = 0; p <= 100; p += 1) {
        if (!isAnimating) return;
        
        await Future.delayed(const Duration(milliseconds: 250));
        setState(() {
          progressPercent = p.toDouble();
        });
      }

      setState(() {
        currentStopIndex = i + 1;
        progressPercent = 0;
        busStatus = "Halted at ${stops[i + 1]['name']}";
      });
      
      await Future.delayed(const Duration(milliseconds: 4500));
    }

    setState(() {
      busStatus = "Reached Destination";
    });
  }

  // Fetch seat data from API
  Future<void> fetchSeatData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/seats/${widget.routeId}'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          seatData = data;
        });
      } else {
        throw Exception('Failed to fetch seat data');
      }
    } catch (error) {
      debugPrint('Error fetching seat data: $error');
    }

    // Poll for updates every 10 seconds
    Timer(const Duration(seconds: 10), fetchSeatData);
  }

  // Navigate to map view
  void handleViewOnMap() {
    final destination = [26.891839, 75.743184]; // Example destination coordinates
    final routeStops = [
      [26.85117, 75.641325], // Example stop coordinates
      [26.9012, 75.7556],
      [26.9208, 75.765],
    ];

    Navigator.pushNamed(
      context, 
      '/map/${widget.routeId}',
      arguments: {
        'lat': destination[0],
        'lng': destination[1],
        'stops': routeStops,
      },
    );
  }

  // Navigate to payment page
  void handleBuyTicket() {
    Navigator.pushNamed(context, '/payment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with glass effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(24),
                      elevation: 4,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.blue, Colors.indigo],
                      ).createShader(bounds),
                      child: const Text(
                        'Route Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Bus Info Card
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: Icon(
                                              Icons.directions_bus,
                                              size: 24,
                                              color: Colors.blue[600],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Bus #${widget.routeId}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${stops[0]['name']} → ${stops[stops.length - 1]['name']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 20,
                                            color: busStatus.contains("Halted")
                                                ? Colors.amber[500]
                                                : busStatus.contains("Reached")
                                                    ? Colors.green[500]
                                                    : Colors.blue[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            busStatus,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: busStatus.contains("Halted")
                                                  ? Colors.amber[500]
                                                  : busStatus.contains("Reached")
                                                      ? Colors.green[500]
                                                      : Colors.blue[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ETA: ${stops[stops.length - 1]['time']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // Progress bar
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        stops[0]['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      Text(
                                        '${calculateTotalProgress().round()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      Text(
                                        stops[stops.length - 1]['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 8,
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      child: FractionallySizedBox(
                                        widthFactor: calculateTotalProgress() / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blue, Colors.indigo.shade600],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
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
                      
                      // Route Timeline Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Colors.blue, Colors.indigo],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Route Timeline',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: handleViewOnMap,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green[500],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 3,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('View on Map'),
                                  ),
                                ],
                              ),
                              
                              // Timeline
                              const SizedBox(height: 24),
                              Stack(
                                children: [
                                  // Timeline track (background)
                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    bottom: 16,
                                    child: Container(
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  
                                  // Progress track (blue fill)
                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    child: Container(
                                      width: 4,
                                      height: (stops.length * 90 - 32) * calculateTotalProgress() / 100,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.blue, Colors.indigo],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  
                                  // Bus position indicator
                                  if (calculateTotalProgress() > 0 && calculateTotalProgress() < 100)
                                    Positioned(
                                      left: 16,
                                      top: 16 + ((stops.length * 90 - 32) * calculateTotalProgress() / 100),
                                      child: Transform.translate(
                                        offset: const Offset(-14, -14),
                                        child: AnimatedBuilder(
                                          animation: busAnimationController,
                                          builder: (context, child) {
                                            final double scale = busStatus.contains("Moving")
                                                ? 1.0 + 0.1 * busAnimationController.value
                                                : 1.0;
                                            
                                            return Transform.scale(
                                              scale: scale,
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: busStatus.contains("Halted")
                                                        ? Colors.amber.shade500
                                                        : Colors.blue.shade500,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.directions_bus,
                                                  size: 20,
                                                  color: busStatus.contains("Halted")
                                                      ? Colors.amber[500]
                                                      : busStatus.contains("Reached")
                                                          ? Colors.green[500]
                                                          : Colors.blue[500],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  
                                  // Stops
                                  Column(
                                    children: List.generate(
                                      stops.length,
                                      (index) {
                                        final stop = stops[index];
                                        final isPassed = index < currentStopIndex ||
                                            (index == currentStopIndex && progressPercent == 100);
                                        final isCurrent = index == currentStopIndex;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 40, bottom: 16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Stop marker
                                              Container(
                                                margin: const EdgeInsets.only(top: 12, right: 16),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: isPassed
                                                      ? Colors.blue
                                                      : isCurrent && progressPercent == 0 && busStatus.contains("Halted")
                                                          ? Colors.amber[100]
                                                          : Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isPassed
                                                        ? Colors.blue
                                                        : isCurrent && progressPercent == 0 && busStatus.contains("Halted")
                                                            ? Colors.amber.shade500
                                                            : Colors.grey.shade300,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: index == stops.length - 1 && isPassed
                                                    ? Center(
                                                        child: Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration: BoxDecoration(
                                                            color: Colors.green[500],
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              
                                              // Stop content
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: isCurrent && progressPercent == 0
                                                        ? Colors.blue.shade50
                                                        : isPassed
                                                            ? Colors.grey.shade50
                                                            : Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: isCurrent && progressPercent == 0
                                                          ? Colors.blue.shade200
                                                          : Colors.grey.shade100,
                                                    ),
                                                    boxShadow: isCurrent && progressPercent == 0
                                                        ? [
                                                            BoxShadow(
                                                              color: Colors.blue.withOpacity(0.1),
                                                              blurRadius: 4,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            stop['name'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.black87,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            stop['distance'] as String,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            stop['time'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.black87,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          if (isCurrent && progressPercent == 0 && busStatus.contains("Halted"))
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors.amber.shade100,
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: Text(
                                                                'Current',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.amber.shade700,
                                                                ),
                                                              ),
                                                            )
                                                          else if (isPassed && index != currentStopIndex)
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors.green.shade100,
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: Text(
                                                                'Passed',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.green.shade700,
                                                                ),
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bus Information Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Colors.amber[500],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.amber.shade500, Colors.orange.shade500],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Bus Information',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 2.5,
                                children: [
                                  _buildInfoCard('Driver', 'Rajesh Kumar'),
                                  _buildInfoCard('Number', 'RJ 14 BT 2253'),
                                  _buildInfoCard('Capacity', '42 Seats'),
                                  _buildInfoCard('Contact', '+91 9876543210'),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: handleBuyTicket,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Buy Ticket',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Seat Availability Section
                      SeatAvailability(
                        totalSeats: seatData['totalSeats'],
                        occupiedSeats: seatData['occupiedSeats'],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
Widget _buildInfoCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// SeatAvailability Widget
class SeatAvailability extends StatelessWidget {
  final int totalSeats;
  final int occupiedSeats;

  const SeatAvailability({
    Key? key,
    required this.totalSeats,
    required this.occupiedSeats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final availableSeats = totalSeats - occupiedSeats;
    final percentOccupied = (occupiedSeats / totalSeats) * 100;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.green.shade600, Colors.teal.shade600],
              ).createShader(bounds),
              child: const Text(
                'Seat Availability',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      // Background circle
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: availableSeats / totalSeats,
                          strokeWidth: 10,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentOccupied > 90
                                ? Colors.red
                                : percentOccupied > 70
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                      // Center text
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$availableSeats',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSeatStat('Total Seats', totalSeats.toString(), Colors.blue),
                      const SizedBox(height: 12),
                      _buildSeatStat('Occupied', occupiedSeats.toString(), Colors.orange),
                      const SizedBox(height: 12),
                      _buildSeatStat('Available', availableSeats.toString(), Colors.green),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Colored indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator('Low', Colors.green),
                const SizedBox(width: 16),
                _buildIndicator('Medium', Colors.orange),
                const SizedBox(width: 16),
                _buildIndicator('High', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}