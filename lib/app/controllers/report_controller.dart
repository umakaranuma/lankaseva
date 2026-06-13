import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../data/models/service_model.dart';
import '../data/sources/api_client.dart';

/// ---------------------------------------------------------------------------
/// ReportController
/// ---------------------------------------------------------------------------
/// Drives the two feedback flows (spec 5.3 "Report incorrect info" +
/// 4.15 "Report a bug"). Holds the reactive form state for each so the
/// screens stay pure UI, validates input, and "submits" the report.
///
/// There is no backend in this build, so submit just acknowledges with a
/// toast; production would POST /report/:serviceId and a /feedback endpoint.
/// Swapping that in only touches this controller.
/// ---------------------------------------------------------------------------
class ReportController extends GetxController {
  // -------------------------------------------------------------------
  // Report incorrect info (per service)
  // -------------------------------------------------------------------

  /// The service whose details are being reported (set on screen open).
  final Rxn<Service> reportTarget = Rxn<Service>();

  /// Which fields the user flagged as wrong (translation keys).
  final RxSet<String> infoIssues = <String>{}.obs;

  /// Free-text detail for the incorrect-info report.
  final RxString infoDetail = ''.obs;

  /// Selectable "what's wrong" options for a service listing.
  static const infoIssueKeys = [
    'issue_phone',
    'issue_address',
    'issue_hours',
    'issue_name',
    'issue_closed',
    'issue_other',
  ];

  /// Resets the incorrect-info form for a given service.
  void startInfoReport(Service service) {
    reportTarget.value = service;
    infoIssues.clear();
    infoDetail.value = '';
  }

  /// Toggles one "what's wrong" chip.
  void toggleInfoIssue(String key) {
    if (!infoIssues.remove(key)) infoIssues.add(key);
  }

  /// Updates the incorrect-info detail text.
  void onInfoDetailChanged(String text) => infoDetail.value = text;

  /// Submit is enabled once at least one issue is flagged.
  bool get canSubmitInfo => infoIssues.isNotEmpty;

  /// Submits the incorrect-info report to POST /api/reports/ and returns true
  /// so the screen can pop with a success message. The network call is
  /// best-effort (fire-and-forget) so the UX stays instant.
  bool submitInfoReport() {
    if (!canSubmitInfo) return false;
    final target = reportTarget.value;
    final message = 'Issues: ${infoIssues.join(', ')}'
        '${infoDetail.value.trim().isEmpty ? '' : '\nDetails: ${infoDetail.value.trim()}'}';
    ApiClient.post(ApiConfig.reports, {
      if (target != null) 'service': int.tryParse(target.id),
      'report_type': 'incorrect_info',
      'message': message,
    }).catchError((_) => null);
    return true;
  }

  // -------------------------------------------------------------------
  // Report a bug (app feedback)
  // -------------------------------------------------------------------

  /// Selected bug category (single choice, translation key).
  final RxnString bugCategory = RxnString();

  /// Bug description text.
  final RxString bugDetail = ''.obs;

  /// Optional contact (email / phone) so the team can follow up.
  final RxString bugContact = ''.obs;

  /// Bug category options.
  static const bugCategoryKeys = [
    'bug_crash',
    'bug_display',
    'bug_slow',
    'bug_feature',
    'bug_other',
  ];

  /// Resets the bug-report form (call on screen open).
  void startBugReport() {
    bugCategory.value = null;
    bugDetail.value = '';
    bugContact.value = '';
  }

  /// Selects a bug category chip.
  void setBugCategory(String key) => bugCategory.value = key;

  /// Updates the bug description / contact fields.
  void onBugDetailChanged(String text) => bugDetail.value = text;
  void onBugContactChanged(String text) => bugContact.value = text;

  /// Submit is enabled once a category is picked and a meaningful
  /// description (10+ chars) is entered.
  bool get canSubmitBug =>
      bugCategory.value != null && bugDetail.value.trim().length >= 10;

  /// Submits the bug report to POST /api/reports/ (best-effort) and returns
  /// true on success so the screen can pop.
  bool submitBug() {
    if (!canSubmitBug) return false;
    final contact = bugContact.value.trim();
    final message = 'Category: ${bugCategory.value}'
        '\n${bugDetail.value.trim()}'
        '${contact.isEmpty ? '' : '\nContact: $contact'}';
    ApiClient.post(ApiConfig.reports, {
      'report_type': 'bug',
      'message': message,
    }).catchError((_) => null);
    return true;
  }
}
