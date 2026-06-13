import '../../core/config/api_config.dart';
import '../models/review_model.dart';
import 'api_client.dart';

/// ---------------------------------------------------------------------------
/// ReviewDataSource
/// ---------------------------------------------------------------------------
/// Owns every reviews endpoint and maps the JSON to [Review] models. The
/// ReviewController talks only to this class — it never touches ApiClient.
/// ---------------------------------------------------------------------------
class ReviewDataSource {
  ReviewDataSource._();

  /// All reviews from `GET /api/reviews/` (paginated → flattened).
  static Future<List<Review>> fetchAll() async {
    final rows = await ApiClient.getAllPages(ApiConfig.reviews);
    return rows.map(Review.fromJson).toList();
  }

  /// Creates a review via `POST /api/reviews/` and returns the server record.
  static Future<Review> create({
    required String serviceId,
    required int stars,
    required String text,
    required List<String> positiveTags,
    required List<String> negativeTags,
  }) async {
    final res = await ApiClient.post(ApiConfig.reviewsCreate, {
      'service': serviceId,
      'stars': stars,
      'text': text,
      'positive_tags': positiveTags,
      'negative_tags': negativeTags,
    });
    return Review.fromJson(res as Map<String, dynamic>);
  }

  /// Deletes a review via `DELETE /api/reviews/{id}/`.
  static Future<void> delete(String id) =>
      ApiClient.delete(ApiConfig.review(id));

  /// Registers a helpful vote via `POST /api/reviews/{id}/helpful/`.
  static Future<void> markHelpful(String id) =>
      ApiClient.post(ApiConfig.reviewHelpful(id));
}
