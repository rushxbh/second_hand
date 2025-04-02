import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YourRequestsPage extends StatefulWidget {
  const YourRequestsPage({Key? key}) : super(key: key);

  @override
  State<YourRequestsPage> createState() => _YourRequestsPageState();
}

class _YourRequestsPageState extends State<YourRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incoming Requests'),
              Tab(text: 'Outgoing Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(incoming: true),
            _buildRequestsList(incoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList({required bool incoming}) {
    String userId = _auth.currentUser?.uid ?? '';
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('trade_requests')
          .where(incoming ? 'receiverId' : 'senderId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Text('No ${incoming ? 'incoming' : 'outgoing'} requests'),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            
            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait([
                _firestore.collection('items').doc(request['offeredItemId']).get(),
                _firestore.collection('items').doc(request['requestedItemId']).get(),
                _firestore.collection('users').doc(incoming ? request['senderId'] : request['receiverId']).get(),
              ]),
              builder: (context, snapshots) {
                if (!snapshots.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final offeredItem = snapshots.data![0].data() as Map<String, dynamic>;
                final requestedItem = snapshots.data![1].data() as Map<String, dynamic>;
                final otherUser = snapshots.data![2].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1E3A8A),
                              child: Text(
                                (otherUser['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otherUser['name'] ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    otherUser['city'] ?? 'Unknown Location',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                request['status'] ?? 'Pending',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildItemCard(
                                title: incoming ? 'Offered Item' : 'Your Item',
                                item: offeredItem,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.swap_horiz),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildItemCard(
                                title: incoming ? 'Your Item' : 'Requested Item',
                                item: requestedItem,
                              ),
                            ),
                          ],
                        ),
                        if (incoming && request['status'] == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _updateRequestStatus(
                                    requests[index].id,
                                    'rejected',
                                  ),
                                  child: const Text('Decline'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _updateRequestStatus(
                                    requests[index].id,
                                    'accepted',
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard({required String title, required Map<String, dynamic> item}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  item['image'] ?? '',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item_name'] ?? 'Unknown Item',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${item['original_cost'] ?? 0}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('trade_requests').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}