import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_dimens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// SavedServicesScreen — dedicated list of bookmarked services, opened
/// from Settings → Saved Services. Reuses the standard ServiceCard (with
/// its heart toggle, call button and detail navigation) so unsaving here
/// removes the card live. Bookmark state lives in AppController.
/// ---------------------------------------------------------------------------
class SavedServicesScreen extends StatelessWidget {
  const SavedServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(title: Text('saved_services'.tr)),
      body: Obx(() {
        final saved = app.savedServices;
        if (saved.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border,
            message: 'no_saved'.tr,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimens.space4),
          itemCount: saved.length,
          itemBuilder: (_, i) => ServiceCard(service: saved[i]),
        );
      }),
    );
  }
}
