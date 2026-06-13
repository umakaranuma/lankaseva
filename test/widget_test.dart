import 'package:flutter_test/flutter_test.dart';

import 'package:lankaseva/app/data/models/service_model.dart';

/// Unit tests for opening-hours logic. The directory itself is no longer
/// bundled — it is loaded from the backend at runtime (see api_models_test
/// for the JSON mappers), so there is nothing static to assert here.
void main() {
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
}
