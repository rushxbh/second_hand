import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_page.dart';
import 'services/chat_service.dart';

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
          const SnackBar(
            content: Text('Buy request sent!'),
            backgroundColor: Color(0xFF6A1B9A),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops! Request not Sent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    Future<void> _showTradeDialog(BuildContext context) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Place your Offer',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the amount you want to offer:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF6A1B9A)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
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
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Submit Offer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom app bar with image carousel
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_border, color: Color(0xFF6A1B9A)),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.share, color: Color(0xFF6A1B9A)),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: product['id'] ?? 'product-image',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: product['image'] != null && product['image'].isNotEmpty
                            ? Image.network(
                                product['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      size: 100, color: Colors.grey),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image,
                                    size: 100, color: Colors.grey),
                              ),
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                      // Price badge
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6A1B9A).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            "₹${product['price']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product title and category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product['category'] ?? "Category",
                            style: const TextStyle(
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "4.7",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              " (42 reviews)",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Product name
                    Text(
                      product['name'] ?? "Unknown Product",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Seller Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Seller avatar
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFF6A1B9A).withOpacity(0.1),
                            child: Text(
                              (product['user'] ?? "U")[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF6A1B9A),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
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
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product['location'] ?? "Unknown location",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Chat button
                          InkWell(
                            onTap: () async {
                              // First, make sure we have a valid user ID
                              final sellerId = product['userId'];
                              if (sellerId == null || sellerId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cannot start chat: Seller information is missing'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Create a chat room
                              final chatService = ChatService();
                              try {
                                // Create or get the chat room ID
                                final chatRoomId = await chatService.createChatRoom(sellerId);

                                // Make sure chatRoomId is not empty
                                if (chatRoomId.isEmpty) {
                                  throw Exception("Failed to create chat room");
                                }
                                
                                // Navigate to ChatPage directly
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      chatRoomId: chatRoomId,
                                      otherUserId: sellerId,
                                      otherUserName: product['user'] ?? 'User',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print('Chat error: $e'); // Print to console for debugging
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error starting chat: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Product description section
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['description'] ??
                          "This is a premium quality item available for trade. The item is in good condition and ready for a new owner.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Features section
                    const Text(
                      "Highlights",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Feature pills
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFeaturePill("Certified Genuine"),
                        _buildFeaturePill("Top Quality"),
                        _buildFeaturePill("Free Delivery"),
                        _buildFeaturePill("7-day Returns"),
                      ],
                    ),

                    const SizedBox(height: 24),
                    
                    // Trading information in a nicer format
                    const Text(
                      "Listing Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRowNew(Icons.calendar_today, "Listed", "3 days ago"),
                          const Divider(height: 24),
                          _buildInfoRowNew(Icons.visibility, "Views", "24"),
                          const Divider(height: 24),
                          _buildInfoRowNew(Icons.favorite, "Interested", "5 people"),
                          const Divider(height: 24),
                          _buildInfoRowNew(Icons.local_shipping_outlined, "Shipping", "Free Delivery"),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 80), // Extra space for button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom bar with buy button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF6A1B9A)),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_outlined, color: Color(0xFF6A1B9A)),
                onPressed: () async {
                  // First, make sure we have a valid user ID
                  final sellerId = product['userId'];
                  if (sellerId == null || sellerId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot start chat: Seller information is missing'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create a chat room
                  final chatService = ChatService();
                  try {
                    // Create or get the chat room ID
                    final chatRoomId = await chatService.createChatRoom(sellerId);

                    // Make sure chatRoomId is not empty
                    if (chatRoomId.isEmpty) {
                      throw Exception("Failed to create chat room");
                    }
                    
                    // Navigate to ChatPage directly
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatRoomId: chatRoomId,
                          otherUserId: sellerId,
                          otherUserName: product['user'] ?? 'User',
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Chat error: $e'); // Print to console for debugging
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error starting chat: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            // Buy button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showTradeDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6A1B9A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRowNew(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF616161),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  // Deprecated - kept for reference
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A1B9A)),
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