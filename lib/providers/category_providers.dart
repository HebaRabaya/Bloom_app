import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});
