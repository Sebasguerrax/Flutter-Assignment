import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({Key? key}) : super(key: key);

  @override
  _RidesScreenState createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  late Future<List<Ride>> _rides;
  List<int> _favouriteRideIds = []; // List to hold favorite ride IDs

  @override
  void initState() {
    super.initState();
    _rides = _loadRides();
    _loadFavourites(); // Load favourites from local storage
  }

  // Load rides from JSON file
  Future<List<Ride>> _loadRides() async {
    final String response = await rootBundle.loadString('assets/json/rides.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Ride.fromJson(json)).toList();
  }

  // Load favourite rides from local storage
  Future<void> _loadFavourites() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          _favouriteRideIds = List<int>.from(jsonDecode(contents));
        });
      }
    } catch (e) {
      print("Error loading favourites: $e");
    }
  }

  // Save favourite rides to local storage
  Future<void> _saveFavourites() async {
    try {
      final file = await _getLocalFile();
      await file.writeAsString(jsonEncode(_favouriteRideIds));
    } catch (e) {
      print("Error saving favourites: $e");
    }
  }

  // Get the local file for favourites
  Future<File> _getLocalFile() async {
    final directory = Directory.systemTemp; // Use a temporary directory for simplicity
    return File('${directory.path}/favourites.json');
  }

  // Toggle ride as a favourite
  void _toggleFavourite(int rideId) {
    setState(() {
      if (_favouriteRideIds.contains(rideId)) {
        _favouriteRideIds.remove(rideId);
      } else {
        _favouriteRideIds.add(rideId);
      }
    });
    _saveFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rides"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Ride>>(
        future: _rides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading rides."));
          } else if (snapshot.hasData) {
            final rides = snapshot.data!;
            return ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                final isFavourite = _favouriteRideIds.contains(ride.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.asset(ride.image, fit: BoxFit.cover, width: 60),
                    title: Text(ride.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Wait time: ${ride.waitTime}"),
                    trailing: IconButton(
                      icon: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: isFavourite ? Colors.red : null,
                      ),
                      onPressed: () => _toggleFavourite(ride.id),
                    ),
                    onTap: () => _showRideDetails(context, ride),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No rides available."));
          }
        },
      ),
    );
  }

  // Show ride details in a dialog
  void _showRideDetails(BuildContext context, Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ride.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(ride.image, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(ride.description),
            const SizedBox(height: 10),
            Text("Wait time: ${ride.waitTime}"),
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

// Ride model class
class Ride {
  final int id;
  final String name;
  final String description;
  final String waitTime;
  final String image;

  Ride({
    required this.id,
    required this.name,
    required this.description,
    required this.waitTime,
    required this.image,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      waitTime: json['wait_time'],
      image: json['image'],
    );
  }
}
