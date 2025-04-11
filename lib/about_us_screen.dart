import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart'; // Add in pubspec.yaml
import 'package:connectivity_plus/connectivity_plus.dart'; // Add in pubspec.yaml

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  String _batteryStatus = "Unknown";
  String _networkStatus = "Unknown";

  @override
  void initState() {
    super.initState();
    _getBatteryStatus();
    _getNetworkStatus();
  }

  // Function to get the battery status
  Future<void> _getBatteryStatus() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryStatus = "$batteryLevel%";
    });
  }

  // Function to get the network status
  Future<void> _getNetworkStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    String status;
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        status = "Wi-Fi";
        break;
      case ConnectivityResult.mobile:
        status = "Mobile Data";
        break;
      case ConnectivityResult.none:
        status = "No Connection";
        break;
      default:
        status = "Unknown";
    }
    setState(() {
      _networkStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paragraph about the theme park
            const Text(
              "Welcome to Bertie's Theme Park! Our park is a world of wonder, excitement, "
              "and unforgettable adventures. From thrilling roller coasters to tranquil gardens, "
              "we offer something for everyone. Whether you're here for the rides, the food, or the "
              "entertainment, Bertie's Theme Park promises a magical experience for visitors of all ages. "
              "Come and make memories that last a lifetime!",
              style: TextStyle(
                fontFamily: 'Roboto', // Roboto is default on Android
                fontSize: 18.0, // Larger font size for readability
                height: 1.8, // Line height for spacing
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30.0),

            // App version
            const Text(
              "App Version: 1.0.0",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),

            // Battery status
            Row(
              children: [
                const Icon(Icons.battery_full, color: Colors.green),
                const SizedBox(width: 8.0),
                Text(
                  "Battery Status: $_batteryStatus",
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),

            // Network connectivity
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.blueAccent),
                const SizedBox(width: 8.0),
                Text(
                  "Network Status: $_networkStatus",
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
