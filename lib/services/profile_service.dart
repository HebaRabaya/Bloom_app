// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class ProfileService {
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;
//
//   final FirebaseStorage _storage =
//       FirebaseStorage.instance;
//
//   // ============================================================
//   // حفظ بيانات البروفايل
//   // ============================================================
//
//   Future<void> saveProfile({
//     required String uid,
//     required String name,
//     required String age,
//     required String phone,
//     required String bio,
//     String? imageUrl,
//   }) async {
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .set(
//       {
//         'name': name,
//         'age': age,
//         'phone': phone,
//         'bio': bio,
//         'imageUrl': imageUrl ?? '',
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );
//   }
//
//   // ============================================================
//   // جلب بيانات البروفايل
//   // ============================================================
//
//   Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(
//       String uid,
//       ) async {
//     return await _firestore
//         .collection('users')
//         .doc(uid)
//         .get();
//   }
//
//   // ============================================================
//   // رفع صورة البروفايل إلى Firebase Storage
//   // ============================================================
//
//   Future<String> uploadProfileImage({
//     required String uid,
//     required File imageFile,
//   }) async {
//     final storageRef = _storage
//         .ref()
//         .child('profile_images')
//         .child('$uid.jpg');
//
//     await storageRef.putFile(imageFile);
//
//     final downloadUrl =
//     await storageRef.getDownloadURL();
//
//     return downloadUrl;
//   }
// }


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloudinary_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CloudinaryService _cloudinaryService =
  CloudinaryService();

  // ============================================================
  // Save Profile
  // ============================================================

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String age,
    required String phone,
    required String bio,
    String? imageUrl,
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
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // Get Profile
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
  getProfile(
      String uid,
      ) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .get();
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