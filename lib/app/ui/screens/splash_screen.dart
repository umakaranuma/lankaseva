import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// SplashScreen — brand moment on cold launch (spec 4.1).
/// Professional treatment: primary gradient backdrop, staged entrance
/// animation (logo scales/fades in, then wordmark and tagline slide up),
/// trilingual tagline, and a pinned footer with a subtle progress
/// indicator + version. Routes onward after 2.2 s via AppController.
/// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  /// Logo: scale 0.7→1.0 with a gentle overshoot, fading in first.
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  /// Wordmark + tagline: fade and slide up slightly after the logo.
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _logoFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut));
    _textFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic)));
    _entrance.forward();

    // Brand pause, then route: onboarding (first run) or main shell.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Get.offAllNamed(Get.find<AppController>().startRoute);
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: Container(
        // Subtle top-to-bottom brand gradient instead of a flat fill.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.primary, c.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- Centre block: logo + wordmark + tagline ----
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo medallion with soft ring.
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                              border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.25),
                                  width: 2),
                            ),
                            child: const Icon(Icons.shield_outlined,
                                size: 56, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.space6),
                      // Wordmark + trilingual tagline.
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(AppInfo.appName,
                                  style: AppTextStyles.display.copyWith(
                                      color: Colors.white,
                                      fontSize: 32,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: AppDimens.space1),
                              Text(AppInfo.appNameLatin.toUpperCase(),
                                  style: AppTextStyles.sectionLabel.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
                                      letterSpacing: 4)),
                              const SizedBox(height: AppDimens.space5),
                              // Divider accent.
                              Container(
                                  width: 36,
                                  height: 2,
                                  color:
                                      Colors.white.withValues(alpha: 0.35)),
                              const SizedBox(height: AppDimens.space5),
                              Text('app_tagline'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.9))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- Pinned footer: progress + version ----
              FadeTransition(
                opacity: _textFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space6),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: AppDimens.space3),
                      Text('v${AppInfo.version}',
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
