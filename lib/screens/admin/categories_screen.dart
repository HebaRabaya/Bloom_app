import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/category_service.dart';

class CategoriesScreen
    extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  final CategoryService _categoryService =
  CategoryService();

  final TextEditingController
  _categoryController =
  TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // ============================================================
  // Add Category
  // ============================================================

  Future<void> _addCategory() async {
    final name =
    _categoryController.text.trim();

    if (name.isEmpty) {
      return;
    }

    await _categoryService.addCategory(
      name,
    );

    _categoryController.clear();
  }

  // ============================================================
  // Delete Category
  // ============================================================

  Future<void> _deleteCategory(
      String id,
      ) async {
    await _categoryService
        .deleteCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        title: Text(
          'Categories',
          style:
          GoogleFonts.playfairDisplay(
            fontWeight:
            FontWeight.w600,
          ),
        ),

        centerTitle: true,

        backgroundColor:
        Colors.transparent,

        elevation: 0,
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==================================================
            // Add Category
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                    _categoryController,

                    decoration:
                    InputDecoration(
                      hintText:
                      'Category name',

                      filled: true,

                      fillColor:
                      Colors.white,

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),

                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed:
                  _addCategory,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFFB86F7B,
                    ),

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.all(
                      18,
                    ),
                  ),

                  child:
                  const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // Categories List
            // ==================================================

            Expanded(
              child: StreamBuilder(
                stream: _categoryService
                    .getCategories(),

                builder:
                    (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final categories =
                      snapshot.data!.docs;

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories yet.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount:
                    categories.length,

                    itemBuilder:
                        (context, index) {
                      final category =
                      categories[index];

                      final data =
                      category.data();

                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.category_outlined,
                          ),

                          title: Text(
                            data['name'] ?? '',
                          ),

                          trailing:
                          IconButton(
                            onPressed: () {
                              _deleteCategory(
                                category.id,
                              );
                            },

                            icon: const Icon(
                              Icons.delete_outline,
                              color:
                              Colors.red,
                            ),
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