import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// WriteReviewScreen — authenticated review submission (spec 4.12).
/// Star picker, 20–500 character text area with live counter, optional
/// positive/negative experience tags, submit disabled until valid.
/// All form state lives in ReviewController.
/// ---------------------------------------------------------------------------
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the form every time the screen opens.
    Get.find<ReviewController>().startReview();
  }

  /// Submits via the controller; on success pops back with the toast.
  void _submit(Service service) {
    final reviews = Get.find<ReviewController>();
    if (reviews.submitReview(service.id)) {
      Get.back();
      Get.rawSnackbar(
          message: 'review_submitted'.tr,
          duration: const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Service service = Get.arguments as Service;
    final app = Get.find<AppController>();
    final reviews = Get.find<ReviewController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('write_review'.tr)),
      body: SafeArea(
        child: Obx(() => ListView(
              padding: const EdgeInsets.all(AppDimens.space4),
              children: [
                // Read-only service header.
                Text(service.name.of(app.language.value),
                    style:
                        AppTextStyles.heading2.copyWith(color: c.textPrimary)),
                const SizedBox(height: AppDimens.space4),

                // ---- Star picker (5 large tappable stars) ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = reviews.formStars.value > i;
                    return IconButton(
                      iconSize: 40,
                      icon: Icon(filled ? Icons.star : Icons.star_border,
                          color: c.star),
                      onPressed: () => reviews.setStars(i + 1),
                    );
                  }),
                ),
                const SizedBox(height: AppDimens.space3),

                // ---- Text area with live character counter ----
                TextField(
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'describe_experience'.tr,
                    helperText: reviews.formText.value.trim().length < 20
                        ? 'review_min_chars'.tr
                        : null,
                    counterText:
                        '${reviews.formText.value.length}/500',
                  ),
                  onChanged: reviews.onReviewTextChanged,
                ),
                const SizedBox(height: AppDimens.space4),

                // ---- Positive experience tags ----
                SectionLabel('what_went_well'.tr),
                Wrap(
                  spacing: AppDimens.space2,
                  runSpacing: AppDimens.space2,
                  children: [
                    for (final key in ReviewController.positiveTagKeys)
                      FilterChip(
                        label:
                            Text(key.tr, style: const TextStyle(fontSize: 12)),
                        selected: reviews.formPositiveTags.contains(key),
                        selectedColor: c.successLight,
                        onSelected: (_) =>
                            reviews.toggleTag(key, positive: true),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space4),

                // ---- Negative experience tags ----
                SectionLabel('what_could_improve'.tr),
                Wrap(
                  spacing: AppDimens.space2,
                  runSpacing: AppDimens.space2,
                  children: [
                    for (final key in ReviewController.negativeTagKeys)
                      FilterChip(
                        label:
                            Text(key.tr, style: const TextStyle(fontSize: 12)),
                        selected: reviews.formNegativeTags.contains(key),
                        selectedColor: c.warningLight,
                        onSelected: (_) =>
                            reviews.toggleTag(key, positive: false),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space6),

                // ---- Submit (disabled until stars + min text) ----
                ElevatedButton(
                  onPressed:
                      reviews.canSubmit ? () => _submit(service) : null,
                  child: Text('submit_review'.tr),
                ),
              ],
            )),
      ),
    );
  }
}
