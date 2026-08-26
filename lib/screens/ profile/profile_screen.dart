// import 'dart:io';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../services/auth_service.dart';
// import '../services/profile_service.dart';
// import 'login_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }
//
// class _ProfileScreenState
//     extends State<ProfileScreen> {
//   // ============================================================
//   // Controllers
//   // ============================================================
//
//   final _nameController =
//   TextEditingController();
//
//   final _ageController =
//   TextEditingController();
//
//   final _phoneController =
//   TextEditingController();
//
//   final _bioController =
//   TextEditingController();
//
//   // ============================================================
//   // Services
//   // ============================================================
//
//   final _profileService =
//   ProfileService();
//
//   final _authService =
//   AuthService();
//
//   final ImagePicker _imagePicker =
//   ImagePicker();
//
//   // ============================================================
//   // States
//   // ============================================================
//
//   bool _isLoading = true;
//   bool _isSaving = false;
//   bool _isUploadingImage = false;
//
//   String? _imageUrl;
//
//   File? _selectedImage;
//
//   // ============================================================
//   // Init
//   // ============================================================
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   // ============================================================
//   // Dispose
//   // ============================================================
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _phoneController.dispose();
//     _bioController.dispose();
//
//     super.dispose();
//   }
//
//   // ============================================================
//   // Load Profile
//   // ============================================================
//
//   Future<void> _loadProfile() async {
//     final user =
//         FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//
//       return;
//     }
//
//     try {
//       final document =
//       await _profileService.getProfile(
//         user.uid,
//       );
//
//       if (document.exists) {
//         final data = document.data();
//
//         _nameController.text =
//             data?['name']?.toString() ?? '';
//
//         _ageController.text =
//             data?['age']?.toString() ?? '';
//
//         _phoneController.text =
//             data?['phone']?.toString() ?? '';
//
//         _bioController.text =
//             data?['bio']?.toString() ?? '';
//
//         _imageUrl =
//             data?['imageUrl']?.toString();
//       } else {
//         _nameController.text =
//             user.displayName ?? '';
//       }
//     } catch (e) {
//       _showMessage(
//         'Unable to load your profile.',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // ============================================================
//   // Pick Image
//   // ============================================================
//
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedImage =
//       await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );
//
//       if (pickedImage == null) {
//         return;
//       }
//
//       setState(() {
//         _selectedImage =
//             File(pickedImage.path);
//       });
//     } catch (e) {
//       _showMessage(
//         'Unable to select image.',
//       );
//     }
//   }
//
//   // ============================================================
//   // Upload Image
//   // ============================================================
//
//   Future<String?> _uploadImage(
//       String uid) async {
//     if (_selectedImage == null) {
//       return _imageUrl;
//     }
//
//     setState(() {
//       _isUploadingImage = true;
//     });
//
//     try {
//       final imageUrl =
//       await _profileService
//           .uploadProfileImage(
//         uid: uid,
//         imageFile: _selectedImage!,
//       );
//
//       return imageUrl;
//     } catch (e) {
//       _showMessage(
//         'Unable to upload image. Please check Firebase Storage.',
//       );
//
//       return null;
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploadingImage = false;
//         });
//       }
//     }
//   }
//
//   // ============================================================
//   // Save Profile
//   // ============================================================
//
//   Future<void> _saveProfile() async {
//     final user =
//         FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       _showMessage(
//         'No logged-in user found.',
//       );
//
//       return;
//     }
//
//     if (_nameController.text
//         .trim()
//         .isEmpty) {
//       _showMessage(
//         'Please enter your name.',
//       );
//
//       return;
//     }
//
//     setState(() {
//       _isSaving = true;
//     });
//
//     try {
//       // --------------------------------------------------------
//       // Upload image first
//       // --------------------------------------------------------
//
//       final newImageUrl =
//       await _uploadImage(user.uid);
//
//       // إذا المستخدم اختار صورة جديدة
//       // ولكن الرفع فشل، لا نحفظ البروفايل
//       if (_selectedImage != null &&
//           newImageUrl == null) {
//         return;
//       }
//
//       // --------------------------------------------------------
//       // Save profile in Firestore
//       // --------------------------------------------------------
//
//       await _profileService.saveProfile(
//         uid: user.uid,
//         name: _nameController.text.trim(),
//         age: _ageController.text.trim(),
//         phone: _phoneController.text.trim(),
//         bio: _bioController.text.trim(),
//         imageUrl: newImageUrl,
//       );
//
//       // --------------------------------------------------------
//       // Update Firebase Authentication name
//       // --------------------------------------------------------
//
//       await user.updateDisplayName(
//         _nameController.text.trim(),
//       );
//
//       if (!mounted) return;
//
//       setState(() {
//         _imageUrl = newImageUrl;
//         _selectedImage = null;
//       });
//
//       _showMessage(
//         'Profile saved successfully 🌷',
//       );
//     } catch (e) {
//       _showMessage(
//         'Unable to save your profile.',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }
//
//   // ============================================================
//   // Logout
//   // ============================================================
//
//   Future<void> _logout() async {
//     final shouldLogout =
//     await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor:
//           const Color(0xFFFFFAF8),
//           shape:
//           RoundedRectangleBorder(
//             borderRadius:
//             BorderRadius.circular(24),
//           ),
//           title: Text(
//             'Leave Bloom?',
//             style:
//             GoogleFonts.playfairDisplay(
//               fontSize: 24,
//               fontWeight:
//               FontWeight.w600,
//               color:
//               const Color(0xFF4B3439),
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to log out?',
//             style:
//             GoogleFonts.dmSans(
//               color:
//               const Color(0xFF7D696D),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () =>
//                   Navigator.pop(
//                     context,
//                     false,
//                   ),
//               child:
//               const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () =>
//                   Navigator.pop(
//                     context,
//                     true,
//                   ),
//               style:
//               ElevatedButton.styleFrom(
//                 backgroundColor:
//                 const Color(
//                   0xFFB86F7B,
//                 ),
//                 foregroundColor:
//                 Colors.white,
//               ),
//               child:
//               const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (shouldLogout != true) {
//       return;
//     }
//
//     await _authService.logout();
//
//     if (!mounted) return;
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//         const LoginScreen(),
//       ),
//           (route) => false,
//     );
//   }
//
//   // ============================================================
//   // SnackBar
//   // ============================================================
//
//   void _showMessage(
//       String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//         SnackBarBehavior.floating,
//         backgroundColor:
//         const Color(0xFF5A3D43),
//         margin:
//         const EdgeInsets.all(16),
//         shape:
//         RoundedRectangleBorder(
//           borderRadius:
//           BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // Build
//   // ============================================================
//
//   @override
//   Widget build(
//       BuildContext context) {
//     final user =
//         FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       backgroundColor:
//       const Color(0xFFF9F4F1),
//
//       appBar: AppBar(
//         backgroundColor:
//         Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//
//         title: Text(
//           'My Bloom',
//           style:
//           GoogleFonts.playfairDisplay(
//             color:
//             const Color(0xFF4B3439),
//             fontSize: 24,
//             fontWeight:
//             FontWeight.w600,
//           ),
//         ),
//
//         actions: [
//           IconButton(
//             onPressed: _logout,
//             icon: const Icon(
//               Icons.logout_rounded,
//               color:
//               Color(0xFF8C626B),
//             ),
//           ),
//         ],
//       ),
//
//       body: _isLoading
//           ? const Center(
//         child:
//         CircularProgressIndicator(
//           color:
//           Color(0xFFB86F7B),
//         ),
//       )
//           : SingleChildScrollView(
//         padding:
//         const EdgeInsets.fromLTRB(
//           24,
//           10,
//           24,
//           35,
//         ),
//         child: Column(
//           children: [
//             _buildProfileHeader(
//               user,
//             ),
//
//             const SizedBox(
//               height: 28,
//             ),
//
//             _buildSectionTitle(
//               'Your details',
//               'Tell us a little about yourself.',
//             ),
//
//             const SizedBox(
//               height: 18,
//             ),
//
//             _buildField(
//               controller:
//               _nameController,
//               label: 'Name',
//               icon: Icons
//                   .person_outline_rounded,
//             ),
//
//             const SizedBox(
//               height: 14,
//             ),
//
//             Row(
//               children: [
//                 Expanded(
//                   child:
//                   _buildField(
//                     controller:
//                     _ageController,
//                     label: 'Age',
//                     icon: Icons
//                         .cake_outlined,
//                     keyboardType:
//                     TextInputType
//                         .number,
//                   ),
//                 ),
//
//                 const SizedBox(
//                   width: 12,
//                 ),
//
//                 Expanded(
//                   flex: 2,
//                   child:
//                   _buildField(
//                     controller:
//                     _phoneController,
//                     label: 'Phone',
//                     icon: Icons
//                         .phone_outlined,
//                     keyboardType:
//                     TextInputType
//                         .phone,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(
//               height: 14,
//             ),
//
//             _buildField(
//               controller:
//               _bioController,
//               label: 'Bio',
//               icon: Icons
//                   .edit_note_rounded,
//               maxLines: 4,
//             ),
//
//             const SizedBox(
//               height: 24,
//             ),
//
//             SizedBox(
//               width:
//               double.infinity,
//               height: 56,
//               child:
//               ElevatedButton(
//                 onPressed:
//                 _isSaving ||
//                     _isUploadingImage
//                     ? null
//                     : _saveProfile,
//                 style:
//                 ElevatedButton
//                     .styleFrom(
//                   backgroundColor:
//                   const Color(
//                     0xFFB86F7B,
//                   ),
//                   foregroundColor:
//                   Colors.white,
//                   elevation: 0,
//                   shape:
//                   RoundedRectangleBorder(
//                     borderRadius:
//                     BorderRadius
//                         .circular(
//                       17,
//                     ),
//                   ),
//                 ),
//                 child: _isSaving ||
//                     _isUploadingImage
//                     ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child:
//                   CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color:
//                     Colors.white,
//                   ),
//                 )
//                     : Text(
//                   'Save my profile',
//                   style:
//                   GoogleFonts
//                       .dmSans(
//                     fontWeight:
//                     FontWeight
//                         .w700,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(
//               height: 18,
//             ),
//
//             Text(
//               'Bloom where you are planted ✦',
//               style:
//               GoogleFonts
//                   .playfairDisplay(
//                 fontStyle:
//                 FontStyle.italic,
//                 color:
//                 const Color(
//                   0xFF9B777E,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // Profile Header
//   // ============================================================
//
//   Widget _buildProfileHeader(
//       User? user) {
//     final displayName =
//     _nameController
//         .text
//         .isNotEmpty
//         ? _nameController.text
//         : user?.displayName ??
//         'Bloom User';
//
//     return Column(
//       children: [
//         // --------------------------------------------------------
//         // Image + Camera Button
//         // --------------------------------------------------------
//
//         Stack(
//           children: [
//             Container(
//               width: 112,
//               height: 112,
//               decoration:
//               BoxDecoration(
//                 shape:
//                 BoxShape.circle,
//                 color:
//                 const Color(
//                   0xFFE8D1D4,
//                 ),
//                 border:
//                 Border.all(
//                   color: Colors.white,
//                   width: 5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black
//                         .withValues(
//                       alpha: 0.08,
//                     ),
//                     blurRadius: 20,
//                     offset:
//                     const Offset(
//                       0,
//                       8,
//                     ),
//                   ),
//                 ],
//               ),
//               child:
//               _selectedImage !=
//                   null
//                   ? ClipOval(
//                 child:
//                 Image.file(
//                   _selectedImage!,
//                   fit: BoxFit
//                       .cover,
//                 ),
//               )
//                   : _imageUrl !=
//                   null &&
//                   _imageUrl!
//                       .isNotEmpty
//                   ? ClipOval(
//                 child:
//                 Image.network(
//                   _imageUrl!,
//                   fit: BoxFit
//                       .cover,
//                 ),
//               )
//                   : const Icon(
//                 Icons
//                     .local_florist_rounded,
//                 size: 48,
//                 color:
//                 Color(
//                   0xFFB86F7B,
//                 ),
//               ),
//             ),
//
//             // --------------------------------------------------
//             // Camera Button
//             // --------------------------------------------------
//
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: GestureDetector(
//                 onTap:
//                 _pickImage,
//                 child:
//                 Container(
//                   width: 38,
//                   height: 38,
//                   decoration:
//                   BoxDecoration(
//                     color:
//                     const Color(
//                       0xFFB86F7B,
//                     ),
//                     shape:
//                     BoxShape.circle,
//                     border:
//                     Border.all(
//                       color:
//                       const Color(
//                         0xFFF9F4F1,
//                       ),
//                       width: 3,
//                     ),
//                   ),
//                   child:
//                   const Icon(
//                     Icons
//                         .camera_alt_rounded,
//                     color:
//                     Colors.white,
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         const SizedBox(
//           height: 15,
//         ),
//
//         Text(
//           displayName,
//           style:
//           GoogleFonts.playfairDisplay(
//             fontSize: 28,
//             fontWeight:
//             FontWeight.w600,
//             color:
//             const Color(
//               0xFF4B3439,
//             ),
//           ),
//         ),
//
//         const SizedBox(
//           height: 5,
//         ),
//
//         Text(
//           user?.email ?? '',
//           style:
//           GoogleFonts.dmSans(
//             fontSize: 13,
//             color:
//             const Color(
//               0xFF92797E,
//             ),
//           ),
//         ),
//
//         const SizedBox(
//           height: 8,
//         ),
//
//         TextButton.icon(
//           onPressed:
//           _pickImage,
//           icon:
//           const Icon(
//             Icons
//                 .photo_camera_outlined,
//             size: 18,
//           ),
//           label:
//           const Text(
//             'Change profile photo',
//           ),
//           style:
//           TextButton.styleFrom(
//             foregroundColor:
//             const Color(
//               0xFF9E5967,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // Section Title
//   // ============================================================
//
//   Widget _buildSectionTitle(
//       String title,
//       String subtitle,
//       ) {
//     return Align(
//       alignment:
//       Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style:
//             GoogleFonts.playfairDisplay(
//               fontSize: 23,
//               fontWeight:
//               FontWeight.w600,
//               color:
//               const Color(
//                 0xFF4B3439,
//               ),
//             ),
//           ),
//
//           const SizedBox(
//             height: 3,
//           ),
//
//           Text(
//             subtitle,
//             style:
//             GoogleFonts.dmSans(
//               fontSize: 13,
//               color:
//               const Color(
//                 0xFF92797E,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // Profile Field
//   // ============================================================
//
//   Widget _buildField({
//     required TextEditingController
//     controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller:
//       controller,
//       keyboardType:
//       keyboardType,
//       maxLines:
//       maxLines,
//       style:
//       GoogleFonts.dmSans(
//         fontSize: 14,
//         color:
//         const Color(
//           0xFF4B3439,
//         ),
//       ),
//       decoration:
//       InputDecoration(
//         labelText:
//         label,
//
//         prefixIcon:
//         Icon(
//           icon,
//           color:
//           const Color(
//             0xFFB86F7B,
//           ),
//         ),
//
//         filled: true,
//         fillColor:
//         Colors.white,
//
//         contentPadding:
//         const EdgeInsets
//             .symmetric(
//           horizontal: 18,
//           vertical: 17,
//         ),
//
//         border:
//         OutlineInputBorder(
//           borderRadius:
//           BorderRadius
//               .circular(
//             17,
//           ),
//           borderSide:
//           BorderSide.none,
//         ),
//
//         enabledBorder:
//         OutlineInputBorder(
//           borderRadius:
//           BorderRadius
//               .circular(
//             17,
//           ),
//           borderSide:
//           BorderSide.none,
//         ),
//
//         focusedBorder:
//         OutlineInputBorder(
//           borderRadius:
//           BorderRadius
//               .circular(
//             17,
//           ),
//           borderSide:
//           const BorderSide(
//             color:
//             Color(
//               0xFFD39AA4,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  // ============================================================
  // Controllers
  // ============================================================

  final _nameController =
  TextEditingController();

  final _ageController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _bioController =
  TextEditingController();

  // ============================================================
  // Services
  // ============================================================

  final _profileService =
  ProfileService();

  final _authService =
  AuthService();

  final ImagePicker _imagePicker =
  ImagePicker();

  // ============================================================
  // States
  // ============================================================

  bool _isLoading = true;

  bool _isSaving = false;

  bool _isUploadingImage = false;

  String? _imageUrl;

  File? _selectedImage;

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ============================================================
  // Load Profile
  // ============================================================

  Future<void> _loadProfile() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return;
    }

    try {
      final document =
      await _profileService.getProfile(
        user.uid,
      );

      if (document.exists) {
        final data =
        document.data();

        _nameController.text =
            data?['name']
                ?.toString() ??
                '';

        _ageController.text =
            data?['age']
                ?.toString() ??
                '';

        _phoneController.text =
            data?['phone']
                ?.toString() ??
                '';

        _bioController.text =
            data?['bio']
                ?.toString() ??
                '';

        _imageUrl =
            data?['imageUrl']
                ?.toString();
      } else {
        _nameController.text =
            user.displayName ?? '';
      }
    } catch (e) {
      _showMessage(
        'Unable to load your profile.',
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
  // Pick Image
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
      await _imagePicker.pickImage(
        source:
        ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _selectedImage =
            File(pickedImage.path);
      });
    } catch (e) {
      _showMessage(
        'Unable to select image.',
      );
    }
  }

  // ============================================================
  // Upload Image
  // ============================================================

  Future<String?> _uploadImage(
      String uid) async {

    if (_selectedImage == null) {
      return _imageUrl;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl =
      await _profileService
          .uploadProfileImage(
        uid: uid,
        imageFile:
        _selectedImage!,
      );

      return imageUrl;
    } catch (e) {
      _showMessage(
        'Unable to upload image. '
            'Please check your Cloudinary settings.',
      );

      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // ============================================================
  // Save Profile
  // ============================================================

  Future<void> _saveProfile() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'No logged-in user found.',
      );

      return;
    }

    if (_nameController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Please enter your name.',
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {

      // --------------------------------------------------------
      // Upload image to Cloudinary
      // --------------------------------------------------------

      final newImageUrl =
      await _uploadImage(
        user.uid,
      );

      // --------------------------------------------------------
      // If image upload failed
      // --------------------------------------------------------

      if (_selectedImage != null &&
          newImageUrl == null) {

        return;
      }

      // --------------------------------------------------------
      // Save profile to Firestore
      // --------------------------------------------------------

      await _profileService.saveProfile(
        uid: user.uid,
        name:
        _nameController.text.trim(),
        age:
        _ageController.text.trim(),
        phone:
        _phoneController.text.trim(),
        bio:
        _bioController.text.trim(),
        imageUrl: newImageUrl,
      );

      // --------------------------------------------------------
      // Update Firebase Auth display name
      // --------------------------------------------------------

      await user.updateDisplayName(
        _nameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imageUrl = newImageUrl;

        _selectedImage = null;
      });

      _showMessage(
        'Profile saved successfully 🌷',
      );

    } catch (e) {

      _showMessage(
        'Unable to save your profile.',
      );

    } finally {

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> _logout() async {

    final shouldLogout =
    await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          backgroundColor:
          const Color(0xFFFFFAF8),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
          ),

          title: Text(
            'Leave Bloom?',
            style:
            GoogleFonts
                .playfairDisplay(
              fontSize: 24,
              fontWeight:
              FontWeight.w600,
              color:
              const Color(
                0xFF4B3439,
              ),
            ),
          ),

          content: Text(
            'Are you sure you want to log out?',
            style:
            GoogleFonts.dmSans(
              color:
              const Color(
                0xFF7D696D,
              ),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                    false,
                  ),
              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                    true,
                  ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFFB86F7B,
                ),
                foregroundColor:
                Colors.white,
              ),
              child:
              const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await _authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ============================================================
  // SnackBar
  // ============================================================

  void _showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),

        behavior:
        SnackBarBehavior.floating,

        backgroundColor:
        const Color(
          0xFF5A3D43,
        ),

        margin:
        const EdgeInsets.all(
          16,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: Text(
          'My Bloom',
          style:
          GoogleFonts.playfairDisplay(
            color:
            const Color(
              0xFF4B3439,
            ),
            fontSize: 24,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        actions: [

          IconButton(
            onPressed:
            _logout,

            icon:
            const Icon(
              Icons.logout_rounded,
              color:
              Color(0xFF8C626B),
            ),
          ),
        ],
      ),

      body: _isLoading

          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          Color(0xFFB86F7B),
        ),
      )

          : SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          24,
          10,
          24,
          35,
        ),

        child: Column(
          children: [

            _buildProfileHeader(
              user,
            ),

            const SizedBox(
              height: 28,
            ),

            _buildSectionTitle(
              'Your details',
              'Tell us a little about yourself.',
            ),

            const SizedBox(
              height: 18,
            ),

            _buildField(
              controller:
              _nameController,
              label: 'Name',
              icon: Icons
                  .person_outline_rounded,
            ),

            const SizedBox(
              height: 14,
            ),

            Row(
              children: [

                Expanded(
                  child:
                  _buildField(
                    controller:
                    _ageController,
                    label: 'Age',
                    icon: Icons
                        .cake_outlined,
                    keyboardType:
                    TextInputType
                        .number,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  flex: 2,
                  child:
                  _buildField(
                    controller:
                    _phoneController,
                    label: 'Phone',
                    icon: Icons
                        .phone_outlined,
                    keyboardType:
                    TextInputType
                        .phone,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            _buildField(
              controller:
              _bioController,
              label: 'Bio',
              icon: Icons
                  .edit_note_rounded,
              maxLines: 4,
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
              double.infinity,

              height: 56,

              child:
              ElevatedButton(
                onPressed:
                _isSaving ||
                    _isUploadingImage
                    ? null
                    : _saveProfile,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFB86F7B,
                  ),

                  foregroundColor:
                  Colors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      17,
                    ),
                  ),
                ),

                child:
                _isSaving ||
                    _isUploadingImage

                    ? const SizedBox(
                  width: 22,
                  height: 22,

                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    Colors.white,
                  ),
                )

                    : Text(
                  'Save my profile',

                  style:
                  GoogleFonts
                      .dmSans(
                    fontWeight:
                    FontWeight
                        .w700,
                    fontSize:
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'Bloom where you are planted ✦',

              style:
              GoogleFonts
                  .playfairDisplay(
                fontStyle:
                FontStyle.italic,
                color:
                const Color(
                  0xFF9B777E,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Profile Header
  // ============================================================

  Widget _buildProfileHeader(
      User? user) {

    final displayName =
    _nameController.text.isNotEmpty
        ? _nameController.text
        : user?.displayName ??
        'Bloom User';

    return Column(
      children: [

        Stack(
          children: [

            Container(
              width: 112,
              height: 112,

              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,

                color:
                const Color(
                  0xFFE8D1D4,
                ),

                border:
                Border.all(
                  color:
                  Colors.white,
                  width: 5,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black
                        .withValues(
                      alpha: 0.08,
                    ),
                    blurRadius:
                    20,
                    offset:
                    const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),

              child:

              // New selected image
              _selectedImage != null

                  ? ClipOval(
                child:
                Image.file(
                  _selectedImage!,
                  fit:
                  BoxFit.cover,
                ),
              )

              // Existing Cloudinary image
                  : _imageUrl != null &&
                  _imageUrl!.isNotEmpty

                  ? ClipOval(
                child:
                Image.network(
                  _imageUrl!,
                  fit:
                  BoxFit.cover,

                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Icon(
                      Icons
                          .local_florist_rounded,
                      size: 48,
                      color:
                      Color(
                        0xFFB86F7B,
                      ),
                    );
                  },
                ),
              )

              // Default icon
                  : const Icon(
                Icons
                    .local_florist_rounded,
                size: 48,
                color:
                Color(
                  0xFFB86F7B,
                ),
              ),
            ),

            // ==================================================
            // Camera Button
            // ==================================================

            Positioned(
              bottom: 0,
              right: 0,

              child:
              GestureDetector(
                onTap:
                _pickImage,

                child:
                Container(
                  width: 38,
                  height: 38,

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFB86F7B,
                    ),

                    shape:
                    BoxShape.circle,

                    border:
                    Border.all(
                      color:
                      const Color(
                        0xFFF9F4F1,
                      ),
                      width: 3,
                    ),
                  ),

                  child:
                  const Icon(
                    Icons
                        .camera_alt_rounded,
                    color:
                    Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 15,
        ),

        Text(
          displayName,

          style:
          GoogleFonts
              .playfairDisplay(
            fontSize: 28,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(
              0xFF4B3439,
            ),
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          user?.email ?? '',

          style:
          GoogleFonts.dmSans(
            fontSize: 13,
            color:
            const Color(
              0xFF92797E,
            ),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextButton.icon(
          onPressed:
          _pickImage,

          icon:
          const Icon(
            Icons
                .photo_camera_outlined,
            size: 18,
          ),

          label:
          const Text(
            'Change profile photo',
          ),

          style:
          TextButton.styleFrom(
            foregroundColor:
            const Color(
              0xFF9E5967,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Section Title
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      String subtitle) {

    return Align(
      alignment:
      Alignment.centerLeft,

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style:
            GoogleFonts
                .playfairDisplay(
              fontSize: 23,
              fontWeight:
              FontWeight.w600,
              color:
              const Color(
                0xFF4B3439,
              ),
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            subtitle,

            style:
            GoogleFonts.dmSans(
              fontSize: 13,
              color:
              const Color(
                0xFF92797E,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Profile Field
  // ============================================================

  Widget _buildField({
    required TextEditingController
    controller,

    required String label,

    required IconData icon,

    TextInputType? keyboardType,

    int maxLines = 1,
  }) {

    return TextField(
      controller:
      controller,

      keyboardType:
      keyboardType,

      maxLines:
      maxLines,

      style:
      GoogleFonts.dmSans(
        fontSize: 14,
        color:
        const Color(
          0xFF4B3439,
        ),
      ),

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

        contentPadding:
        const EdgeInsets
            .symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            17,
          ),
          borderSide:
          BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            17,
          ),
          borderSide:
          BorderSide.none,
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            17,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFD39AA4,
            ),
          ),
        ),
      ),
    );
  }
}