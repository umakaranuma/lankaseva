import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/geocoding_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';

/// ---------------------------------------------------------------------------
/// ServiceMapScreen — opened from the map icon on a Service Detail page.
/// Shows the service's exact location pinned on OpenStreetMap and, when
/// location permission is granted, draws the driving path from the user's
/// current position to the place (free OSRM routing) with a distance /
/// duration banner. Falls back gracefully:
///   • permission refused → destination pin only
///   • router unreachable → straight line + air distance
/// All route logic lives in LocationController; this screen only renders.
/// ---------------------------------------------------------------------------
class ServiceMapScreen extends StatefulWidget {
  const ServiceMapScreen({super.key});

  @override
  State<ServiceMapScreen> createState() => _ServiceMapScreenState();
}

class _ServiceMapScreenState extends State<ServiceMapScreen> {
  final MapController _mapController = MapController();
  late final Service _service;

  /// Exact destination (geocoded when available, seeded otherwise).
  late final (double, double) _target;

  @override
  void initState() {
    super.initState();
    _service = Get.arguments as Service;
    final geocoder = Get.find<GeocodingController>();
    geocoder.ensureResolved([_service]);
    _target = geocoder.positionOf(_service);
    // Kick off the permission → GPS → route pipeline after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final location = Get.find<LocationController>();
      await location.buildRouteTo(_target.$1, _target.$2);
      _fitCamera(location);
    });
  }

  @override
  void dispose() {
    // Route state is screen-scoped — clear it so the next view starts clean.
    Get.find<LocationController>().clearRoute();
    super.dispose();
  }

  /// Fits the camera to show the whole route, or centres on the
  /// destination when there is no route.
  void _fitCamera(LocationController location) {
    if (!mounted) return;
    final points = location.routePoints;
    if (points.length >= 2) {
      _mapController.fitCamera(CameraFit.coordinates(
        coordinates: [for (final p in points) LatLng(p.$1, p.$2)],
        padding: const EdgeInsets.all(48),
      ));
    } else {
      _mapController.move(LatLng(_target.$1, _target.$2), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final location = Get.find<LocationController>();
    final c = AppColors.of(context);
    final meta = categoryMeta(_service.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(_service.name.of(app.language.value),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          // External hand-off to Google/Apple Maps for turn-by-turn.
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'directions'.tr,
            onPressed: () => app.openMap(_target.$1, _target.$2,
                _service.name.of(app.language.value)),
          ),
        ],
      ),
      body: Obx(() {
        final fix = location.position.value;
        final route = location.routePoints;
        final info = location.routeInfo.value;

        return Stack(children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_target.$1, _target.$2),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lankaseva',
              ),
              // Driving path polyline (user → service).
              if (route.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: [for (final p in route) LatLng(p.$1, p.$2)],
                    strokeWidth: 5,
                    color: c.info,
                  ),
                ]),
              MarkerLayer(markers: [
                // Destination pin (category-coloured).
                Marker(
                  point: LatLng(_target.$1, _target.$2),
                  width: 44,
                  height: 44,
                  child: Icon(Icons.location_pin, size: 42, color: meta.color),
                ),
                // User position blue dot (when permission was granted).
                if (fix != null)
                  Marker(
                    point: LatLng(fix.latitude, fix.longitude),
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
              ]),
              const RichAttributionWidget(attributions: [
                TextSourceAttribution('OpenStreetMap'),
              ]),
            ],
          ),

          // Loading veil while permission/GPS/route are being resolved.
          if (location.isLocating.value || location.isRouting.value)
            const Positioned(
              top: AppDimens.space3,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),

          // Route summary banner: distance + estimated drive time.
          if (info != null)
            Positioned(
              left: AppDimens.space4,
              right: AppDimens.space4,
              bottom: AppDimens.space4,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.space3),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: c.borderLight),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(children: [
                  Icon(Icons.directions_car_outlined, color: c.info),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Text(
                      info.durationMin > 0
                          ? '${info.distanceKm.toStringAsFixed(1)} km · ${info.durationMin.round()} min'
                          : '${info.distanceKm.toStringAsFixed(1)} km',
                      style: AppTextStyles.heading3
                          .copyWith(color: c.textPrimary),
                    ),
                  ),
                  // One-tap call straight from the route view.
                  IconButton(
                    style:
                        IconButton.styleFrom(backgroundColor: c.primaryLight),
                    icon: Icon(Icons.phone, size: 20, color: c.primary),
                    onPressed: () =>
                        app.callNumber(_service.primaryPhone.number),
                  ),
                ]),
              ),
            ),
        ]);
      }),
    );
  }
}
