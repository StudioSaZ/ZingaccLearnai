import 'ai_quota_service.dart';

/// Zingacc Learn AI
/// AI question balance data model.
///
/// This model does not make payments or write to Firebase.
/// Real balances must be verified by a trusted backend.
class AiQuotaModel {
  final int freeQuestionsUsed;
  final int carriedForward;
  final int currentPackageRemaining;
  final int topUpRemaining;
  final DateTime? subscriptionExpiresAt;

  const AiQuotaModel({
    this.freeQuestionsUsed = 0,
    this.carriedForward = 0,
    this.currentPackageRemaining = 0,
    this.topUpRemaining = 0,
    this.subscriptionExpiresAt,
  });

  int get freeRemaining {
    return AiQuotaService.freeRemaining(
      freeQuestionsUsed,
    );
  }

  int get savedPaidBalance {
    return AiQuotaService.savedPaidQuestions(
      carriedForward: carriedForward,
      currentPackageRemaining: currentPackageRemaining,
      topUpRemaining: topUpRemaining,
    );
  }

  bool isSubscriptionActive(DateTime now) {
    return AiQuotaService.isSubscriptionActive(
      now: now,
      expiresAt: subscriptionExpiresAt,
    );
  }

  int availablePaidBalance(DateTime now) {
    return AiQuotaService.availablePaidQuestions(
      now: now,
      expiresAt: subscriptionExpiresAt,
      carriedForward: carriedForward,
      currentPackageRemaining: currentPackageRemaining,
      topUpRemaining: topUpRemaining,
    );
  }

  /// Preview of the total balance after renewal.
  /// Does not activate or charge for a subscription.
  int get balanceAfterRenewal {
    return AiQuotaService.balanceAfterRenewal(
      savedPaidBalance: savedPaidBalance,
    );
  }

  /// Preview of a top-up balance.
  /// Returns null for an unsupported top-up amount.
  int? balanceAfterTopUp(int questions) {
    return AiQuotaService.balanceAfterTopUp(
      savedPaidBalance: savedPaidBalance,
      topUpQuestions: questions,
    );
  }

  /// Create a copy with updated values.
  /// Use clearSubscriptionExpiry to explicitly remove the expiry date.
  AiQuotaModel copyWith({
    int? freeQuestionsUsed,
    int? carriedForward,
    int? currentPackageRemaining,
    int? topUpRemaining,
    DateTime? subscriptionExpiresAt,
    bool clearSubscriptionExpiry = false,
  }) {
    return AiQuotaModel(
      freeQuestionsUsed: freeQuestionsUsed ?? this.freeQuestionsUsed,
      carriedForward: carriedForward ?? this.carriedForward,
      currentPackageRemaining:
      currentPackageRemaining ?? this.currentPackageRemaining,
      topUpRemaining: topUpRemaining ?? this.topUpRemaining,
      subscriptionExpiresAt: clearSubscriptionExpiry
          ? null
          : (subscriptionExpiresAt ?? this.subscriptionExpiresAt),
    );
  }

  /// Convert to a simple map for future integration.
  Map<String, dynamic> toMap() {
    return {
      'free_questions_used': freeQuestionsUsed,
      'carried_forward': carriedForward,
      'current_package_remaining': currentPackageRemaining,
      'top_up_remaining': topUpRemaining,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
    };
  }
}