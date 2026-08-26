class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int quantity;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.quantity,
    required this.imageUrl,
  });

  // ============================================================
  // تحويل بيانات Firestore إلى ProductModel
  // ============================================================

  factory ProductModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // ============================================================
  // تحويل ProductModel إلى Map
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}