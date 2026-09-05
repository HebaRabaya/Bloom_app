import 'package:flutter/material.dart';

import '../../services/category_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryService = CategoryService();
  final _categoryController = TextEditingController();

  bool _isAdding = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      await _categoryService.addCategory(name);
      _categoryController.clear();
      if (!mounted) return;
      showBloomSnack(context, '$name added');
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to add this category.', isError: true);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteCategory(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Products already using "$name" will keep their label.',
          style: AppText.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _categoryService.deleteCategory(id);
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to delete this category.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
              child: FadeSlideIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categories', style: AppText.serif(size: 24)),
                    const SizedBox(height: 2),
                    Text(
                      'Group your flowers so customers find them faster.',
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _addCategory(),
                            style: AppText.sans(size: 13.5),
                            decoration: const InputDecoration(
                              hintText: 'Roses, Plants, Gifts…',
                              prefixIcon: Icon(
                                Icons.local_florist_outlined,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isAdding ? null : _addCategory,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(54, 54),
                              shape: const CircleBorder(),
                            ),
                            child: _isAdding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder(
                stream: _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const BloomEmptyState(
                      title: 'Something went wrong',
                      message: 'We could not load your categories.',
                      icon: Icons.error_outline_rounded,
                    );
                  }

                  if (!snapshot.hasData) return const BloomLoader();

                  final categories = snapshot.data!.docs;

                  if (categories.isEmpty) {
                    return const BloomEmptyState(
                      title: 'No categories yet',
                      message:
                          'Add your first collection above — try Roses, '
                          'Plants or Gifts.',
                      icon: Icons.category_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(padding, 2, padding, 24),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final document = categories[index];
                      final name =
                          document.data()['name']?.toString() ?? '';

                      return FadeSlideIn.staggered(
                        key: ValueKey(document.id),
                        index: index,
                        child: BloomCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  AppAssets.categoryFallback(name),
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppText.sans(
                                    size: 14,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _deleteCategory(document.id, name),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
