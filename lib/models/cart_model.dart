class CartModel {
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final int quantity;
  final int availableQuantity;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    required this.availableQuantity,
  });

  // ============================================================
  // Firestore → CartModel
  // ============================================================

  factory CartModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return CartModel(
      productId:
      map['productId']?.toString() ?? '',

      productName:
      map['productName']?.toString() ?? '',

      productPrice:
      (map['productPrice'] as num?)?.toDouble() ?? 0.0,

      productImage:
      map['productImage']?.toString() ?? '',

      quantity:
      (map['quantity'] as num?)?.toInt() ?? 1,

      availableQuantity:
      (map['availableQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  // ============================================================
  // CartModel → Firestore
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'quantity': quantity,
      'availableQuantity': availableQuantity,
    };
  }
}