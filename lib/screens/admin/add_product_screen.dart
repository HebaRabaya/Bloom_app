import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _imagePicker = ImagePicker();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final product = widget.product!;
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descriptionController.text = product.description;
      _quantityController.text = product.quantity.toString();
      _selectedCategory = product.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ============================================================
  // Image
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;
      setState(() => _selectedImage = File(image.path));
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to select an image.', isError: true);
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _saveProduct() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final description = _descriptionController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (name.isEmpty ||
        price == null ||
        description.isEmpty ||
        _selectedCategory == null ||
        quantity == null) {
      showBloomSnack(context, 'Please complete all fields.', isError: true);
      return;
    }

    if (!_isEditing && _selectedImage == null) {
      showBloomSnack(
        context,
        'Please select a product image.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!_isEditing) {
        await _productService.addProduct(
          name: name,
          price: price,
          description: description,
          category: _selectedCategory!,
          quantity: quantity,
          imageFile: _selectedImage!,
        );
      } else {
        await _productService.updateProduct(
          product: widget.product!,
          name: name,
          price: price,
          description: description,
          category: _selectedCategory!,
          quantity: quantity,
          newImageFile: _selectedImage,
        );
      }

      if (!mounted) return;

      showBloomSnack(
        context,
        _isEditing ? 'Product updated' : 'Product added to the shop',
      );

      if (_isEditing) {
        Navigator.pop(context);
        return;
      }

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _quantityController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
      });
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(
        context,
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      appBar: _isEditing
          ? AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: BloomCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              leadingWidth: 62,
              title: const Text('Edit Product'),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            padding,
            _isEditing ? 8 : 16,
            padding,
            28,
          ),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            if (!_isEditing) ...[
              FadeSlideIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Product', style: AppText.serif(size: 24)),
                    const SizedBox(height: 2),
                    Text(
                      'Add something beautiful to the Bloom shop.',
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            FadeSlideIn(
              delay: const Duration(milliseconds: 70),
              child: _buildImagePicker(),
            ),
            const SizedBox(height: 18),

            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: _field(
                controller: _nameController,
                label: 'Product name',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(height: 12),

            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _quantityController,
                      label: 'Quantity',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: _buildCategoryPicker(),
            ),
            const SizedBox(height: 12),

            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: _field(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 24),

            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Update Product' : 'Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget content;

    if (_selectedImage != null) {
      content = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_isEditing && widget.product!.imageUrl.isNotEmpty) {
      content = BloomImage(url: widget.product!.imageUrl);
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Select product image',
            style: AppText.sans(size: 12.5, color: AppColors.muted),
          ),
        ],
      );
    }

    return PressableScale(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            if (_selectedImage != null ||
                (_isEditing && widget.product!.imageUrl.isNotEmpty))
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Change',
                        style: AppText.sans(
                          size: 11,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return StreamBuilder(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 56,
            child: BloomLoader(),
          );
        }

        final names = snapshot.data!.docs
            .map((document) => document.data()['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

        if (names.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blush.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.coral,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Create a category first from the Categories tab.',
                    style: AppText.sans(size: 12.5, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          );
        }

        final selected = names.contains(_selectedCategory)
            ? _selectedCategory
            : null;

        return DropdownButtonFormField<String>(
          key: ValueKey('${selected ?? 'none'}-${names.length}'),
          initialValue: selected,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
          style: AppText.sans(size: 13.5),
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category_outlined, size: 19),
          ),
          items: [
            for (final name in names)
              DropdownMenuItem(value: name, child: Text(name)),
          ],
          onChanged: (value) => setState(() => _selectedCategory = value),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppText.sans(size: 13.5),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: EdgeInsets.only(bottom: 18.0 * (maxLines - 1)),
                child: Icon(icon, size: 19),
              )
            : Icon(icon, size: 19),
      ),
    );
  }
}
