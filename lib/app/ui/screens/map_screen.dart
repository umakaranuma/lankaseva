import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../controllers/geocoding_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// MapScreen — real interactive district map (spec 4.10) built on
/// flutter_map + OpenStreetMap tiles (free, no API key). Features:
///   • category-coloured service markers at real district coordinates
///   • current-location button (full permission flow via LocationController)
///   • blue user-position marker once a GPS fix exists
///   • category filter chips + map/list toggle
///   • tap a marker → bottom-sheet mini-card → service detail
/// UI only — every behaviour delegates to a controller.
/// ---------------------------------------------------------------------------
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// flutter_map camera controller — view-layer concern, so it stays in the
  /// widget state (controllers own data/permissions, not map cameras).
  final MapController _mapController = MapController();

  /// Centres the camera on the active district's capital.
  LatLng _districtCenter() {
    final d = districtByName(Get.find<AppController>().district.value);
    return LatLng(d?.lat ?? 6.9271, d?.lng ?? 79.8612);
  }

  /// "My location" button: runs the permission + GPS flow in
  /// LocationController, then flies the camera to the fix.
  Future<void> _goToMyLocation() async {
    final location = Get.find<LocationController>();
    final fix = await location.getCurrentPosition();
    if (fix != null) {
      _mapController.move(LatLng(fix.latitude, fix.longitude), 14);
    }
  }

  /// Bottom-sheet mini-card for one marker (spec 4.10).
  void _showMiniCard(Service service) {
    final app = Get.find<AppController>();
    final directory = Get.find<DirectoryController>();
    final c = AppColors.of(context);
    final meta = categoryMeta(service.category);
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
            Row(children: [
              Icon(meta.icon, color: meta.color),
              const SizedBox(width: AppDimens.space2),
              Expanded(
                child: Text(service.name.of(app.language.value),
                    style: AppTextStyles.heading2
                        .copyWith(color: c.textPrimary)),
              ),
            ]),
            const SizedBox(height: AppDimens.space1),
            Text(
                '${service.district} · ${directory.distanceOf(service).toStringAsFixed(1)} km',
                style: AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppDimens.space4),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.serviceDetail, arguments: service);
                  },
                  child: Text('see_all'.tr),
                ),
              ),
              const SizedBox(width: AppDimens.space2),
              IconButton.outlined(
                icon: const Icon(Icons.phone),
                onPressed: () => app.callNumber(service.primaryPhone.number),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final directory = Get.find<DirectoryController>();
    final location = Get.find<LocationController>();
    final c = AppColors.of(context);

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
        final fix = location.position.value;
        final geocoder = Get.find<GeocodingController>();
        // Kick off exact-position lookups for the visible services
        // (idempotent; markers snap to the real place as results arrive).
        geocoder.ensureResolved(services);

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
                  : services.isEmpty
                      ? EmptyState(
                          icon: Icons.map_outlined,
                          message: 'no_results'
                              .trParams({'query': app.district.value}))
                      // Real OpenStreetMap with service + user markers.
                      : Stack(children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _districtCenter(),
                              initialZoom: 12,
                            ),
                            children: [
                              // Free OSM tile layer — no API key required.
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.lankaseva',
                              ),
                              MarkerLayer(markers: [
                                // Category-coloured service pins at the
                                // exact geocoded position (seeded estimate
                                // only until the lookup completes).
                                for (final s in services)
                                  Marker(
                                    point: LatLng(geocoder.positionOf(s).$1,
                                        geocoder.positionOf(s).$2),
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () => _showMiniCard(s),
                                      child: Icon(Icons.location_pin,
                                          size: 36,
                                          color: categoryMeta(s.category)
                                              .color),
                                    ),
                                  ),
                                // Blue dot for the user's GPS position.
                                if (fix != null)
                                  Marker(
                                    point: LatLng(
                                        fix.latitude, fix.longitude),
                                    width: 22,
                                    height: 22,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                      ),
                                    ),
                                  ),
                              ]),
                              // OSM attribution (required by tile policy).
                              const RichAttributionWidget(attributions: [
                                TextSourceAttribution('OpenStreetMap'),
                              ]),
                            ],
                          ),
                          // Current-location button (top right, spec 4.10).
                          Positioned(
                            top: AppDimens.space3,
                            right: AppDimens.space3,
                            child: FloatingActionButton.small(
                              heroTag: 'map_my_location',
                              backgroundColor: c.bgCard,
                              tooltip: 'my_location'.tr,
                              onPressed: location.isLocating.value
                                  ? null
                                  : _goToMyLocation,
                              child: location.isLocating.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Icon(Icons.my_location,
                                      color: c.primary),
                            ),
                          ),
                        ]),
            ),
          ],
        );
      }),
    );
  }
}
