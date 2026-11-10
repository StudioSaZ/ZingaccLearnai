/// Zingacc Learn AI
/// Backend request and response models.
///
/// DATA MODELS ONLY.
/// No Firebase writes, payments or quota changes.
///
/// IMPORTANT:
/// These objects do not grant permissions.
/// A trusted backend must authenticate the user,
/// validate each request and enforce all quotas.

enum AiQuotaAction {
  checkBalance,
  authorizeQuestion,
  completeQuestion,
  refundQuestion,
  activatePackage,
  addTopUp,
}

extension AiQuotaActionCode on AiQuotaAction {
  String get code {
    switch (this) {
      case AiQuotaAction.checkBalance:
        return 'check_balance';
      case AiQuotaAction.authorizeQuestion:
        return 'authorize_question';
      case AiQuotaAction.completeQuestion:
        return 'complete_question';
      case AiQuotaAction.refundQuestion:
        return 'refund_question';
      case AiQuotaAction.activatePackage:
        return 'activate_package';
      case AiQuotaAction.addTopUp:
        return 'add_top_up';
    }
  }
}

/// Request information sent to a trusted backend.
///
/// The backend must determine the user's identity
/// from verified authentication credentials.
/// Never trust a UID or admin flag supplied by
/// the Flutter client.
class AiQuotaBackendRequest {
  final AiQuotaAction action;
  final String requestId;
  final String? grade;
  final String? packageCode;
  final String? paymentReference;

  const AiQuotaBackendRequest({
    required this.action,
    required this.requestId,
    this.grade,
    this.packageCode,
    this.paymentReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': action.code,
      'request_id': requestId,
      if (grade != null) 'grade': grade,
      if (packageCode != null) 'package_code': packageCode,
      if (paymentReference != null) 'payment_reference': paymentReference,
    };
  }
}

/// Read-only balance information returned
/// by the trusted backend.
class AiQuotaBackendBalance {
  final int freeRemaining;
  final int savedPaidBalance;
  final int availablePaidBalance;
  final int monthlyQuestionsGranted;
  final int monthlyQuestionsUsed;
  final DateTime? subscriptionExpiresAt;
  final bool subscriptionActive;

  const AiQuotaBackendBalance({
    required this.freeRemaining,
    required this.savedPaidBalance,
    required this.availablePaidBalance,
    required this.monthlyQuestionsGranted,
    required this.monthlyQuestionsUsed,
    required this.subscriptionActive,
    this.subscriptionExpiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'free_remaining': freeRemaining,
      'saved_paid_balance': savedPaidBalance,
      'available_paid_balance': availablePaidBalance,
      'monthly_questions_granted': monthlyQuestionsGranted,
      'monthly_questions_used': monthlyQuestionsUsed,
      'subscription_active': subscriptionActive,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
    };
  }
}

/// Result returned by the trusted backend.
///
/// success must only be trusted after receiving
/// and validating an authenticated server response.
class AiQuotaBackendResult {
  final bool success;
  final String message;
  final String? requestId;
  final AiQuotaBackendBalance? balance;

  const AiQuotaBackendResult({
    required this.success,
    required this.message,
    this.requestId,
    this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      if (requestId != null) 'request_id': requestId,
      if (balance != null) 'balance': balance!.toMap(),
    };
  }
}

/// Package identifiers.
///
/// Prices and entitlements must be verified
/// by the backend, not accepted from the app.
class AiQuotaPackageCodes {
  AiQuotaPackageCodes._();

  static const String grade5To9 = 'grade_5_to_9_150';
  static const String ol = 'ol_150';
  static const String al = 'al_150';

  static const String topUp25 = 'top_up_25';
  static const String topUp50 = 'top_up_50';
  static const String topUp100 = 'top_up_100';
}