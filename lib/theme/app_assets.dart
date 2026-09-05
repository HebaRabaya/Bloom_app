class AppAssets {
  static const splashBackground = 'assets/images/splash_background.jpg';
  static const authScreenBackground =
      'assets/images/auth_screen_background.jpg';
  static const homeHeroBanner = 'assets/images/home_hero_banner.png';
  static const emptyStateIllustration =
      'assets/images/empty_state_illustration.png';

  static const onboardingFreshFlowers =
      'assets/images/onboarding_fresh_flowers.png';
  static const onboardingSameDayDelivery =
      'assets/images/onboarding_same_day_delivery.png';
  static const onboardingEveryOccasion =
      'assets/images/onboarding_every_occasion.png';

  static const categoryBouquets = 'assets/images/category_bouquets.png';
  static const categoryPlants = 'assets/images/category_plants.png';
  static const categoryGifts = 'assets/images/category_gifts.png';
  static const categoryOccasions = 'assets/images/category_occasions.png';

  /// Picks a decorative fallback image for a category name coming from
  /// Firestore, so categories always look designed even without an image.
  static String categoryFallback(String name) {
    final value = name.toLowerCase();

    if (value.contains('plant') || value.contains('نبات')) {
      return categoryPlants;
    }
    if (value.contains('gift') || value.contains('هدا')) {
      return categoryGifts;
    }
    if (value.contains('occasion') ||
        value.contains('birthday') ||
        value.contains('مناسب')) {
      return categoryOccasions;
    }
    return categoryBouquets;
  }
}
