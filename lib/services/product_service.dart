import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import 'cloudinary_service.dart';

class ProductService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CloudinaryService _cloudinaryService =
  CloudinaryService();

  // ============================================================
  // Products Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _products =>
      _firestore.collection('products');

  // ============================================================
  // Add Product
  // ============================================================

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required int quantity,
    required File imageFile,
  }) async {
    // ----------------------------------------------------------
    // إنشاء ID للمنتج أولاً
    // ----------------------------------------------------------

    final document =
    _products.doc();

    // ----------------------------------------------------------
    // رفع الصورة إلى Cloudinary
    // ----------------------------------------------------------

    final imageUrl =
    await _cloudinaryService.uploadImage(
      imageFile: imageFile,
      folder: 'bloom_products',
      publicId: 'product_${document.id}',
    );

    // ----------------------------------------------------------
    // حفظ بيانات المنتج في Firestore
    // ----------------------------------------------------------

    await document.set({
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,

      'createdAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Get Products Stream
  // ============================================================

  Stream<List<ProductModel>>
  getProducts() {
    return _products
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs
              .map(
                (document) =>
                ProductModel.fromMap(
                  document.id,
                  document.data(),
                ),
          )
              .toList(),
    );
  }

  // ============================================================
  // Update Product
  // ============================================================

  Future<void> updateProduct({
    required ProductModel product,
    required String name,
    required double price,
    required String description,
    required String category,
    required int quantity,
    File? newImageFile,
  }) async {
    String imageUrl =
        product.imageUrl;

    // ----------------------------------------------------------
    // إذا اختار صورة جديدة
    // ----------------------------------------------------------

    if (newImageFile != null) {
      imageUrl =
      await _cloudinaryService.uploadImage(
        imageFile: newImageFile,
        folder: 'bloom_products',
        publicId: 'product_${product.id}',
      );
    }

    // ----------------------------------------------------------
    // Update Firestore
    // ----------------------------------------------------------

    await _products
        .doc(product.id)
        .update({
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Delete Product
  // ============================================================

  Future<void> deleteProduct(
      String productId,
      ) async {
    await _products
        .doc(productId)
        .delete();
  }
}