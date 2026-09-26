import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorite_service.dart';

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService();
});
