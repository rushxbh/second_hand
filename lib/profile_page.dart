import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Thrifty/services/auth_service.dart';
import 'package:Thrifty/your_requests_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _userName;
  String? _userCity;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'];
            _userCity = userDoc['city'];
            _nameController.text = _userName!;
            _cityController.text = _userCity!;
          });
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'city': _cityController.text,
      }, SetOptions(merge: true));

      setState(() {
        _userName = _nameController.text;
        _userCity = _cityController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color.fromARGB(255, 30, 138, 44),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () => Navigator.pushNamed(context, '/post-item'),
              color: Colors.white,
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const YourRequestsPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _authService.signOut().then((_) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $error')),
                  );
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 30, 138, 44),
                    const Color.fromARGB(255, 30, 138, 44).withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color.fromARGB(255, 30, 138, 44)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: "City",
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateUserProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 30, 138, 44),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Update Profile"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}