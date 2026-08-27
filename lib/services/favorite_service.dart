import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // Favorites Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _favorites =>
      _firestore.collection('favorites');

  // ============================================================
  // Current User ID
  // ============================================================

  String? get _currentUserId =>
      _auth.currentUser?.uid;

  // ============================================================
  // Favorite Document Reference
  // ============================================================

  DocumentReference<Map<String, dynamic>>
  _favoriteReference({
    required String userId,
    required String productId,
  }) {
    return _favorites.doc(
      '${userId}_$productId',
    );
  }

  // ============================================================
  // Add To Favorites
  // ============================================================

  Future<void> addToFavorites(
      ProductModel product,
      ) async {
    final userId =
        _currentUserId;

    if (userId == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    final favoriteReference =
    _favoriteReference(
      userId: userId,
      productId: product.id,
    );

    await favoriteReference.set({
      'userId': userId,
      'productId': product.id,
      'productName': product.name,
      'productPrice': product.price,
      'productDescription':
      product.description,
      'productCategory':
      product.category,
      'productQuantity':
      product.quantity,
      'productImage':
      product.imageUrl,
      'createdAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Remove Favorite
  // ============================================================

  Future<void> removeFavorite(
      String productId,
      ) async {
    final userId =
        _currentUserId;

    if (userId == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    await _favoriteReference(
      userId: userId,
      productId: productId,
    ).delete();
  }

  // ============================================================
  // Check Favorite
  // ============================================================

  Future<bool> isFavorite(
      String productId,
      ) async {
    final userId =
        _currentUserId;

    if (userId == null) {
      return false;
    }

    final snapshot =
    await _favoriteReference(
      userId: userId,
      productId: productId,
    ).get();

    return snapshot.exists;
  }

  // ============================================================
  // Get Favorite Product IDs
  // ============================================================

  Stream<Set<String>>
  getFavoriteProductIds() {
    final userId =
        _currentUserId;

    if (userId == null) {
      return Stream.value({});
    }

    return _favorites
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (document) =>
          document.data()[
          'productId'
          ]?.toString() ??
              '',
        )
            .where(
              (id) => id.isNotEmpty,
        )
            .toSet();
      },
    );
  }

  // ============================================================
  // Get Favorites
  // ============================================================

  Stream<List<ProductModel>>
  getFavorites() {
    final userId =
        _currentUserId;

    if (userId == null) {
      return Stream.value([]);
    }

    return _favorites
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final favorites =
        snapshot.docs
            .map(
              (document) {
            final data =
            document.data();

            return ProductModel(
              id: data['productId']
                  ?.toString() ??
                  '',
              name: data['productName']
                  ?.toString() ??
                  '',
              price:
              _toDouble(
                data[
                'productPrice'],
              ),
              description:
              data['productDescription']
                  ?.toString() ??
                  '',
              category:
              data['productCategory']
                  ?.toString() ??
                  '',
              quantity:
              _toInt(
                data[
                'productQuantity'],
              ),
              imageUrl:
              data['productImage']
                  ?.toString() ??
                  '',
            );
          },
        )
            .toList();

        return favorites;
      },
    );
  }

  // ============================================================
  // Toggle Favorite
  // ============================================================

  Future<void> toggleFavorite(
      ProductModel product,
      ) async {
    final userId =
        _currentUserId;

    if (userId == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    final favoriteReference =
    _favoriteReference(
      userId: userId,
      productId: product.id,
    );

    final snapshot =
    await favoriteReference.get();

    if (snapshot.exists) {
      await favoriteReference.delete();
    } else {
      await addToFavorites(product);
    }
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