import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/review_model.dart';
import '../data/sources/service_data_source.dart';
import 'app_controller.dart';
import 'auth_controller.dart';
import '../ui/widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// ReviewController
/// ---------------------------------------------------------------------------
/// Single source of truth for the review system (spec 5.4):
///   • holds all reviews (seed + user-submitted, persisted locally)
///   • per-service aggregates: average, count, star distribution
///   • write-review form state and validation (stars + 20–500 chars,
///     phone-number filter, one review per user per service)
///   • helpful voting and the community feed with filters
/// ---------------------------------------------------------------------------
class ReviewController extends GetxController {
  static const _kUserReviews = 'user_reviews';

  late SharedPreferences _prefs;

  /// All reviews in the app, newest first.
  final RxList<Review> reviews = <Review>[].obs;

  // ---- Write-review form state (spec 4.12) ----
  final RxInt formStars = 0.obs;
  final RxString formText = ''.obs;
  final RxSet<String> formPositiveTags = <String>{}.obs;
  final RxSet<String> formNegativeTags = <String>{}.obs;

  // ---- Community feed filters (spec 4.11) ----
  final RxnInt feedStarFilter = RxnInt();
  final RxBool feedDistrictOnly = true.obs;

  // ---- Pagination ----
  /// Page size shared by the community feed and detail review lists.
  static const int reviewPageSize = 10;

  /// Visible review count on the community feed (grows per page).
  final RxInt feedVisible = reviewPageSize.obs;

  /// Visible review count on the Service Detail screen. Starts small so
  /// the contact info stays above the fold; "See all" reveals more.
  final RxInt detailVisible = 3.obs;

  /// Selectable experience tags (translation keys — spec 4.12).
  static const positiveTagKeys = [
    'tag_helpful_staff',
    'tag_fast_response',
    'tag_accurate_info',
    'tag_easy_to_find',
  ];
  static const negativeTagKeys = [
    'tag_long_wait',
    'tag_outdated_info',
    'tag_hard_to_reach',
    'tag_rude_staff',
  ];

  // -------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------

  /// Loads seed reviews plus any locally persisted user reviews.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    reviews.assignAll(ServiceDataSource.seedReviews);
    final raw = _prefs.getString(_kUserReviews);
    if (raw != null) {
      for (final m in (jsonDecode(raw) as List).cast<Map<String, dynamic>>()) {
        reviews.add(Review(
          id: m['id'],
          serviceId: m['serviceId'],
          userId: m['userId'],
          displayName: m['displayName'],
          stars: m['stars'],
          text: m['text'],
          positiveTags: (m['positiveTags'] as List).cast<String>(),
          negativeTags: (m['negativeTags'] as List).cast<String>(),
          helpfulCount: m['helpfulCount'] ?? 0,
          createdAt: DateTime.parse(m['createdAt']),
        ));
      }
    }
    _sortNewestFirst();
  }

  // -------------------------------------------------------------------
  // Queries / aggregates
  // -------------------------------------------------------------------

  /// All reviews for one service, newest first.
  List<Review> reviewsFor(String serviceId) =>
      reviews.where((r) => r.serviceId == serviceId).toList();

  /// Average star rating for a service (0 when unreviewed).
  double averageFor(String serviceId) {
    final list = reviewsFor(serviceId);
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (s, r) => s + r.stars) / list.length;
  }

  /// Review count for a service.
  int countFor(String serviceId) => reviewsFor(serviceId).length;

  /// Star distribution (index 0 = 1★ … index 4 = 5★) for the detail screen.
  List<int> distributionFor(String serviceId) {
    final dist = List<int>.filled(5, 0);
    for (final r in reviewsFor(serviceId)) {
      dist[r.stars - 1]++;
    }
    return dist;
  }

  /// Reviews written by the logged-in user (Profile → My Reviews).
  List<Review> myReviews() {
    final uid = Get.find<AuthController>().user.value?.id;
    if (uid == null) return const [];
    return reviews.where((r) => r.userId == uid).toList();
  }

  /// Community feed with the active star / district filters applied
  /// (spec 4.11). District filtering matches the service's district.
  List<Review> communityFeed() {
    final app = Get.find<AppController>();
    return reviews.where((r) {
      if (feedStarFilter.value != null && r.stars != feedStarFilter.value) {
        return false;
      }
      if (feedDistrictOnly.value) {
        final service = ServiceDataSource.byId(r.serviceId);
        if (service == null || service.district != app.district.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Toggles the feed star filter chip (tap again to clear) and restarts
  /// feed pagination so results show from the top.
  void setFeedStarFilter(int? stars) {
    feedStarFilter.value = feedStarFilter.value == stars ? null : stars;
    feedVisible.value = reviewPageSize;
  }

  /// Toggles district-only mode on the community feed (resets pagination).
  void toggleFeedDistrictOnly() {
    feedDistrictOnly.toggle();
    feedVisible.value = reviewPageSize;
  }

  /// Reveals the next page of the community feed.
  void loadMoreFeed() => feedVisible.value += reviewPageSize;

  /// Resets the detail-screen review pagination (call on screen open).
  void resetDetailReviews() => detailVisible.value = 3;

  /// Reveals the next page of reviews on the Service Detail screen.
  void loadMoreDetailReviews() => detailVisible.value += reviewPageSize;

  // -------------------------------------------------------------------
  // Write-review flow
  // -------------------------------------------------------------------

  /// Resets the form when the Write Review screen opens.
  void startReview() {
    formStars.value = 0;
    formText.value = '';
    formPositiveTags.clear();
    formNegativeTags.clear();
  }

  /// Updates the review text as the user types.
  void onReviewTextChanged(String text) => formText.value = text;

  /// Sets the star rating from the star picker.
  void setStars(int stars) => formStars.value = stars;

  /// Toggles a positive / negative experience tag chip.
  void toggleTag(String key, {required bool positive}) {
    final set = positive ? formPositiveTags : formNegativeTags;
    if (!set.remove(key)) set.add(key);
  }

  /// Submit is enabled only when a star rating plus the minimum text length
  /// are present (spec 4.12).
  bool get canSubmit =>
      formStars.value > 0 && formText.value.trim().length >= 20;

  /// True when the logged-in user already reviewed this service
  /// (one review per user per service — spec 5.4).
  bool hasReviewed(String serviceId) {
    final uid = Get.find<AuthController>().user.value?.id;
    return uid != null &&
        reviews.any((r) => r.serviceId == serviceId && r.userId == uid);
  }

  /// Validates and stores the review. Returns true on success so the UI can
  /// pop back to the Service Detail screen with a success toast.
  bool submitReview(String serviceId) {
    final user = Get.find<AuthController>().user.value;
    if (user == null || !canSubmit) return false;
    if (hasReviewed(serviceId)) return false;

    // Client-side privacy filter: strip phone numbers from review text
    // (spec 4.12 — "No phone numbers or personal info in review text").
    final cleanText = formText.value
        .trim()
        .replaceAll(RegExp(r'(\+?\d[\d\s-]{7,}\d)'), '[number removed]');

    reviews.add(Review(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      serviceId: serviceId,
      userId: user.id,
      displayName: user.displayName,
      stars: formStars.value,
      text: cleanText,
      positiveTags: formPositiveTags.toList(),
      negativeTags: formNegativeTags.toList(),
      createdAt: DateTime.now(),
    ));
    _sortNewestFirst();
    _persistUserReviews();
    return true;
  }

  /// Deletes one of the user's own reviews (Profile → My Reviews).
  void deleteReview(String reviewId) {
    reviews.removeWhere((r) => r.id == reviewId);
    _persistUserReviews();
  }

  /// Increments the helpful counter on a review (requires login per spec).
  void markHelpful(Review review) {
    if (!Get.find<AuthController>().isLoggedIn) {
      AppToast.show('login_required'.tr);
      return;
    }
    review.helpfulCount++;
    reviews.refresh();
    _persistUserReviews();
  }

  // -------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------

  /// Keeps the master list ordered newest-first for every consumer.
  void _sortNewestFirst() =>
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Persists only user-generated reviews (seed data is rebuilt each run).
  void _persistUserReviews() {
    final userOnes = reviews.where((r) => !r.userId.startsWith('seed_'));
    _prefs.setString(
        _kUserReviews,
        jsonEncode(userOnes
            .map((r) => {
                  'id': r.id,
                  'serviceId': r.serviceId,
                  'userId': r.userId,
                  'displayName': r.displayName,
                  'stars': r.stars,
                  'text': r.text,
                  'positiveTags': r.positiveTags,
                  'negativeTags': r.negativeTags,
                  'helpfulCount': r.helpfulCount,
                  'createdAt': r.createdAt.toIso8601String(),
                })
            .toList()));
  }
}
