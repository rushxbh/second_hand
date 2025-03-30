import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<String> _uploadImageToCloudinary(File imageFile) async {
  try {
    String cloudName = "dke7f8nkt";  // Your Cloudinary cloud name
    String uploadPreset = "traderhub"; // Your Cloudinary preset
    String apiUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonData = json.decode(responseData);

    if (response.statusCode == 200) {
      return jsonData['secure_url']; // Cloudinary image URL
    } else {
      print("Cloudinary upload failed: $jsonData");
      return "";
    }
  } catch (e) {
    print("Error uploading to Cloudinary: $e");
    return "";
  }
}


  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostController = TextEditingController();

  File? _image;
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
      print("ERROROROROROR");
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _postItem() async {
  User? user = _auth.currentUser;
  if (user == null || _image == null) return;

  try {
    print("Posting item...");

    // Upload image to Cloudinary
    String imageUrl = await _uploadImageToCloudinary(_image!);

    if (imageUrl.isEmpty) {
      throw "Image upload failed";
    }

    print("Image URL: $imageUrl");

    // Store item details in Firestore
    await _firestore.collection('items').add({
      'item_name': _itemNameController.text,
      'original_cost': _itemCostController.text,
      'image': imageUrl,
      'user': user.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item posted successfully!")),
    );

    // Clear fields
    _itemNameController.clear();
    _itemCostController.clear();
    setState(() {
      _image = null;
    });
  } catch (e) {
    print("Error posting item: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to post item: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Info
              Text("Your Profile",
                  style: Theme.of(context).textTheme.headlineLarge),
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name")),
              TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: "City")),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: const Text("Update Profile"),
              ),

              const Divider(),

              // Post Item Section
              Text("Post an Item",
                  style: Theme.of(context).textTheme.headlineLarge),
              TextField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(labelText: "Item Name")),
              TextField(
                controller: _itemCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Original Cost"),
              ),
              const SizedBox(height: 10),

              // Image Picker
              _image == null
                  ? ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera),
                      label: const Text("Take Photo"),
                    )
                  : Image.file(_image!, height: 150),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _postItem,
                child: const Text("Post Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
