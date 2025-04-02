import 'package:flutter/material.dart';
import './services/firestore_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'product_details.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  int _currentBannerIndex = 0;

  // Banner facts about the app - colors updated to match auth page
  final List<Map<String, dynamic>> _bannerFacts = [
    {
      'title': 'Second Hand Sustainably',
      'subtitle': 'Join 10,000+ users reducing waste through trading',
      'color': const Color(0xFF6A1B9A),
      'icon': Icons.eco
    },
    {
      'title': 'Secure Transactions',
      'subtitle': 'Every trade is protected by our secure platform',
      'color': const Color(0xFF4527A0),
      'icon': Icons.security
    },
    {
      'title': 'Save Money',
      'subtitle': 'Users save ₹2,000 on average per month',
      'color': const Color(0xFF7B1FA2),
      'icon': Icons.savings
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      List<Map<String, dynamic>> items =
          await _firestoreService.fetchItemsWithUsers();

      // Add a small delay to show the loading state (for demo purposes)
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading items: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        color: const Color(0xFF6A1B9A),
        child: CustomScrollView(
          slivers: [
            // App Bar - Updated to match auth page
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF6A1B9A),
              title: const Text(
                "Thrifty",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Body Content
            SliverToBoxAdapter(
              child: _isLoading ? _buildLoadingUI() : _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      children: [
        // Loading banner
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 180,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Loading section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 24,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Loading grid items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBodyContent() {
    // If no items found
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Icon(Icons.inventory_2_outlined, 
                size: 80, 
                color: const Color(0xFF6A1B9A).withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No items available",
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF6A1B9A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Be the first to add an item!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                "Add Item",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Welcome message - added to match auth page style
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Welcome to Thrifty!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A1B9A),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Find great deals on pre-loved items",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        const SizedBox(height: 20),

        // Banner section with facts - updated with rounded corners
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildFactsBanner(),
        ),

        const SizedBox(height: 24),

        // Items grid title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Items",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: const Color(0xFF4527A0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Items grid - updated with more shadow and rounded corners
        _buildItemsGrid(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFactsBanner() {
    return Container(
      height: 180,
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 16 / 9,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {
              _currentBannerIndex = index;
            });
          },
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: _bannerFacts.map((fact) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fact['color'],
                      fact['color'].withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern (circles) - added to match auth page style
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            fact['icon'],
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fact['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fact['subtitle'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _items.length.clamp(0, 6), // Show up to 6 items in grid
        itemBuilder: (context, index) {
          final item = _items[index];
          final user = item['userDetails'] ?? {};

          return GestureDetector(
            onTap: () {
              // Navigate to product details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    product: {
                      'id': item['id'],
                      'name': item['item_name'] ?? "No Name",
                      'image': item['image'] ?? "",
                      'price': item['original_cost'] ?? "0",
                      'user': user['name'] ?? "Unknown",
                      'userId': item['user'],
                      'description': item['description'],
                      'location': user['city'] ?? "No Location",
                    },
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: item['image'] != null
                        ? Image.network(
                            item['image'],
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 130,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          )
                        : Container(
                            height: 130,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, 
                                color: const Color(0xFF6A1B9A).withOpacity(0.3),
                                size: 40),
                          ),
                  ),
                  // Item details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['item_name'] ?? "No Name",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${item['original_cost'] ?? '0'}",
                          style: const TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user['city'] ?? "Unknown location",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}