import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // Orders Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _orders =>
      _firestore.collection('orders');

  // ============================================================
  // Products Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _products =>
      _firestore.collection('products');

  // ============================================================
  // Create Order + Decrease Product Quantity
  // ============================================================

  Future<void> createOrder({
    required String productId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    final productReference =
    _products.doc(productId);

    final orderReference =
    _orders.doc();

    final userReference =
    _firestore
        .collection('users')
        .doc(user.uid);

    // ==========================================================
    // Transaction
    // ==========================================================

    await _firestore.runTransaction(
          (transaction) async {
        // ------------------------------------------------------
        // Read Product
        // ------------------------------------------------------

        final productSnapshot =
        await transaction.get(
          productReference,
        );

        if (!productSnapshot.exists) {
          throw Exception(
            'Product not found.',
          );
        }

        final productData =
        productSnapshot.data();

        if (productData == null) {
          throw Exception(
            'Product data not found.',
          );
        }

        // ------------------------------------------------------
        // Check Quantity
        // ------------------------------------------------------

        final quantity =
        _toInt(
          productData['quantity'],
        );

        if (quantity <= 0) {
          throw Exception(
            'This product is out of stock.',
          );
        }

        // ------------------------------------------------------
        // Read User Profile
        // ------------------------------------------------------

        final userSnapshot =
        await transaction.get(
          userReference,
        );

        final userData =
        userSnapshot.data();

        final userName =
            userData?['name']
                ?.toString()
                ?? user.displayName
                ?? 'Bloom User';

        final userPhone =
            userData?['phone']
                ?.toString()
                ?? '';

        // ------------------------------------------------------
        // Product Data
        // ------------------------------------------------------

        final productName =
            productData['name']
                ?.toString()
                ?? '';

        final productImage =
            productData['imageUrl']
                ?.toString()
                ?? '';

        final productPrice =
        _toDouble(
          productData['price'],
        );

        // ------------------------------------------------------
        // Decrease Quantity
        // ------------------------------------------------------

        transaction.update(
          productReference,
          {
            'quantity': quantity - 1,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );

        // ------------------------------------------------------
        // Create Order
        // ------------------------------------------------------

        transaction.set(
          orderReference,
          {
            'productId': productId,
            'productName': productName,
            'productImage': productImage,
            'productPrice': productPrice,
            'userId': user.uid,
            'userName': userName,
            'userPhone': userPhone,
            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ============================================================
  // Get Current User Orders
  // ============================================================

  Stream<List<OrderModel>> getMyOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _orders
        .where(
      'userId',
      isEqualTo: user.uid,
    )
        .snapshots()
        .map(
          (snapshot) {
        final orders =
        snapshot.docs
            .map(
              (document) =>
              OrderModel.fromMap(
                document.id,
                document.data(),
              ),
        )
            .toList();

        // Sort locally instead of using
        // Firestore where + orderBy.
        orders.sort(
              (a, b) {
            final aDate =
                a.createdAt;

            final bDate =
                b.createdAt;

            if (aDate == null &&
                bDate == null) {
              return 0;
            }

            if (aDate == null) {
              return 1;
            }

            if (bDate == null) {
              return -1;
            }

            return bDate.compareTo(
              aDate,
            );
          },
        );

        return orders;
      },
    );
  }

  // ============================================================
  // Get All Orders
  // ============================================================

  Stream<List<OrderModel>> getAllOrders() {
    return _orders
        .snapshots()
        .map(
          (snapshot) {
        final orders =
        snapshot.docs
            .map(
              (document) =>
              OrderModel.fromMap(
                document.id,
                document.data(),
              ),
        )
            .toList();

        orders.sort(
              (a, b) {
            final aDate =
                a.createdAt;

            final bDate =
                b.createdAt;

            if (aDate == null &&
                bDate == null) {
              return 0;
            }

            if (aDate == null) {
              return 1;
            }

            if (bDate == null) {
              return -1;
            }

            return bDate.compareTo(
              aDate,
            );
          },
        );

        return orders;
      },
    );
  }

  // ============================================================
  // Cancel Order By User
  // ============================================================

  Future<void> cancelOrder({
    required OrderModel order,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    // User can cancel only his own order.
    if (order.userId != user.uid) {
      throw Exception(
        'You cannot cancel this order.',
      );
    }

    await _cancelOrderTransaction(
      order: order,
    );
  }

  // ============================================================
  // Cancel Order By Admin
  // ============================================================

  Future<void> cancelOrderByAdmin({
    required OrderModel order,
  }) async {
    await _cancelOrderTransaction(
      order: order,
    );
  }

  // ============================================================
  // Shared Cancel Transaction
  // ============================================================

  Future<void> _cancelOrderTransaction({
    required OrderModel order,
  }) async {
    final orderReference =
    _orders.doc(order.id);

    await _firestore.runTransaction(
          (transaction) async {
        // ------------------------------------------------------
        // Read Order
        // ------------------------------------------------------

        final orderSnapshot =
        await transaction.get(
          orderReference,
        );

        if (!orderSnapshot.exists) {
          throw Exception(
            'Order not found.',
          );
        }

        final orderData =
        orderSnapshot.data();

        if (orderData == null) {
          throw Exception(
            'Order data not found.',
          );
        }

        // ------------------------------------------------------
        // Product ID
        // ------------------------------------------------------

        final productId =
        orderData['productId']
            ?.toString();

        if (productId == null ||
            productId.isEmpty) {
          throw Exception(
            'Product ID not found.',
          );
        }

        final productReference =
        _products.doc(productId);

        // ------------------------------------------------------
        // Read Product
        // ------------------------------------------------------

        final productSnapshot =
        await transaction.get(
          productReference,
        );

        if (!productSnapshot.exists) {
          throw Exception(
            'Product not found.',
          );
        }

        final productData =
        productSnapshot.data();

        final currentQuantity =
        _toInt(
          productData?['quantity'],
        );

        // ------------------------------------------------------
        // Return Product To Stock
        // ------------------------------------------------------

        transaction.update(
          productReference,
          {
            'quantity':
            currentQuantity + 1,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );

        // ------------------------------------------------------
        // Delete Order
        // ------------------------------------------------------

        transaction.delete(
          orderReference,
        );
      },
    );
  }

  // ============================================================
  // Convert To Double
  // ============================================================

  double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  // ============================================================
  // Convert To Int
  // ============================================================

  int _toInt(
      dynamic value,
      ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}