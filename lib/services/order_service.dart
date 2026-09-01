import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_model.dart';
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
  // User Cart Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  _userCart(
      String uid,
      ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  // ============================================================
  // Checkout
  // ============================================================

  Future<void> checkout({
    required String address,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    if (address.trim().isEmpty) {
      throw Exception(
        'Please enter your delivery address.',
      );
    }

    final uid = user.uid;

    final userReference =
    _firestore
        .collection('users')
        .doc(uid);

    final cartCollection =
    _userCart(uid);

    final orderReference =
    _orders.doc();

    // ==========================================================
    // READ CART
    // ==========================================================

    final cartSnapshot =
    await cartCollection.get();

    if (cartSnapshot.docs.isEmpty) {
      throw Exception(
        'Your cart is empty.',
      );
    }

    final cartItems =
    cartSnapshot.docs.map(
          (document) {
        return CartModel.fromMap(
          document.data(),
        );
      },
    ).toList();

    // ==========================================================
    // TRANSACTION
    // ==========================================================

    await _firestore.runTransaction(
          (transaction) async {
        // ======================================================
        // READ USER
        // ======================================================

        final userSnapshot =
        await transaction.get(
          userReference,
        );

        final userData =
        userSnapshot.data();

        final userName =
            userData?['name']
                ?.toString() ??
                user.displayName ??
                'Bloom User';

        final userPhone =
            userData?['phone']
                ?.toString() ??
                '';

        // ======================================================
        // READ PRODUCTS
        // ======================================================

        final Map<
            String,
            DocumentSnapshot<
                Map<String, dynamic>>>
        productSnapshots = {};

        for (final cartItem in cartItems) {
          final productReference =
          _products.doc(
            cartItem.productId,
          );

          final productSnapshot =
          await transaction.get(
            productReference,
          );

          if (!productSnapshot.exists) {
            throw Exception(
              '${cartItem.productName} is no longer available.',
            );
          }

          productSnapshots[
          cartItem.productId] =
              productSnapshot;
        }

        // ======================================================
        // PREPARE ORDER ITEMS
        // ======================================================

        final List<OrderItemModel>
        orderItems = [];

        double totalAmount = 0;

        // ======================================================
        // VALIDATE STOCK
        // ======================================================

        for (final cartItem in cartItems) {
          final productSnapshot =
          productSnapshots[
          cartItem.productId];

          if (productSnapshot ==
              null ||
              !productSnapshot.exists) {
            throw Exception(
              '${cartItem.productName} is no longer available.',
            );
          }

          final productData =
          productSnapshot.data();

          if (productData == null) {
            throw Exception(
              'Product data not found.',
            );
          }

          final currentStock =
          _toInt(
            productData['quantity'],
          );

          if (cartItem.quantity <= 0) {
            throw Exception(
              'Invalid quantity for ${cartItem.productName}.',
            );
          }

          if (currentStock <
              cartItem.quantity) {
            throw Exception(
              'Not enough stock for ${cartItem.productName}. Available: $currentStock',
            );
          }

          final productName =
              productData['name']
                  ?.toString() ??
                  cartItem.productName;

          final productImage =
              productData['imageUrl']
                  ?.toString() ??
                  cartItem.productImage;

          final productPrice =
          _toDouble(
            productData['price'],
          );

          orderItems.add(
            OrderItemModel(
              productId:
              cartItem.productId,
              productName:
              productName,
              productImage:
              productImage,
              productPrice:
              productPrice,
              quantity:
              cartItem.quantity,
            ),
          );

          totalAmount +=
              productPrice *
                  cartItem.quantity;
        }

        // ======================================================
        // CREATE ORDER
        // ======================================================

        transaction.set(
          orderReference,
          {
            'userId': uid,
            'userName': userName,
            'userPhone': userPhone,
            'address':
            address.trim(),

            'items': orderItems
                .map(
                  (item) =>
                  item.toMap(),
            )
                .toList(),

            'totalAmount':
            totalAmount,

            'createdAt':
            FieldValue
                .serverTimestamp(),

            'status':
            'Pending',
          },
        );

        // ======================================================
        // DECREASE STOCK
        // ======================================================

        for (final cartItem
        in cartItems) {
          final productSnapshot =
          productSnapshots[
          cartItem.productId];

          if (productSnapshot ==
              null ||
              !productSnapshot.exists) {
            continue;
          }

          final productData =
          productSnapshot.data();

          final currentStock =
          _toInt(
            productData?['quantity'],
          );

          final newStock =
              currentStock -
                  cartItem.quantity;

          transaction.update(
            productSnapshot.reference,
            {
              'quantity':
              newStock,
              'updatedAt':
              FieldValue
                  .serverTimestamp(),
            },
          );
        }

        // ======================================================
        // CLEAR CART
        // ======================================================

        for (final document
        in cartSnapshot.docs) {
          transaction.delete(
            document.reference,
          );
        }
      },
    );
  }

  // ============================================================
  // Get Current User Orders
  // ============================================================

  Stream<List<OrderModel>>
  getMyOrders() {
    final user =
        _auth.currentUser;

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
              (document) {
            return OrderModel.fromMap(
              document.id,
              document.data(),
            );
          },
        ).toList();

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

  Stream<List<OrderModel>>
  getAllOrders() {
    return _orders
        .snapshots()
        .map(
          (snapshot) {
        final orders =
        snapshot.docs
            .map(
              (document) {
            return OrderModel.fromMap(
              document.id,
              document.data(),
            );
          },
        ).toList();

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
  // Update Order Status By Admin
  // ============================================================

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (orderId.trim().isEmpty) {
      throw Exception(
        'Order ID is empty.',
      );
    }

    await _orders
        .doc(orderId)
        .update({
      'status': status,
      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Cancel Order By User
  // ============================================================

  Future<void> cancelOrder({
    required OrderModel order,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    if (order.userId !=
        user.uid) {
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
        // ======================================================
        // READ ORDER
        // ======================================================

        final orderSnapshot =
        await transaction.get(
          orderReference,
        );

        if (!orderSnapshot.exists) {
          throw Exception(
            'Order not found.',
          );
        }

        // ======================================================
        // READ PRODUCTS
        // ======================================================

        final productSnapshots =
        <
            String,
            DocumentSnapshot<
                Map<String, dynamic>>>{
        };

        for (final item
        in order.items) {
          final productReference =
          _products.doc(
            item.productId,
          );

          final productSnapshot =
          await transaction.get(
            productReference,
          );

          productSnapshots[
          item.productId] =
              productSnapshot;
        }

        // ======================================================
        // RETURN QUANTITIES
        // ======================================================

        for (final item
        in order.items) {
          final productSnapshot =
          productSnapshots[
          item.productId];

          if (productSnapshot ==
              null ||
              !productSnapshot.exists) {
            continue;
          }

          final productData =
          productSnapshot.data();

          final currentQuantity =
          _toInt(
            productData?['quantity'],
          );

          transaction.update(
            productSnapshot.reference,
            {
              'quantity':
              currentQuantity +
                  item.quantity,
              'updatedAt':
              FieldValue
                  .serverTimestamp(),
            },
          );
        }

        // ======================================================
        // DELETE ORDER
        // ======================================================

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