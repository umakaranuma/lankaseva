import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';

/// ---------------------------------------------------------------------------
/// OnboardingScreen — three swipeable value slides shown before any
/// permission ask (spec 4.2). Skip and Get-started both continue to
/// Language Selection (spec 6 navigation tree).
/// ---------------------------------------------------------------------------
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  /// Slide content: (icon, headline key, sub key) — copy from spec 4.2.
  static const _slides = [
    (Icons.grid_view_outlined, 'onb1_title', 'onb1_sub'),
    (Icons.phone_in_talk_outlined, 'onb2_title', 'onb2_sub'),
    (Icons.star_outline, 'onb3_title', 'onb3_sub'),
  ];

  /// Advances a slide, or finishes onboarding from the last slide.
  void _next() {
    if (_page < _slides.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  /// Hands off to Language Selection (first-run flow continues there).
  void _finish() => Get.offNamed(Routes.language);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button — top right (spec).
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('skip'.tr,
                    style:
                        AppTextStyles.body.copyWith(color: c.textTertiary)),
              ),
            ),
            // Swipeable slides.
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (icon, title, sub) = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(AppDimens.space6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                              color: c.primaryLight, shape: BoxShape.circle),
                          child: Icon(icon, size: 64, color: c.primary),
                        ),
                        const SizedBox(height: AppDimens.space6),
                        Text(title.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading1
                                .copyWith(color: c.textPrimary)),
                        const SizedBox(height: AppDimens.space3),
                        Text(sub.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body
                                .copyWith(color: c.textSecondary)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Progress dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? c.primary : c.borderMedium,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),
            ),
            // Next / Get started.
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page == _slides.length - 1
                      ? 'get_started'.tr
                      : 'next'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
