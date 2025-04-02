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
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

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
              icon: const Icon(Icons.camera_alt, size: 40),
              onPressed: () async {
                final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, pickedImage);
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo_library, size: 40),
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

  // Your existing _uploadImageToCloudinary method here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Item'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[100],
                child: _image == null
                    ? IconButton(
                        icon: const Icon(Icons.add_photo_alternate, size: 50),
                        onPressed: _pickImage,
                      )
                    : Stack(
                        children: [
                          Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemCostController,
                      decoration: const InputDecoration(
                        labelText: 'Original Cost',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _postItem,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Post Item'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}