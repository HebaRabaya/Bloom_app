import 'package:bloom_app/services/cart_service.dart';
import 'package:bloom_app/services/order_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class FakeBackend {
  FakeBackend({bool signedIn = true}) {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      signedIn: signedIn,
      mockUser: MockUser(
        uid: uid,
        email: 'bloom@test.com',
        displayName: 'Bloom User',
      ),
    );
  }

  static const uid = 'user-1';

  late final FakeFirebaseFirestore firestore;
  late final MockFirebaseAuth auth;

  CartService get cart => CartService(firestore: firestore, auth: auth);

  OrderService get orders => OrderService(firestore: firestore, auth: auth);

  Future<void> seedUser({
    String name = 'Bloom User',
    String phone = '0590000000',
  }) {
    return firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'role': 'user',
      'email': 'bloom@test.com',
    });
  }

  Future<void> seedProduct({
    required String id,
    String name = 'Rose Bouquet',
    double price = 40,
    int quantity = 5,
    String imageUrl = 'https://example.com/rose.png',
  }) {
    return firestore.collection('products').doc(id).set({
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'description': 'Test product',
      'category': 'Bouquets',
    });
  }

  Future<void> seedCartItem({
    required String productId,
    String productName = 'Rose Bouquet',
    double productPrice = 40,
    int quantity = 1,
    int availableQuantity = 5,
    String productImage = 'https://example.com/rose.png',
  }) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .set({
          'productId': productId,
          'productName': productName,
          'productPrice': productPrice,
          'productImage': productImage,
          'quantity': quantity,
          'availableQuantity': availableQuantity,
        });
  }

  Future<Map<String, dynamic>?> product(String id) async {
    final snapshot = await firestore.collection('products').doc(id).get();
    return snapshot.data();
  }

  Future<Map<String, dynamic>?> cartItem(String productId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .get();
    return snapshot.data();
  }

  Future<int> cartCount() async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    return snapshot.docs.length;
  }

  Future<Map<String, dynamic>?> order(String id) async {
    final snapshot = await firestore.collection('orders').doc(id).get();
    return snapshot.data();
  }
}
