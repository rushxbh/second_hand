import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final TextEditingController _amountController = TextEditingController();
  
  ProductDetailPage({Key? key, required this.product}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    print(product);
    
    Future<void> _createTradeRequest(
        String offeredItemId, String requestedItemId) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      try {
        await FirebaseFirestore.instance.collection('trade_requests').add({
          'senderId': currentUser.uid,
          'receiverId': product['userId'],
          'offeredItemId': offeredItemId,
          'requestedItemId': requestedItemId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buy request sent!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oops! Request not Sent: $e')),
        );
      }
    }

    Future<void> _showTradeDialog(BuildContext context) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Place your Offer',
            style: TextStyle(
              color: Color.fromARGB(255, 30, 138, 44),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the amount you want to offer:'),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.currency_rupee, color: Color.fromARGB(255, 30, 138, 44)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 30, 138, 44), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = _amountController.text;
                _createTradeRequest(amount, product['id']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 138, 44),
              ),
              child: const Text('Offer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.topCenter, // We only want the top part to be green
            colors: [
              const Color.fromARGB(255, 30, 138, 44),
              const Color.fromARGB(255, 30, 138, 44),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Sliver app bar with image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 30, 138, 44),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.black87),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.black87),
                  ),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image
                    product['image'] != null && product['image'].isNotEmpty
                        ? Image.network(
                            product['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 80, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                size: 80, color: Colors.grey),
                          ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product details
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.all(0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product name
                          Expanded(
                            child: Text(
                              product['name'] ?? "Unknown Product",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          // Price tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 138, 44),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "₹${product['price']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Seller information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // Seller avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 30, 138, 44).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.person,
                                    color: Color.fromARGB(255, 30, 138, 44), size: 30),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Seller details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['user'] ?? "Unknown Seller",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['location'] ?? "Unknown location",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Contact button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 30, 138, 44).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.message_outlined,
                                    color: Color.fromARGB(255, 30, 138, 44)),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Product description section
                      const Text(
                        "About this item",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 30, 138, 44),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product['description'] ??
                            "This is a premium quality item available for trade. The item is in good condition and ready for a new owner.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Trading information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 30, 138, 44).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 30, 138, 44).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Trading Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 30, 138, 44),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                                Icons.calendar_today, "Listed", "3 days ago"),
                            _buildInfoRow(Icons.visibility, "Views", "24"),
                            _buildInfoRow(
                                Icons.touch_app, "Interested", "5 people"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat button
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  final Uri whatsappUrl = Uri.parse("https://wa.me/918856875861");
                  launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Chat"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 30, 138, 44),
                  side: const BorderSide(color: Color.fromARGB(255, 30, 138, 44)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Make offer button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showTradeDialog(context);
                },
                icon: const Icon(Icons.handshake_outlined),
                label: const Text("Buy"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 138, 44),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color.fromARGB(255, 30, 138, 44)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}