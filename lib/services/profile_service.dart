import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'cloudinary_service.dart';

class ProfileService {
  ProfileService({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cloudinaryService = cloudinaryService ?? CloudinaryService();

  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  // ============================================================
  // Save Profile
  // ============================================================
  // حفظ بيانات البروفايل داخل users/{uid}
  // ============================================================

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String age,
    required String phone,
    required String bio,
    String? imageUrl,
    String? address,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'name': name,
        'age': age,
        'phone': phone,
        'bio': bio,
        'imageUrl': imageUrl ?? '',

        // ======================================================
        // Delivery Address
        // ======================================================

        'address': address ?? '',

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // Save Address
  // ============================================================
  // نستخدمها من Checkout لتخزين عنوان التوصيل.
  // ============================================================

  Future<void> saveAddress({
    required String uid,
    required String address,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'address': address,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // Get Profile
  // ============================================================

  Future<UserModel?> getProfile(
      String uid,
      ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return UserModel.fromMap(uid, data);
  }

  // ============================================================
  // Watch Profile
  // ============================================================
  // بنستخدمها بشاشة البروفايل حتى أي تعديل يظهر مباشرة.
  // ============================================================

  Stream<UserModel?> watchProfile(
      String uid,
      ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      return UserModel.fromMap(uid, data);
    });
  }

  // ============================================================
  // Upload Profile Image
  // ============================================================

  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    return await _cloudinaryService.uploadImage(
      imageFile: imageFile,

      // فولدر خاص بصور البروفايل
      folder: 'bloom_profile_images',

      // اسم ثابت للصورة
      publicId: 'profile_$uid',
    );
  }
}
