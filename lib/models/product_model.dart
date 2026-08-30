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
  // Firestore -> ProductModel
  // ============================================================

  factory ProductModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return ProductModel(
      id: id,

      name:
      map['name']?.toString() ?? '',

      price:
      _parseDouble(map['price']),

      description:
      map['description']?.toString() ?? '',

      category:
      map['category']?.toString() ?? '',

      quantity:
      _parseInt(map['quantity']),

      imageUrl:
      map['imageUrl']?.toString() ?? '',
    );
  }

  // ============================================================
  // ProductModel -> Map
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

  // ============================================================
  // Parse Double
  // ============================================================

  static double _parseDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ============================================================
  // Parse Int
  // ============================================================

  static int _parseInt(
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