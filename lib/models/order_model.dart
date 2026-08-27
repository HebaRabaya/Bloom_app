import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;

  // ============================================================
  // Product Info
  // ============================================================

  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;

  // ============================================================
  // User Info
  // ============================================================

  final String userId;
  final String userName;
  final String userPhone;

  // ============================================================
  // Order Info
  // ============================================================

  final Timestamp? createdAt;

  OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
  });

  // ============================================================
  // From Firestore
  // ============================================================

  factory OrderModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return OrderModel(
      id: id,

      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',

      productPrice: (map['productPrice'] ?? 0).toDouble(),

      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',

      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  // ============================================================
  // To Map
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'createdAt': createdAt,
    };
  }
}