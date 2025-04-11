import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accelerometer_screen.dart';
import 'about_us_screen.dart';

// Restaurant model class
class Restaurant {
  final String name;
  final String description;
  final String imageUrl;

  Restaurant({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  late Future<List<Restaurant>> _restaurants;
  ScrollController _scrollController = ScrollController();
  bool _isAtEnd = false;

  @override
  void initState() {
    super.initState();
    _restaurants = _loadRestaurants();

    // Listen for scroll changes to detect when the user reaches the end
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          _isAtEnd = true;
        });
      } else {
        setState(() {
          _isAtEnd = false;
        });
      }
    });
  }

  // Load restaurants from JSON
  Future<List<Restaurant>> _loadRestaurants() async {
    final String response = await rootBundle.loadString('assets/json/restaurants.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Wrap everything in a SingleChildScrollView to make it scrollable
          child: Column(
            children: [
              // Welcome banner
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/theme_park_banner.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Text(
                        "Welcome to Bertie's Theme Park!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Popular Restaurants section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Popular Restaurants",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<Restaurant>>(
                future: _restaurants,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading restaurants."));
                  } else if (snapshot.hasData) {
                    final restaurants = snapshot.data!;
                    return SizedBox(
                      height: 160, // Decreased height for restaurant cards section
                      child: ListView.builder(
                        controller: _scrollController, // Attach scroll controller
                        scrollDirection: Axis.horizontal,
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          return GestureDetector(
                            onTap: () => _showRestaurantDetails(context, restaurant),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              width: 140, // Decreased width for smaller restaurant cards
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.asset(
                                      restaurant.imageUrl,
                                      width: 140,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    restaurant.name,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: Text("No restaurants available."));
                  }
                },
              ),

              const SizedBox(height: 10.0),

              // FAQ and About Us buttons
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.all(10.0),
                shrinkWrap: true, // Allow GridView to take only the necessary space
                physics: NeverScrollableScrollPhysics(),  // Disable GridView scrolling
                children: [
                  _buildFeatureCard(
                    context,
                    "Accelerometer",
                    Icons.trending_up,
                    Colors.blueAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccelerometerScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    "About Us",
                    Icons.info_outline,
                    Colors.greenAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable card for FAQ/About Us buttons
  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show restaurant details in a dialog
  void _showRestaurantDetails(BuildContext context, Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(restaurant.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(restaurant.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
