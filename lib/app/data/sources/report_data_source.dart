import '../../core/config/api_config.dart';
import 'api_client.dart';

/// ---------------------------------------------------------------------------
/// ReportDataSource
/// ---------------------------------------------------------------------------
/// Owns the reports endpoint. The ReportController builds the payload and
/// calls [submit]; the network detail lives here.
/// ---------------------------------------------------------------------------
class ReportDataSource {
  ReportDataSource._();

  /// Stores a user report via `POST /api/reports/`.
  /// [serviceId] is null for app-level reports (e.g. bug reports).
  static Future<void> submit({
    String? serviceId,
    required String reportType,
    required String message,
  }) =>
      ApiClient.post(ApiConfig.reports, {
        if (serviceId != null) 'service': int.tryParse(serviceId),
        'report_type': reportType,
        'message': message,
      });
}
