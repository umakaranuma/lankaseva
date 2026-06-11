import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';

/// ---------------------------------------------------------------------------
/// ServiceDataSource
/// ---------------------------------------------------------------------------
/// Static, offline-first data layer (spec 5.1: "Static data model — no
/// complex server required for browsing"). In production this would be a
/// SQLite cache synced from the REST API; for this build all 25 districts
/// are seeded locally so every screen is fully functional offline.
///
/// Controllers MUST go through this class — never hold raw data themselves.
/// ---------------------------------------------------------------------------
class ServiceDataSource {
  ServiceDataSource._();

  /// Memoised full directory: a curated Colombo set plus generated core
  /// services (hospital, police, secretariat, post office, CEB, water board)
  /// for every one of the 25 districts.
  static final List<Service> services = _buildDirectory();

  /// Seed community reviews so review screens have content on first launch.
  static final List<Review> seedReviews = _buildSeedReviews();

  /// Finds a single service by id (returns null when not found).
  static Service? byId(String id) {
    for (final s in services) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Directory construction
  // ---------------------------------------------------------------------

  /// Builds the full national directory list.
  static List<Service> _buildDirectory() {
    final rng = Random(7); // Fixed seed → stable demo distances
    final list = <Service>[];

    // Per-district core services common to all 25 districts.
    for (final d in kDistricts) {
      final base = d.name.toLowerCase().replaceAll(' ', '_');
      double dist() => (rng.nextDouble() * 12 + 0.4);
      // Real-world pin positions: scattered within ~±3 km of the district
      // capital so map markers land in plausible town locations.
      double jLat() => d.lat + (rng.nextDouble() - 0.5) * 0.05;
      double jLng() => d.lng + (rng.nextDouble() - 0.5) * 0.05;

      list.addAll([
        Service(
          id: '${base}_hospital',
          name: LocalizedText(
              en: '${d.name} General Hospital',
              si: '${d.name} මහ රෝහල',
              ta: '${d.name} பொது மருத்துவமனை'),
          department: const LocalizedText(
              en: 'Ministry of Health',
              si: 'සෞඛ්‍ය අමාත්‍යාංශය',
              ta: 'சுகாதார அமைச்சு'),
          category: ServiceCategory.hospital,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'Main line', si: 'ප්‍රධාන මාර්ගය', ta: 'முதன்மை இணைப்பு'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
            const ServicePhone(
                label: LocalizedText(
                    en: 'Emergency / ETU', si: 'හදිසි ඒකකය', ta: 'அவசர பிரிவு'),
                number: '1990'),
          ],
          address: LocalizedText(
              en: 'Hospital Road, ${d.name}',
              si: 'රෝහල් පාර, ${d.name}',
              ta: 'மருத்துவமனை சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.always,
          isEmergency: true,
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_police',
          name: LocalizedText(
              en: '${d.name} Police Station',
              si: '${d.name} පොලිස් ස්ථානය',
              ta: '${d.name} காவல் நிலையம்'),
          department: const LocalizedText(
              en: 'Sri Lanka Police',
              si: 'ශ්‍රී ලංකා පොලිසිය',
              ta: 'இலங்கை காவல்துறை'),
          category: ServiceCategory.police,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(en: 'OIC', si: 'ස්ථානාධිපති', ta: 'OIC'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
            const ServicePhone(
                label: LocalizedText(
                    en: 'Emergency', si: 'හදිසි', ta: 'அவசரம்'),
                number: '119'),
          ],
          address: LocalizedText(
              en: 'Station Road, ${d.name}',
              si: 'ස්ටේෂන් පාර, ${d.name}',
              ta: 'நிலைய சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.always,
          isEmergency: true,
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_secretariat',
          name: LocalizedText(
              en: '${d.name} District Secretariat',
              si: '${d.name} දිස්ත්‍රික් ලේකම් කාර්යාලය',
              ta: '${d.name} மாவட்ட செயலகம்'),
          department: const LocalizedText(
              en: 'Ministry of Public Administration',
              si: 'රාජ්‍ය පරිපාලන අමාත්‍යාංශය',
              ta: 'பொது நிர்வாக அமைச்சு'),
          category: ServiceCategory.government,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'General', si: 'පොදු', ta: 'பொது'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'District Secretariat, ${d.name}',
              si: 'දිස්ත්‍රික් ලේකම් කාර්යාලය, ${d.name}',
              ta: 'மாவட்ட செயலகம், ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.office,
          website: 'https://www.${base.replaceAll('_', '')}.dist.gov.lk',
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_ceb',
          name: LocalizedText(
              en: 'CEB Area Office — ${d.name}',
              si: 'ලංවිම ප්‍රාදේශීය කාර්යාලය — ${d.name}',
              ta: 'CEB பகுதி அலுவலகம் — ${d.name}'),
          department: const LocalizedText(
              en: 'Ceylon Electricity Board',
              si: 'ලංකා විදුලිබල මණ්ඩලය',
              ta: 'இலங்கை மின்சார சபை'),
          category: ServiceCategory.electricity,
          district: d.name,
          phones: [
            const ServicePhone(
                label: LocalizedText(
                    en: 'Breakdown hotline', si: 'බිඳවැටීම් අංකය', ta: 'பழுது இணைப்பு'),
                number: '1987',
                isPrimary: true),
            ServicePhone(
                label: const LocalizedText(
                    en: 'Area office', si: 'ප්‍රාදේශීය කාර්යාලය', ta: 'பகுதி அலுவலகம்'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}'),
          ],
          address: LocalizedText(
              en: 'Main Street, ${d.name}',
              si: 'ප්‍රධාන වීදිය, ${d.name}',
              ta: 'பிரதான வீதி, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.always,
          website: 'https://www.ceb.lk',
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_water',
          name: LocalizedText(
              en: 'NWSDB Regional Office — ${d.name}',
              si: 'ජල මණ්ඩල කාර්යාලය — ${d.name}',
              ta: 'NWSDB பிராந்திய அலுவலகம் — ${d.name}'),
          department: const LocalizedText(
              en: 'National Water Supply & Drainage Board',
              si: 'ජාතික ජල සම්පාදන මණ්ඩලය',
              ta: 'தேசிய நீர் வழங்கல் வாரியம்'),
          category: ServiceCategory.water,
          district: d.name,
          phones: [
            const ServicePhone(
                label: LocalizedText(
                    en: 'Hotline', si: 'ක්ෂණික අංකය', ta: 'அவசர இணைப்பு'),
                number: '1954',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'Water Board Road, ${d.name}',
              si: 'ජල මණ්ඩල පාර, ${d.name}',
              ta: 'நீர் வாரிய சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.office,
          website: 'https://www.waterboard.lk',
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_post',
          name: LocalizedText(
              en: '${d.name} Main Post Office',
              si: '${d.name} ප්‍රධාන තැපැල් කාර්යාලය',
              ta: '${d.name} பிரதான அஞ்சலகம்'),
          department: const LocalizedText(
              en: 'Sri Lanka Post',
              si: 'ශ්‍රී ලංකා තැපැල්',
              ta: 'இலங்கை அஞ்சல்'),
          category: ServiceCategory.post,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'Counter', si: 'කවුන්ටරය', ta: 'கவுண்டர்'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'Post Office Road, ${d.name}',
              si: 'තැපැල් කාර්යාල පාර, ${d.name}',
              ta: 'அஞ்சலக சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.office,
          website: 'https://slpost.gov.lk',
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_court',
          name: LocalizedText(
              en: '${d.name} Magistrate\'s Court',
              si: '${d.name} මහේස්ත්‍රාත් අධිකරණය',
              ta: '${d.name} நீதவான் நீதிமன்றம்'),
          department: const LocalizedText(
              en: 'Ministry of Justice',
              si: 'අධිකරණ අමාත්‍යාංශය',
              ta: 'நீதி அமைச்சு'),
          category: ServiceCategory.court,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'Registrar', si: 'රෙජිස්ට්‍රාර්', ta: 'பதிவாளர்'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'Courts Complex, ${d.name}',
              si: 'අධිකරණ සංකීර්ණය, ${d.name}',
              ta: 'நீதிமன்ற வளாகம், ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.office,
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_school',
          name: LocalizedText(
              en: '${d.name} Zonal Education Office',
              si: '${d.name} කලාප අධ්‍යාපන කාර්යාලය',
              ta: '${d.name} வலயக் கல்வி அலுவலகம்'),
          department: const LocalizedText(
              en: 'Ministry of Education',
              si: 'අධ්‍යාපන අමාත්‍යාංශය',
              ta: 'கல்வி அமைச்சு'),
          category: ServiceCategory.school,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'Office', si: 'කාර්යාලය', ta: 'அலுவலகம்'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'Education Office Road, ${d.name}',
              si: 'අධ්‍යාපන කාර්යාල පාර, ${d.name}',
              ta: 'கல்வி அலுவலக சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: OpeningHours.office,
          distanceKm: dist(),
        ),
        Service(
          id: '${base}_transport',
          name: LocalizedText(
              en: 'SLTB Depot — ${d.name}',
              si: 'ලංගම ඩිපෝව — ${d.name}',
              ta: 'SLTB டிப்போ — ${d.name}'),
          department: const LocalizedText(
              en: 'Sri Lanka Transport Board',
              si: 'ශ්‍රී ලංකා ගමනාගමන මණ්ඩලය',
              ta: 'இலங்கை போக்குவரத்து சபை'),
          category: ServiceCategory.transport,
          district: d.name,
          phones: [
            ServicePhone(
                label: const LocalizedText(
                    en: 'Depot', si: 'ඩිපෝව', ta: 'டிப்போ'),
                number: '0${11 + rng.nextInt(80)}${2000000 + rng.nextInt(7999999)}',
                isPrimary: true),
          ],
          address: LocalizedText(
              en: 'Bus Stand Road, ${d.name}',
              si: 'බස් නැවතුම් පාර, ${d.name}',
              ta: 'பேருந்து நிலைய சாலை, ${d.name}'),
          lat: jLat(),
          lng: jLng(),
          hours: const OpeningHours(byWeekday: {
            1: ('05:00', '21:00'),
            2: ('05:00', '21:00'),
            3: ('05:00', '21:00'),
            4: ('05:00', '21:00'),
            5: ('05:00', '21:00'),
            6: ('05:00', '21:00'),
            7: ('06:00', '20:00'),
          }),
          distanceKm: dist(),
        ),
      ]);
    }

    // Curated national flagship entries (richer detail for the demo).
    list.add(Service(
      id: 'colombo_nhsl',
      name: const LocalizedText(
          en: 'National Hospital of Sri Lanka',
          si: 'ශ්‍රී ලංකා ජාතික රෝහල',
          ta: 'இலங்கை தேசிய மருத்துவமனை'),
      department: const LocalizedText(
          en: 'Ministry of Health',
          si: 'සෞඛ්‍ය අමාත්‍යාංශය',
          ta: 'சுகாதார அமைச்சு'),
      category: ServiceCategory.hospital,
      district: 'Colombo',
      phones: const [
        ServicePhone(
            label: LocalizedText(en: 'General', si: 'පොදු', ta: 'பொது'),
            number: '0112691111',
            isPrimary: true),
        ServicePhone(
            label: LocalizedText(
                en: 'Accident service', si: 'හදිසි අනතුරු', ta: 'விபத்து சேவை'),
            number: '0112691111'),
      ],
      address: const LocalizedText(
          en: 'Regent Street, Colombo 10',
          si: 'රීජන්ට් වීදිය, කොළඹ 10',
          ta: 'ரீஜண்ட் தெரு, கொழும்பு 10'),
      lat: 6.9176,
      lng: 79.8672,
      hours: OpeningHours.always,
      website: 'https://www.nhsl.health.gov.lk',
      whatsapp: '+94112691111',
      isEmergency: true,
      distanceKm: 1.2,
    ));

    return list;
  }

  // ---------------------------------------------------------------------
  // Seed reviews
  // ---------------------------------------------------------------------

  /// Builds a handful of believable seed reviews spread across districts so
  /// the Reviews tab and Service Detail screens are populated on day one.
  static List<Review> _buildSeedReviews() {
    final now = DateTime.now();
    Review r(String id, String serviceId, String name, int stars, String text,
            int daysAgo, int helpful,
            {List<String> pos = const [], List<String> neg = const []}) =>
        Review(
          id: id,
          serviceId: serviceId,
          userId: 'seed_$id',
          displayName: name,
          stars: stars,
          text: text,
          positiveTags: pos,
          negativeTags: neg,
          helpfulCount: helpful,
          createdAt: now.subtract(Duration(days: daysAgo)),
        );

    return [
      r('s1', 'colombo_nhsl', 'Nimal Perera', 5,
          'Accident service responded very quickly. Staff were kind and the process was clear even at midnight.',
          3, 14,
          pos: ['tag_helpful_staff', 'tag_fast_response']),
      r('s2', 'colombo_nhsl', 'Tharindu S', 4,
          'OPD queue was long but the doctors were thorough. Bring your clinic book.',
          9, 6,
          pos: ['tag_accurate_info'], neg: ['tag_long_wait']),
      r('s3', 'colombo_ceb', 'Fathima R', 3,
          'Breakdown hotline 1987 answered after a few tries. Power was restored in about two hours.',
          5, 4,
          neg: ['tag_hard_to_reach']),
      r('s4', 'colombo_police', 'Kasun J', 5,
          'Reported a lost NIC and received the report in fifteen minutes. Very professional.',
          1, 9,
          pos: ['tag_fast_response', 'tag_helpful_staff']),
      r('s5', 'kandy_hospital', 'Sivakumar V', 4,
          'Clean wards and helpful nurses. Parking is difficult during clinic hours.',
          12, 3,
          pos: ['tag_helpful_staff'], neg: ['tag_long_wait']),
      r('s6', 'galle_water', 'Chamari W', 2,
          'Water cut notice was not updated. Hotline kept ringing without answer.',
          7, 11,
          neg: ['tag_outdated_info', 'tag_hard_to_reach']),
      r('s7', 'jaffna_secretariat', 'Anitha K', 5,
          'Got my certificate the same day. Counters are clearly numbered and staff guide you.',
          2, 8,
          pos: ['tag_easy_to_find', 'tag_fast_response']),
    ];
  }
}
