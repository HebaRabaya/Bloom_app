import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});
