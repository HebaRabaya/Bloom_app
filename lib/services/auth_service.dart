import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // إنشاء حساب جديد
  // ============================================================

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // ----------------------------------------------------------
    // 1. إنشاء الحساب داخل Firebase Authentication
    // ----------------------------------------------------------

    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      // --------------------------------------------------------
      // 2. حفظ الاسم داخل Firebase Authentication
      // --------------------------------------------------------

      await user.updateDisplayName(name);

      // --------------------------------------------------------
      // 3. إنشاء Document داخل Firestore
      // --------------------------------------------------------

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name,
        'email': email,
        'role': role,

        // حقول البروفايل
        'age': '',
        'phone': '',
        'bio': '',
        'imageUrl': '',

        'createdAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  // ============================================================
  // تسجيل الدخول
  // ============================================================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // الحصول على Role للمستخدم الحالي
  // ============================================================

  Future<String> getUserRole(
      String uid,
      ) async {
    final document =
    await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return 'user';
    }

    final data = document.data();

    return data?['role']?.toString() ??
        'user';
  }

  // ============================================================
  // إرسال رابط إعادة تعيين كلمة المرور
  // ============================================================

  Future<void> sendPasswordReset({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // ============================================================
  // تسجيل الخروج
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // المستخدم الحالي
  // ============================================================

  User? get currentUser =>
      _auth.currentUser;
}