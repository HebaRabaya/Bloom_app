import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  CategoryService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // Categories Collection
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _categories =>
      _firestore.collection('categories');

  // ============================================================
  // Add Category
  // ============================================================

  Future<void> addCategory(
      String name,
      ) async {
    await _categories.add({
      'name': name,
      'createdAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Get Categories
  // ============================================================

  Stream<List<CategoryModel>> getCategories() {
    return _categories
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CategoryModel.fromMap(
                  document.id,
                  document.data(),
                ),
              )
              .toList(),
        );
  }

  // ============================================================
  // Delete Category
  // ============================================================

  Future<void> deleteCategory(
      String categoryId,
      ) async {
    await _categories
        .doc(categoryId)
        .delete();
  }
}
