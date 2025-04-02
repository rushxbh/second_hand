    import 'package:url_launcher/url_launcher.dart';
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
              Tab(text: 'Incoming Offers'),
              Tab(text: 'Outgoing Offers'),
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

void _makeUPIPayment({required String upiId, required String amount}) async {
  String url = "upi://pay?pa=$upiId&pn=Seller&mc=&tid=&tr=&tn=Trade%20Payment&am=$amount&cu=INR";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch UPI payment';
  }
}

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
        print(requests);
        if (requests.isEmpty) {
          return Center(
            child: Text('No ${incoming ? 'incoming' : 'outgoing'} offers'),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            print(request);
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore
                  .collection('items')
                  .doc(request['requestedItemId'])
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final requestedItem =
                    snapshot.data!.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Offered Price: ₹${request['offeredItemId']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                        _buildItemCard(item: requestedItem),
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
                        if (!incoming && request['status'] == 'accepted')
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _makeUPIPayment(
                                    upiId:
                                        "example@upi", // Replace with your UPI ID
                                    amount: request['offeredAmount'] ??
                                        '0', // Use actual amount
                                  ),
                                  child: const Text('Pay'),
                                ),
                              ],
                            ),
                          )
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

  Widget _buildItemCard({required Map<String, dynamic> item}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  item['image'] ?? '',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
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
