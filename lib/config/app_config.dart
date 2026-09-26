class AppConfig {
  const AppConfig._();

  // ============================================================
  // Cloudinary
  // ============================================================
  // القيم الافتراضية هي نفس الإعدادات الحالية حتى الرفع
  // يظل يشتغل بدون أي تغيير بطريقة التشغيل.
  // للبيئات الثانية ممكن تمرير:
  // --dart-define=CLOUDINARY_CLOUD_NAME=...
  // --dart-define=CLOUDINARY_UPLOAD_PRESET=...
  // ============================================================

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'ownsdmuj',
  );

  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'bloom_profiles',
  );
}
