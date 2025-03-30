import 'package:flutter/material.dart';
import './services/firestore_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Map<String, dynamic>> items = await _firestoreService.fetchItemsWithUsers();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marketplace")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text("No items found"))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    var item = _items[index];
                    var user = item['userDetails'] ?? {};
                    
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: item['image'] != null
                            ? Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 60),
                        title: Text(item['item_name'] ?? "No Name"),
                        subtitle: Text("₹${item['original_cost']}"),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(user['name'] ?? "Unknown", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(user['city'] ?? "No City", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
