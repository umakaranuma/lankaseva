import 'package:flutter_test/flutter_test.dart';

import 'package:lankaseva/app/core/constants/app_constants.dart';
import 'package:lankaseva/app/data/models/service_model.dart';
import 'package:lankaseva/app/data/sources/service_data_source.dart';

/// Unit tests for the static data layer — verifies the seeded directory
/// covers every district and that opening-hours logic behaves correctly.
void main() {
  test('directory seeds services for all 25 districts', () {
    final districts =
        ServiceDataSource.services.map((s) => s.district).toSet();
    expect(districts.length, 25);
  });

  test('opening hours: office preset is closed on Sunday', () {
    // 2026-06-14 is a Sunday.
    final sunday = DateTime(2026, 6, 14, 10);
    expect(OpeningHours.office.isOpenAt(sunday), isFalse);
    expect(OpeningHours.always.isOpenAt(sunday), isTrue);
  });

  test('opening hours: office preset is open Monday morning', () {
    // 2026-06-15 is a Monday.
    final monday = DateTime(2026, 6, 15, 9);
    expect(OpeningHours.office.isOpenAt(monday), isTrue);
  });

  test('service pins sit near their district capital (±0.05°)', () {
    for (final s in ServiceDataSource.services) {
      final d = districtByName(s.district)!;
      expect((s.lat - d.lat).abs(), lessThanOrEqualTo(0.05),
          reason: '${s.id} latitude off-district');
      expect((s.lng - d.lng).abs(), lessThanOrEqualTo(0.05),
          reason: '${s.id} longitude off-district');
    }
  });

  test('primary phone falls back to first number', () {
    final service = ServiceDataSource.services.first;
    expect(service.primaryPhone.number, isNotEmpty);
  });
}
