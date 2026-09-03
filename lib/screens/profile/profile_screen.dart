import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';
import '../auth/login_screen.dart';
import '../user/favorites_screen.dart';
import '../user/user_main_screen.dart';
import 'edit_profile_screen.dart';

/// Account hub. Shared by customers and admins; customer-only shortcuts are
/// hidden when [isAdmin] is true.
class ProfileScreen extends StatelessWidget {
  final bool isAdmin;

  const ProfileScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);
    final profileService = ProfileService();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null ? null : profileService.watchProfile(user.uid),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();

            final name = (data?['name']?.toString().trim().isNotEmpty ?? false)
                ? data!['name'].toString()
                : user?.displayName ?? 'Bloom User';

            final imageUrl = data?['imageUrl']?.toString() ?? '';

            return ListView(
              padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                FadeSlideIn(
                  child: _buildHeader(
                    context: context,
                    name: name,
                    email: user?.email ?? '',
                    imageUrl: imageUrl,
                  ),
                ),
                const SizedBox(height: 28),

                ..._buildMenu(context),

                const SizedBox(height: 26),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Opacity(
                    opacity: 0.45,
                    child: Column(
                      children: [
                        const BloomMark(size: 26),
                        const SizedBox(height: 8),
                        Text(
                          'Bloom Flowers · v1.0',
                          style: AppText.sans(
                            size: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================

  Widget _buildHeader({
    required BuildContext context,
    required String name,
    required String email,
    required String imageUrl,
  }) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 42),
            Expanded(
              child: Center(
                child: Text('Profile', style: AppText.serif(size: 22)),
              ),
            ),
            BloomCircleButton(
              icon: Icons.edit_outlined,
              onTap: () => _openEditProfile(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _openEditProfile(context),
          child: Container(
            width: 104,
            height: 104,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blush,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.taupe.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: imageUrl.trim().isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: AppColors.coralSoft,
                  )
                : BloomImage(url: imageUrl),
          ),
        ),
        const SizedBox(height: 14),
        Text(name, style: AppText.serif(size: 21)),
        const SizedBox(height: 3),
        Text(
          email,
          style: AppText.sans(size: 12.5, color: AppColors.muted),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.forestSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Administrator',
              style: AppText.sans(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // Menu
  // ============================================================

  List<Widget> _buildMenu(BuildContext context) {
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.person_outline_rounded,
        label: 'Edit profile',
        onTap: () => _openEditProfile(context),
      ),
      if (!isAdmin) ...[
        _MenuEntry(
          icon: Icons.receipt_long_outlined,
          label: 'My orders',
          onTap: () => UserMainScreen.of(context)?.goToTab(3),
        ),
        _MenuEntry(
          icon: Icons.favorite_border_rounded,
          label: 'Favorites',
          onTap: () {
            Navigator.push(
              context,
              BloomPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
        ),
        _MenuEntry(
          icon: Icons.location_on_outlined,
          label: 'Delivery address',
          onTap: () => _openEditProfile(context),
        ),
        _MenuEntry(
          icon: Icons.payments_outlined,
          label: 'Payment methods',
          onTap: () => showBloomSnack(
            context,
            'Bloom currently accepts cash on delivery.',
          ),
        ),
      ],
      _MenuEntry(
        icon: Icons.help_outline_rounded,
        label: 'Help & support',
        onTap: () => _showSupport(context),
      ),
      _MenuEntry(
        icon: Icons.info_outline_rounded,
        label: 'About Bloom',
        onTap: () => _showAbout(context),
      ),
    ];

    return [
      for (var i = 0; i < entries.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FadeSlideIn(
            delay: Duration(milliseconds: 90 + (i * 55)),
            child: _MenuTile(entry: entries[i]),
          ),
        ),
    ];
  }

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      BloomPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _showSupport(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(26, 4, 26, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help & support', style: AppText.serif(size: 21)),
              const SizedBox(height: 8),
              Text(
                'Our florists are here every day from 9:00 AM to 9:00 PM.',
                style: AppText.sans(
                  size: 13,
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              _contactRow(Icons.mail_outline_rounded, 'care@bloomflowers.app'),
              const SizedBox(height: 12),
              _contactRow(Icons.phone_outlined, '+970 59 000 0000'),
              const SizedBox(height: 12),
              _contactRow(
                Icons.chat_bubble_outline_rounded,
                'Live chat inside the app — coming soon',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.blush,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: AppColors.coral),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: AppText.sans(size: 13))),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BloomLogo(markSize: 46, titleSize: 21),
              const SizedBox(height: 18),
              Text(
                'More than flowers.. it\'s a feeling.\n\n'
                'Bloom Flowers delivers hand-arranged bouquets, plants and '
                'gifts for every moment worth celebrating.',
                textAlign: TextAlign.center,
                style: AppText.sans(
                  size: 13,
                  color: AppColors.muted,
                  height: 1.7,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Bloom?'),
        content: Text(
          'You will need to sign in again to place new orders.',
          style: AppText.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      BloomPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuEntry entry;

  const _MenuTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return BloomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: entry.onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.creamDeep,
              shape: BoxShape.circle,
            ),
            child: Icon(entry.icon, size: 18, color: AppColors.forest),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              entry.label,
              style: AppText.sans(size: 13.5, weight: FontWeight.w500),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.taupe,
          ),
        ],
      ),
    );
  }
}
