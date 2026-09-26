import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cart_service.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});
