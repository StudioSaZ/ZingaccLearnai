import 'ai_quota_backend_model.dart';

/// Trusted backend gateway for Zingacc Learn AI.
///
/// No Firestore writes, payments, or quota changes happen here.
/// Requests fail closed until a verified backend is connected.
class AiQuotaBackendService {
  AiQuotaBackendService._();

  static const bool isBackendConnected = false;

  static const int freeLifetimeQuestions = 5;
  static const int monthlyPackageQuestions = 150;
  static const int subscriptionDays = 30;

  static const Set<String> validPackageCodes = {
    AiQuotaPackageCodes.grade5To9,
    AiQuotaPackageCodes.ol,
    AiQuotaPackageCodes.al,
  };

  static const Set<String> validTopUpCodes = {
    AiQuotaPackageCodes.topUp25,
    AiQuotaPackageCodes.topUp50,
    AiQuotaPackageCodes.topUp100,
  };

  static String? validateRequest(AiQuotaBackendRequest request) {
    if (request.requestId.trim().isEmpty) {
      return 'Request ID is required.';
    }

    switch (request.action) {
      case AiQuotaAction.checkBalance:
      case AiQuotaAction.completeQuestion:
      case AiQuotaAction.refundQuestion:
        return null;

      case AiQuotaAction.authorizeQuestion:
        if (request.grade == null || request.grade!.trim().isEmpty) {
          return 'Grade is required.';
        }
        return null;

      case AiQuotaAction.activatePackage:
        if (!validPackageCodes.contains(request.packageCode)) {
          return 'Invalid subscription package.';
        }
        if (request.paymentReference == null ||
            request.paymentReference!.trim().isEmpty) {
          return 'Verified payment reference is required.';
        }
        return null;

      case AiQuotaAction.addTopUp:
        if (!validTopUpCodes.contains(request.packageCode)) {
          return 'Invalid top-up package.';
        }
        if (request.paymentReference == null ||
            request.paymentReference!.trim().isEmpty) {
          return 'Verified payment reference is required.';
        }
        return null;
    }
  }

  static Future<AiQuotaBackendResult> submit(
      AiQuotaBackendRequest request,
      ) async {
    final validationError = validateRequest(request);

    if (validationError != null) {
      return AiQuotaBackendResult(
        success: false,
        requestId: request.requestId,
        message: validationError,
      );
    }

    // Never perform quota changes from the Flutter client.
    // A trusted server must authenticate the user, verify
    // payments, enforce limits, and handle refunds safely.
    return AiQuotaBackendResult(
      success: false,
      requestId: request.requestId,
      message: 'Trusted backend is not connected yet. No quota was changed.',
    );
  }
}
