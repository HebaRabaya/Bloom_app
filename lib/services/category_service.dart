import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getCategories() {
    return _categories
        .orderBy('createdAt')
        .snapshots();
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