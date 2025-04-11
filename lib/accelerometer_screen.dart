import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({Key? key}) : super(key: key);

  @override
  _AccelerometerScreenState createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  double _x = 0.0, _y = 0.0, _z = 0.0;

  @override
  void initState() {
    super.initState();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accelerometer Data")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Accelerometer Data:"),
            Text("X: $_x"),
            Text("Y: $_y"),
            Text("Z: $_z"),
            const SizedBox(height: 20),
            const Text("Move the device to see the changes!"),
          ],
        ),
      ),
    );
  }
}
