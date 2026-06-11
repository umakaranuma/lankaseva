import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// MapScreen — district map of services (spec 4.10).
/// The Google Maps SDK needs an API key + native config, so this build ships
/// a lightweight schematic "pin board" (category-coloured markers laid out
/// by lat/lng) with the same controls: category filter chips, map/list
/// toggle and a mini-card bottom sheet per marker. Swapping in
/// google_maps_flutter later only replaces the _SchematicMap widget.
/// ---------------------------------------------------------------------------
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final directory = Get.find<DirectoryController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('tab_map'.tr),
        actions: [
          // Map / List toggle (spec 4.10).
          Obx(() => IconButton(
                icon: Icon(directory.mapAsList.value
                    ? Icons.map_outlined
                    : Icons.list),
                onPressed: directory.toggleMapAsList,
              )),
        ],
      ),
      body: Obx(() {
        final lang = app.language.value;
        final services = directory.mapServices();
        return Column(
          children: [
            // Category filter chips (horizontal scroll above map).
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppDimens.space3),
              child: Row(children: [
                for (final meta in kCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.space2),
                    child: FilterChip(
                      avatar: Icon(meta.icon, size: 16, color: meta.color),
                      label: Text(meta.name(lang),
                          style: const TextStyle(fontSize: 12)),
                      selected: directory.mapCategory.value == meta.id,
                      onSelected: (_) => directory.setMapCategory(meta.id),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: directory.mapAsList.value
                  // List presentation — same results as the map.
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space4),
                      itemCount: services.length,
                      itemBuilder: (_, i) =>
                          ServiceCard(service: services[i]),
                    )
                  // Schematic pin-board map.
                  : services.isEmpty
                      ? EmptyState(
                          icon: Icons.map_outlined,
                          message: 'no_results'
                              .trParams({'query': app.district.value}))
                      : _SchematicMap(services: services),
            ),
          ],
        );
      }),
    );
  }
}

/// Positions category-coloured pins proportionally to lat/lng inside the
/// available canvas. Tapping a pin opens the service mini-card sheet.
class _SchematicMap extends StatelessWidget {
  final List services;
  const _SchematicMap({required this.services});

  /// Opens the bottom-sheet mini-card for one marker (spec 4.10).
  void _showMiniCard(BuildContext context, dynamic service) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.space4),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(service.name.of(app.language.value),
                style:
                    AppTextStyles.heading2.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppDimens.space1),
            Text('${service.district} · ${service.distanceKm.toStringAsFixed(1)} km',
                style:
                    AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppDimens.space4),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.serviceDetail, arguments: service);
              },
              child: Text('see_all'.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Normalise lat/lng to the canvas bounds.
    final lats = services.map((s) => s.lat as double).toList();
    final lngs = services.map((s) => s.lng as double).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(builder: (context, box) {
      double x(double lng) => maxLng == minLng
          ? box.maxWidth / 2
          : 24 + (lng - minLng) / (maxLng - minLng) * (box.maxWidth - 64);
      double y(double lat) => maxLat == minLat
          ? box.maxHeight / 2
          : 24 + (maxLat - lat) / (maxLat - minLat) * (box.maxHeight - 80);

      return Container(
        margin: const EdgeInsets.all(AppDimens.space4),
        decoration: BoxDecoration(
          color: c.primaryLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: c.borderLight),
        ),
        child: Stack(children: [
          for (final s in services)
            Positioned(
              left: x(s.lng),
              top: y(s.lat),
              child: GestureDetector(
                onTap: () => _showMiniCard(context, s),
                child: Icon(Icons.location_pin,
                    size: 32, color: categoryMeta(s.category).color),
              ),
            ),
        ]),
      );
    });
  }
}
