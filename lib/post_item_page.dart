import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostItemPage extends StatefulWidget {
  const PostItemPage({Key? key}) : super(key: key);

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    try {
      String cloudName = "dke7f8nkt"; // Your Cloudinary cloud name
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt, size: 40, color: Color.fromARGB(255, 30, 138, 44)),
                onPressed: () async {
                  final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, pickedImage);
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo_library, size: 40, color: Color.fromARGB(255, 30, 138, 44)),
                onPressed: () async {
                  final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, pickedImage);
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      setState(() => _image = File(image.path));
    }
  }

  Future<void> _postItem() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = await _uploadImageToCloudinary(_image!);
      
      await FirebaseFirestore.instance.collection('items').add({
        'item_name': _itemNameController.text,
        'original_cost': double.parse(_itemCostController.text),
        'description': _descriptionController.text,
        'image': imageUrl,
        'user': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Post New Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Card Content
                Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Item Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 30, 138, 44),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Image Picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: _image == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Color.fromARGB(255, 30, 138, 44),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Item Photo',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 30, 138, 44),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white.withOpacity(0.8),
                                            radius: 16,
                                            child: IconButton(
                                              iconSize: 18,
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.edit, color: Color.fromARGB(255, 30, 138, 44)),
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Form Fields
                          TextFormField(
                            controller: _itemNameController,
                            decoration: const InputDecoration(
                              labelText: 'Item Name',
                              prefixIcon: Icon(Icons.inventory, color: Color.fromARGB(255, 30, 138, 44)),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 30, 138, 44), width: 2),
                              ),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _itemCostController,
                            decoration: const InputDecoration(
                              labelText: 'Original Cost',
                              prefixIcon: Icon(Icons.currency_rupee, color: Color.fromARGB(255, 30, 138, 44)),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 30, 138, 44), width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description, color: Color.fromARGB(255, 30, 138, 44)),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 30, 138, 44), width: 2),
                              ),
                            ),
                            maxLines: 3,
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Post Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _postItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 30, 138, 44),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Post Item',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
}