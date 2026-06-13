import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lankaseva/app/core/constants/app_constants.dart';
import 'package:lankaseva/app/data/models/review_model.dart';
import 'package:lankaseva/app/data/models/service_model.dart';
import 'package:lankaseva/app/data/sources/emergency_data_source.dart';

/// Verifies the fromJson mappers against real payload shapes captured from
/// the backend (`GET /api/services/<id>/` and `GET /api/reviews/`).
void main() {
  group('Service.fromJson', () {
    const sample = '''
    {"id":"colombo_nhsl",
     "phones":[{"label_en":"General","label_si":"පොදු","label_ta":"பொது","number":"0112691111","is_primary":true},
               {"label_en":"Accident service","label_si":"හදිසි අනතුරු","label_ta":"விபத்து சேவை","number":"0112691111","is_primary":false}],
     "hours":{"is_always_open":true,"notes":null,"days":[]},
     "name_en":"National Hospital of Sri Lanka","name_si":"ශ්‍රී ලංකා ජාතික රෝහල","name_ta":"இலங்கை தேசிய மருத்துவமனை",
     "department_en":"Ministry of Health","department_si":"සෞඛ්‍ය අමාත්‍යාංශය","department_ta":"சுகாதார அமைச்சு",
     "category":"hospital","district":"Colombo",
     "address_en":"Regent Street, Colombo 10","address_si":"රීජන්ට් වීදිය, කොළඹ 10","address_ta":"ரீஜண்ட் தெரு, கொழும்பு 10",
     "lat":6.9176,"lng":79.8672,
     "website":"https://www.nhsl.health.gov.lk","whatsapp":"+94112691111","is_emergency":true}
    ''';

    test('maps a 24/7 hospital', () {
      final s = Service.fromJson(jsonDecode(sample));
      expect(s.id, 'colombo_nhsl');
      expect(s.category, ServiceCategory.hospital);
      expect(s.name.of('si'), 'ශ්‍රී ලංකා ජාතික රෝහල');
      expect(s.primaryPhone.number, '0112691111');
      expect(s.hours.isAlwaysOpen, isTrue);
      expect(s.hours.isOpenAt(DateTime(2026, 6, 14, 3)), isTrue);
      expect(s.isEmergency, isTrue);
      expect(s.whatsapp, '+94112691111');
    });

    test('maps weekday hour slots into byWeekday', () {
      final json = jsonDecode(sample) as Map<String, dynamic>;
      json['hours'] = {
        'is_always_open': false,
        'notes': null,
        'days': [
          {'weekday': 1, 'open': '08:30', 'close': '16:15'},
          {'weekday': 6, 'open': '09:00', 'close': '12:00'},
        ],
      };
      final s = Service.fromJson(json);
      expect(s.hours.byWeekday[1], ('08:30', '16:15'));
      expect(s.hours.byWeekday[7], isNull); // Sunday closed
      // Monday 10:00 open, Monday 17:00 closed, Saturday 10:00 open.
      expect(s.hours.isOpenAt(DateTime(2026, 6, 15, 10)), isTrue);
      expect(s.hours.isOpenAt(DateTime(2026, 6, 15, 17)), isFalse);
      expect(s.hours.isOpenAt(DateTime(2026, 6, 20, 10)), isTrue);
    });
  });

  test('EmergencyDataSource starts empty (loaded from API only)', () {
    // No bundled data — both lists are filled by EmergencyDataSource.load().
    expect(EmergencyDataSource.hotlines, isEmpty);
    expect(EmergencyDataSource.quickDial, isEmpty);
  });

  test('Review.fromJson splits tags by polarity', () {
    final r = Review.fromJson(jsonDecode('''
      {"id":"rabc","service":"colombo_nhsl","user_id":"f6b2","display_name":"Uma Karan",
       "stars":4,"text":"Good service","helpful_count":2,
       "created_at":"2026-06-13T00:25:51.331483+05:30","edited_at":null,
       "tags":[{"tag_key":"tag_helpful_staff","is_positive":true},
               {"tag_key":"tag_long_wait","is_positive":false}]}
    '''));
    expect(r.serviceId, 'colombo_nhsl');
    expect(r.stars, 4);
    expect(r.positiveTags, ['tag_helpful_staff']);
    expect(r.negativeTags, ['tag_long_wait']);
    expect(r.helpfulCount, 2);
  });
}
