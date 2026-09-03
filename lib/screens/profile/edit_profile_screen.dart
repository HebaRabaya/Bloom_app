import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();

  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _imageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ============================================================
  // Load
  // ============================================================

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final document = await _profileService.getProfile(user.uid);

      if (document.exists) {
        final data = document.data();
        _nameController.text = data?['name']?.toString() ?? '';
        _ageController.text = data?['age']?.toString() ?? '';
        _phoneController.text = data?['phone']?.toString() ?? '';
        _bioController.text = data?['bio']?.toString() ?? '';
        _addressController.text = data?['address']?.toString() ?? '';
        _imageUrl = data?['imageUrl']?.toString();
      } else {
        _nameController.text = user.displayName ?? '';
      }
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to load your profile.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Image
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;
      setState(() => _selectedImage = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to select an image.', isError: true);
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showBloomSnack(context, 'No logged-in user found.', isError: true);
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      showBloomSnack(context, 'Please enter your name.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      var imageUrl = _imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _profileService.uploadProfileImage(
          uid: user.uid,
          imageFile: _selectedImage!,
        );
      }

      await _profileService.saveProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        imageUrl: imageUrl,
        address: _addressController.text.trim(),
      );

      await user.updateDisplayName(_nameController.text.trim());

      if (!mounted) return;

      setState(() {
        _imageUrl = imageUrl;
        _selectedImage = null;
      });

      showBloomSnack(context, 'Profile updated');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(
        context,
        'Unable to save your profile. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BloomCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 62,
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const BloomLoader()
          : ListView(
              padding: EdgeInsets.fromLTRB(padding, 8, padding, 40),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                FadeSlideIn(child: Center(child: _buildAvatar())),
                const SizedBox(height: 28),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: _field(
                    controller: _nameController,
                    label: 'Full name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _ageController,
                          label: 'Age',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _field(
                          controller: _phoneController,
                          label: 'Phone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: _field(
                    controller: _addressController,
                    label: 'Delivery address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: _field(
                    controller: _bioController,
                    label: 'About you',
                    icon: Icons.edit_note_rounded,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 26),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    Widget avatar;

    if (_selectedImage != null) {
      avatar = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_imageUrl != null && _imageUrl!.trim().isNotEmpty) {
      avatar = BloomImage(url: _imageUrl!);
    } else {
      avatar = const ColoredBox(
        color: AppColors.blush,
        child: Icon(
          Icons.person_rounded,
          size: 46,
          color: AppColors.coralSoft,
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 116,
            height: 116,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.taupe.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: avatar,
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.forest,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cream, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
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
