import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_sheets.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// EditProfileScreen — full-page profile editor opened from the edit icon
/// on the Settings account card (replaces the old name-edit popup).
/// Shows a large photo avatar (tap → change/remove sheet), the display
/// name field with live validation, and the phone-privacy note. Saving
/// goes through AuthController and pops back with a toast.
/// ---------------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: Get.find<AuthController>().user.value?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Opens the change/remove photo actions as a bottom sheet.
  void _photoSheet(AuthController auth) {
    showActionsSheet([
      SheetAction(
        icon: Icons.photo_library_outlined,
        label: 'change_photo'.tr,
        onTap: auth.pickAvatar,
      ),
      if (auth.user.value?.avatarPath != null)
        SheetAction(
          icon: Icons.delete_outline,
          label: 'remove_photo'.tr,
          destructive: true,
          onTap: auth.removeAvatar,
        ),
    ]);
  }

  /// Persists the new display name to the database, then returns to Settings.
  /// Only reports success once the server confirms the update.
  bool _saving = false;

  Future<void> _save(AuthController auth) async {
    final name = _nameController.text.trim();
    if (name.length < 2 || _saving) return;
    setState(() => _saving = true);
    final ok = await auth.updateDisplayName(name);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      // Re-pull reviews so the new name (joined from the user table) shows
      // immediately wherever this user's reviews appear.
      Get.find<ReviewController>().load();
      Get.back();
      AppToast.show('profile_saved'.tr);
    } else {
      AppToast.show('profile_save_failed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('edit_profile'.tr)),
      body: SafeArea(
        child: Obx(() {
          final user = auth.user.value;
          if (user == null) return const SizedBox.shrink(); // Logged out
          return ListView(
            padding: const EdgeInsets.all(AppDimens.space5),
            children: [
              // ---- Large avatar with camera badge ----
              Center(
                child: GestureDetector(
                  onTap: () => _photoSheet(auth),
                  child: Stack(children: [
                    UserAvatar(
                        imagePath: user.avatarPath,
                        initials: user.initials,
                        size: 112),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.bgScreen, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppDimens.space2),
              Center(
                child: TextButton(
                  onPressed: () => _photoSheet(auth),
                  child: Text('change_photo'.tr),
                ),
              ),
              const SizedBox(height: AppDimens.space5),

              // ---- Display name ----
              SectionLabel('display_name'.tr),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                decoration: InputDecoration(
                  hintText: 'display_name_hint'.tr,
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}), // Re-evaluate save button
              ),
              const SizedBox(height: AppDimens.space1),
              Text('display_name_hint'.tr,
                  style:
                      AppTextStyles.caption.copyWith(color: c.textTertiary)),
              const SizedBox(height: AppDimens.space5),

              // ---- Read-only account facts ----
              SectionLabel('profile'.tr),
              Container(
                padding: const EdgeInsets.all(AppDimens.space3),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: c.borderLight),
                ),
                child: Row(children: [
                  Icon(Icons.verified_user_outlined,
                      size: 20, color: c.success),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Text(
                        'member_since'.trParams({
                          'date':
                              '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}'
                        }),
                        style: AppTextStyles.bodySm
                            .copyWith(color: c.textSecondary)),
                  ),
                ]),
              ),
              const SizedBox(height: AppDimens.space3),
              Text('privacy_note'.tr,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.caption.copyWith(color: c.textTertiary)),
              const SizedBox(height: AppDimens.space6),

              // ---- Save ----
              ElevatedButton(
                onPressed: (_nameController.text.trim().length >= 2 && !_saving)
                    ? () => _save(auth)
                    : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('save'.tr),
              ),
            ],
          );
        }),
      ),
    );
  }
}
