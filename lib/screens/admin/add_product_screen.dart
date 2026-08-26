import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';

class AddProductScreen
    extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({
    super.key,
    this.product,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  // ============================================================
  // Controllers
  // ============================================================

  final _nameController =
  TextEditingController();

  final _priceController =
  TextEditingController();

  final _descriptionController =
  TextEditingController();

  final _quantityController =
  TextEditingController();

  // ============================================================
  // Services
  // ============================================================

  final ProductService _productService =
  ProductService();

  final CategoryService _categoryService =
  CategoryService();

  final ImagePicker _imagePicker =
  ImagePicker();

  // ============================================================
  // States
  // ============================================================

  String? _selectedCategory;

  File? _selectedImage;

  bool _isLoading = false;

  // ============================================================
  // هل الشاشة Add أو Edit؟
  // ============================================================

  bool get _isEditing =>
      widget.product != null;

  @override
  void initState() {
    super.initState();

    // إذا في Product معناها Edit
    if (_isEditing) {
      final product =
      widget.product!;

      _nameController.text =
          product.name;

      _priceController.text =
          product.price.toString();

      _descriptionController.text =
          product.description;

      _quantityController.text =
          product.quantity.toString();

      _selectedCategory =
          product.category;
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
  // Pick Image
  // ============================================================

  Future<void> _pickImage() async {
    final XFile? image =
    await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage =
          File(image.path);
    });
  }

  // ============================================================
  // Save Product
  // ============================================================

  Future<void> _saveProduct() async {
    final name =
    _nameController.text.trim();

    final price =
    double.tryParse(
      _priceController.text.trim(),
    );

    final description =
    _descriptionController.text.trim();

    final quantity =
    int.tryParse(
      _quantityController.text.trim(),
    );

    // ----------------------------------------------------------
    // Validation
    // ----------------------------------------------------------

    if (name.isEmpty ||
        price == null ||
        description.isEmpty ||
        _selectedCategory == null ||
        quantity == null) {
      _showMessage(
        'Please complete all fields.',
      );

      return;
    }

    // بالصورة:
    // Add لازم صورة
    // Edit الصورة اختيارية

    if (!_isEditing &&
        _selectedImage == null) {
      _showMessage(
        'Please select a product image.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // Add Product
      // --------------------------------------------------------

      if (!_isEditing) {
        await _productService.addProduct(
          name: name,
          price: price,
          description: description,
          category:
          _selectedCategory!,
          quantity: quantity,
          imageFile:
          _selectedImage!,
        );
      }

      // --------------------------------------------------------
      // Edit Product
      // --------------------------------------------------------

      else {
        await _productService
            .updateProduct(
          product:
          widget.product!,

          name: name,

          price: price,

          description:
          description,

          category:
          _selectedCategory!,

          quantity: quantity,

          newImageFile:
          _selectedImage,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        _isEditing
            ? 'Product updated successfully.'
            : 'Product added successfully.',
      );

      // إذا Edit نرجع للشاشة السابقة
      if (_isEditing) {
        Navigator.pop(context);
      } else {
        // تنظيف الحقول بعد الإضافة
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _quantityController.clear();

        setState(() {
          _selectedCategory = null;
          _selectedImage = null;
        });
      }
    } catch (e) {
      _showMessage(
        'Something went wrong.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SnackBar
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor:
        const Color(0xFF5A3D43),

        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: _isEditing
          ? AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        title: Text(
          'Edit Product',
          style:
          GoogleFonts.playfairDisplay(
            color:
            const Color(
              0xFF4B3439,
            ),
          ),
        ),
      )
          : null,

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // Title
            // ==================================================

            if (!_isEditing) ...[
              const SizedBox(height: 30),

              Text(
                'Add Product',
                style:
                GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  const Color(
                    0xFF4B3439,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add something beautiful to Bloom.',
                style:
                GoogleFonts.dmSans(
                  color:
                  const Color(
                    0xFF92797E,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],

            // ==================================================
            // Image
            // ==================================================

            GestureDetector(
              onTap: _pickImage,

              child: Container(
                width: double.infinity,
                height: 180,

                decoration:
                BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),

                  border: Border.all(
                    color:
                    const Color(
                      0xFFE8D1D4,
                    ),
                  ),
                ),

                child: _selectedImage !=
                    null
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),

                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : _isEditing &&
                    widget.product!
                        .imageUrl
                        .isNotEmpty
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),

                  child:
                  Image.network(
                    widget.product!
                        .imageUrl,

                    fit:
                    BoxFit.cover,
                  ),
                )
                    : const Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    Icon(
                      Icons
                          .add_photo_alternate_outlined,
                      size: 45,
                      color:
                      Color(
                        0xFFB86F7B,
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Select product image',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // Name
            // ==========================================================

            _buildField(
              controller:
              _nameController,

              label:
              'Product name',

              icon:
              Icons.inventory_2_outlined,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // Price
            // ==========================================================

            _buildField(
              controller:
              _priceController,

              label:
              'Price',

              icon:
              Icons.attach_money_rounded,

              keyboardType:
              TextInputType.number,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // Description
            // ==========================================================

            _buildField(
              controller:
              _descriptionController,

              label:
              'Description',

              icon:
              Icons.description_outlined,

              maxLines: 4,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // Categories Dropdown
            // ==========================================================

            StreamBuilder(
              stream: _categoryService
                  .getCategories(),

              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final categories =
                    snapshot.data!.docs;

                // مهم:
                // إذا category الحالية انحذفت
                // ما نخلي Dropdown يرمي Error

                final categoryNames =
                categories
                    .map(
                      (doc) =>
                  doc.data()['name']
                      ?.toString() ??
                      '',
                )
                    .toList();

                final selectedValue =
                categoryNames.contains(
                  _selectedCategory,
                )
                    ? _selectedCategory
                    : null;

                return DropdownButtonFormField<
                    String>(
                  value: selectedValue,

                  decoration:
                  InputDecoration(
                    labelText:
                    'Category',

                    prefixIcon:
                    const Icon(
                      Icons.category_outlined,
                      color:
                      Color(
                        0xFFB86F7B,
                      ),
                    ),

                    filled: true,

                    fillColor:
                    Colors.white,

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),

                  items: categoryNames
                      .map(
                        (name) =>
                        DropdownMenuItem(
                          value: name,

                          child:
                          Text(name),
                        ),
                  )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _selectedCategory =
                          value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // ==================================================
            // Quantity
            // ==========================================================

            _buildField(
              controller:
              _quantityController,

              label:
              'Quantity',

              icon:
              Icons.numbers_rounded,

              keyboardType:
              TextInputType.number,
            ),

            const SizedBox(height: 25),

            // ==================================================
            // Save Button
            // ==========================================================

            SizedBox(
              width:
              double.infinity,

              height: 56,

              child:
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _saveProduct,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFB86F7B,
                  ),

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      17,
                    ),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,

                  child:
                  CircularProgressIndicator(
                    color:
                    Colors.white,
                    strokeWidth:
                    2,
                  ),
                )
                    : Text(
                  _isEditing
                      ? 'Update Product'
                      : 'Add Product',
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Reusable Input Field
  // ============================================================

  Widget _buildField({
    required TextEditingController
    controller,

    required String label,

    required IconData icon,

    TextInputType?
    keyboardType,

    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,

      keyboardType:
      keyboardType,

      maxLines:
      maxLines,

      decoration:
      InputDecoration(
        labelText:
        label,

        prefixIcon:
        Icon(
          icon,
          color:
          const Color(
            0xFFB86F7B,
          ),
        ),

        filled: true,

        fillColor:
        Colors.white,

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            17,
          ),

          borderSide:
          BorderSide.none,
        ),
      ),
    );
  }
}