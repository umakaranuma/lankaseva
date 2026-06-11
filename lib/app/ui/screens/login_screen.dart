import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// LoginScreen — three-step OTP verification for +94 numbers (spec 4.13):
/// phone → OTP (with 60 s resend countdown) → display name (first login).
/// Browsing always remains available via the back button. All flow state
/// lives in AuthController; this screen only renders the active step.
/// ---------------------------------------------------------------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('login_title'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space4),
          child: Obx(() {
            // Render the active wizard step.
            final step = auth.step.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimens.space5),
                if (step == 0) ..._phoneStep(auth, c),
                if (step == 1) ..._otpStep(auth, c),
                if (step == 2) ..._nameStep(auth, c),
                const Spacer(),
                // Privacy assurance (spec: displayed on this screen).
                Text('privacy_note'.tr,
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.caption.copyWith(color: c.textTertiary)),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Step 1 — phone entry with the +94 country code locked.
  List<Widget> _phoneStep(AuthController auth, AppColors c) => [
        Text('login_title'.tr,
            style: AppTextStyles.heading1.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppDimens.space4),
        Row(children: [
          // Locked country code chip.
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space3, vertical: AppDimens.space3),
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Text('+94',
                style: AppTextStyles.heading2.copyWith(color: c.textPrimary)),
          ),
          const SizedBox(width: AppDimens.space2),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              maxLength: 9,
              style: AppTextStyles.heading2.copyWith(
                  color: c.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()]),
              decoration: InputDecoration(
                  hintText: 'phone_hint'.tr, counterText: ''),
              onChanged: auth.onPhoneChanged,
            ),
          ),
        ]),
        if (auth.error.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space2),
            child: Text(auth.error.value,
                style: AppTextStyles.caption.copyWith(color: c.emergency)),
          ),
        const SizedBox(height: AppDimens.space4),
        ElevatedButton(onPressed: auth.sendOtp, child: Text('send_otp'.tr)),
      ];

  /// Step 2 — 6-digit OTP entry with resend countdown.
  List<Widget> _otpStep(AuthController auth, AppColors c) => [
        Text('enter_otp'.tr,
            style: AppTextStyles.heading1.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppDimens.space1),
        Text('+94 ${auth.phone.value}',
            style: AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppDimens.space4),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
              color: c.textPrimary,
              letterSpacing: 12,
              fontFeatures: const [FontFeature.tabularFigures()]),
          decoration: const InputDecoration(counterText: '', hintText: '••••••'),
          onChanged: auth.onOtpChanged,
        ),
        if (auth.error.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space2),
            child: Text(auth.error.value,
                style: AppTextStyles.caption.copyWith(color: c.emergency)),
          ),
        const SizedBox(height: AppDimens.space4),
        ElevatedButton(onPressed: auth.verifyOtp, child: Text('verify'.tr)),
        // Resend with 60-second countdown (spec 4.13).
        TextButton(
          onPressed: auth.resendCountdown.value == 0 ? auth.resendOtp : null,
          child: Text(auth.resendCountdown.value == 0
              ? 'resend_otp'.tr
              : 'resend_in'
                  .trParams({'secs': '${auth.resendCountdown.value}'})),
        ),
      ];

  /// Step 3 — public display name (first login only).
  List<Widget> _nameStep(AuthController auth, AppColors c) {
    final nameController = TextEditingController();
    return [
      Text('display_name'.tr,
          style: AppTextStyles.heading1.copyWith(color: c.textPrimary)),
      const SizedBox(height: AppDimens.space1),
      Text('display_name_hint'.tr,
          style: AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
      const SizedBox(height: AppDimens.space4),
      TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words),
      if (auth.error.value.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.space2),
          child: Text(auth.error.value,
              style: AppTextStyles.caption.copyWith(color: c.emergency)),
        ),
      const SizedBox(height: AppDimens.space4),
      ElevatedButton(
          onPressed: () => auth.completeProfile(nameController.text),
          child: Text('continue'.tr)),
    ];
  }
}
