import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // Assuming this is your login screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  String? _profilePictureUrl; // Placeholder for the profile picture URL
  bool _isLoading = false;
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load the user's profile data from Firebase
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Retrieve user data from Firestore (adjust the 'users' collection as needed)
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            _username = docSnapshot['username'] ?? 'Anonymous'; // Use the username from Firestore
            _profilePictureUrl = user.photoURL ?? ''; // Use the photoURL
            _usernameController.text = _username!; // Set the text field to the existing username
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save the updated username to Firestore
  Future<void> _saveUsername() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null && _usernameController.text.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': _usernameController.text,
        }, SetOptions(merge: true)); // Merge so it doesn't overwrite other data
        setState(() {
          _username = _usernameController.text; // Update UI with new username
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      }
    } catch (e) {
      print('Error saving username: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Log out and navigate to login screen
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()), // Navigate to login screen (main.dart)
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                        ? NetworkImage(_profilePictureUrl!)
                        : const AssetImage('assets/images/default_avatar.jpg') as ImageProvider,
                  ),
                  const SizedBox(height: 16.0),

                  // Username (Editable)
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Save Changes Button
                  ElevatedButton(
                    onPressed: _saveUsername, // Save the updated username
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 16.0),

                  // Logout Button
                  ElevatedButton(
                    onPressed: _logout, // Log out and navigate to login screen
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            ),
    );
  }
}
