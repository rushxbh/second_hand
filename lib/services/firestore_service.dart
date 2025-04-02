import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchItemsWithUsers() async {
  try {
    QuerySnapshot itemsSnapshot = await _db.collection('items').get();
    List<Map<String, dynamic>> itemList = [];

    for (var itemDoc in itemsSnapshot.docs) {
      Map<String, dynamic> itemData = {
        'id': itemDoc.id, // ✅ Include document ID
        ...itemDoc.data() as Map<String, dynamic>,
      };
      print(itemData);

      // Fetch user details
      if (itemData['user'] != null) {
        DocumentSnapshot userDoc =
            await _db.collection('users').doc(itemData['user']).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          itemData['userDetails'] = {
            'name': userData['name'],
            'email': userData['email'],
            'city': userData['city']
          };
        }
      }
      itemList.add(itemData);
    }
    return itemList;
  } catch (e) {
    print("Error fetching items: $e");
    return [];
  }
}
  Future<List<Map<String, dynamic>>> fetchItems() async {
  try {
    QuerySnapshot itemsSnapshot = await _db.collection('items').get();
    List<Map<String, dynamic>> itemList = [];

    for (var itemDoc in itemsSnapshot.docs) {
      Map<String, dynamic> itemData = {
        'id': itemDoc.id, // ✅ Include document ID
        ...itemDoc.data() as Map<String, dynamic>,
      };
      print(itemData);

      // Fetch user details
      if (itemData['user'] != null) {
        DocumentSnapshot userDoc =
            await _db.collection('users').doc(itemData['user']).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          itemData['userDetails'] = {
            'name': userData['name'],
            'email': userData['email'],
            'city': userData['city']
          };
        }
      }
      itemList.add(itemData);
    }
    return itemList;
  } catch (e) {
    print("Error fetching items: $e");
    return [];
  }
}

}
