import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/profile_providers.dart';
import '../../services/support_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';
import '../user/user_main_screen.dart';

/// Account hub. Shared by customers and admins; customer-only shortcuts are
/// hidden when [isAdmin] is true.
class ProfileScreen extends ConsumerWidget {
  final bool isAdmin;

  const ProfileScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);
    final profileService = ref.watch(profileServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<UserModel?>(
          stream: user == null ? null : profileService.watchProfile(user.uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;

            final name = (profile?.name.trim().isNotEmpty ?? false)
                ? profile!.name
                : user?.displayName ?? 'Bloom User';

            final imageUrl = profile?.imageUrl ?? '';

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
                    onPressed: () => _logout(context, ref),
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
          onTap: () => context.push(AppRoutes.favorites),
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
    context.push(AppRoutes.editProfile);
  }

  void _showSupport(BuildContext context) {
    final support = SupportService();

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
              _contactRow(
                icon: Icons.chat_rounded,
                value: 'Chat on WhatsApp',
                onTap: () => _openSupport(sheetContext, support.openWhatsApp),
              ),
              const SizedBox(height: 12),
              _contactRow(
                icon: Icons.phone_outlined,
                value: AppConfig.supportPhoneDisplay,
                onTap: () => _openSupport(sheetContext, support.openPhone),
              ),
              const SizedBox(height: 12),
              _contactRow(
                icon: Icons.mail_outline_rounded,
                value: AppConfig.supportEmail,
                onTap: () => _openSupport(sheetContext, support.openEmail),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSupport(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      showBloomSnack(context, 'Unable to open this right now.', isError: true);
    }
  }

  Widget _contactRow({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
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
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.taupe,
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
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

    await ref.read(authServiceProvider).logout();

    if (!context.mounted) return;

    context.go(AppRoutes.login);
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
