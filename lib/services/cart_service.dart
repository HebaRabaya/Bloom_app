import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // Current User ID
  // ============================================================

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // User Cart Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _cart {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

  // ============================================================
  // Get Cart
  // ============================================================

  Stream<List<CartModel>> getCart() {
    return _cart.snapshots().map(
          (snapshot) {
        return snapshot.docs.map(
              (document) {
            return CartModel.fromMap(
              document.data(),
            );
          },
        ).toList();
      },
    );
  }

  // ============================================================
  // Add Product To Cart
  // ============================================================

  Future<void> addToCart({
    required String productId,
  }) async {
    final productReference =
    _firestore
        .collection('products')
        .doc(productId);

    final cartReference =
    _cart.doc(productId);

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
            'Product not found.',
          );
        }

        // ------------------------------------------------------
        // Available Product Quantity
        // ------------------------------------------------------

        final availableQuantity =
            (productData['quantity'] as num?)
                ?.toInt() ??
                0;

        if (availableQuantity <= 0) {
          throw Exception(
            'Out of stock.',
          );
        }

        // ------------------------------------------------------
        // Read Current Cart Item
        // ------------------------------------------------------

        final cartSnapshot =
        await transaction.get(
          cartReference,
        );

        int currentCartQuantity = 0;

        if (cartSnapshot.exists) {
          final cartData =
          cartSnapshot.data();

          currentCartQuantity =
              (cartData?['quantity'] as num?)
                  ?.toInt() ??
                  0;
        }

        // ------------------------------------------------------
        // Check Maximum Quantity
        // ------------------------------------------------------

        if (currentCartQuantity + 1 >
            availableQuantity) {
          throw Exception(
            'Maximum available quantity reached.',
          );
        }

        // ------------------------------------------------------
        // Save Product In Cart
        // ------------------------------------------------------

        transaction.set(
          cartReference,
          {
            'productId': productId,

            'productName':
            productData['name'] ?? '',

            'productPrice':
            (productData['price'] as num?)
                ?.toDouble() ??
                0.0,

            'productImage':
            productData['imageUrl'] ?? '',

            // كمية المنتج داخل السلة
            'quantity':
            currentCartQuantity + 1,

            // كمية المخزون الأصلي
            'availableQuantity':
            availableQuantity,

            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ============================================================
  // Increase Quantity
  // ============================================================

  Future<void> increaseQuantity(
      CartModel item,
      ) async {
    final cartReference =
    _cart.doc(item.productId);

    final productReference =
    _firestore
        .collection('products')
        .doc(item.productId);

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
            'Product not found.',
          );
        }

        final availableQuantity =
            (productData['quantity'] as num?)
                ?.toInt() ??
                0;

        // ------------------------------------------------------
        // Read Current Cart Item
        // ------------------------------------------------------

        final cartSnapshot =
        await transaction.get(
          cartReference,
        );

        if (!cartSnapshot.exists) {
          throw Exception(
            'Cart item not found.',
          );
        }

        final cartData =
        cartSnapshot.data();

        final currentCartQuantity =
            (cartData?['quantity'] as num?)
                ?.toInt() ??
                0;

        // ------------------------------------------------------
        // Check Maximum Stock
        // ------------------------------------------------------

        if (currentCartQuantity + 1 >
            availableQuantity) {
          throw Exception(
            'Maximum available quantity reached.',
          );
        }

        // ------------------------------------------------------
        // Update Cart Quantity
        // ------------------------------------------------------

        transaction.update(
          cartReference,
          {
            'quantity':
            currentCartQuantity + 1,

            'availableQuantity':
            availableQuantity,

            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ============================================================
  // Decrease Quantity
  // ============================================================

  Future<void> decreaseQuantity(
      CartModel item,
      ) async {
    final cartReference =
    _cart.doc(item.productId);

    await _firestore.runTransaction(
          (transaction) async {
        // ------------------------------------------------------
        // Read Current Cart Item
        // ------------------------------------------------------

        final cartSnapshot =
        await transaction.get(
          cartReference,
        );

        if (!cartSnapshot.exists) {
          return;
        }

        final cartData =
        cartSnapshot.data();

        final currentQuantity =
            (cartData?['quantity'] as num?)
                ?.toInt() ??
                1;

        // ------------------------------------------------------
        // If Quantity Is 1 → Remove From Cart
        // ------------------------------------------------------

        if (currentQuantity <= 1) {
          transaction.delete(
            cartReference,
          );

          return;
        }

        // ------------------------------------------------------
        // Decrease Quantity
        // ------------------------------------------------------

        transaction.update(
          cartReference,
          {
            'quantity':
            currentQuantity - 1,

            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ============================================================
  // Remove Product From Cart
  // ============================================================

  Future<void> removeFromCart(
      String productId,
      ) async {
    await _cart
        .doc(productId)
        .delete();
  }

  // ============================================================
  // Clear Cart After Checkout
  // ============================================================
  // بعد نجاح الطلب، بنمسح كل المنتجات الموجودة
  // داخل سلة المستخدم.
  // ============================================================

  Future<void> clearCart() async {
    final snapshot =
    await _cart.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch =
    _firestore.batch();

    for (final document
    in snapshot.docs) {
      batch.delete(
        document.reference,
      );
    }

    await batch.commit();
  }
}