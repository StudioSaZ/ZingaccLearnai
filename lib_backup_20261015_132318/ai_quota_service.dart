/// Zingacc Learn AI - AI Quota Calculator
/// Preview only. No Firebase writes or payments.
/// Production quotas must be enforced by a trusted backend.

class AiQuotaService {
  AiQuotaService._();

  static const int lifetimeFreeQuestions = 5;
  static const int monthlyPackageQuestions = 150;
  static const int packageDurationDays = 30;

  static const List<int> topUpOptions = [25, 50, 100];

  static int _safe(int value) => value < 0 ? 0 : value;

  /// Free questions are given only once per account.
  static int freeRemaining(int used) {
    final remaining = lifetimeFreeQuestions - _safe(used);
    return remaining > 0 ? remaining : 0;
  }

  /// Unused paid questions remain saved indefinitely.
  static int savedPaidQuestions({
    required int carriedForward,
    required int currentPackageRemaining,
    required int topUpRemaining,
  }) {
    return _safe(carriedForward) +
        _safe(currentPackageRemaining) +
        _safe(topUpRemaining);
  }

  /// Check whether the current monthly plan is active.
  static bool isSubscriptionActive({
    required DateTime now,
    required DateTime? expiresAt,
  }) {
    return expiresAt != null && now.isBefore(expiresAt);
  }

  /// Saved paid questions can be used only with an active plan.
  static int availablePaidQuestions({
    required DateTime now,
    required DateTime? expiresAt,
    required int carriedForward,
    required int currentPackageRemaining,
    required int topUpRemaining,
  }) {
    if (!isSubscriptionActive(
      now: now,
      expiresAt: expiresAt,
    )) {
      return 0;
    }

    return savedPaidQuestions(
      carriedForward: carriedForward,
      currentPackageRemaining: currentPackageRemaining,
      topUpRemaining: topUpRemaining,
    );
  }

  /// Preview balance after activating a new monthly plan.
  static int balanceAfterRenewal({
    required int savedPaidBalance,
  }) {
    return _safe(savedPaidBalance) + monthlyPackageQuestions;
  }

  /// Preview balance after adding a valid top-up.
  /// Returns null if the top-up size is invalid.
  static int? balanceAfterTopUp({
    required int savedPaidBalance,
    required int topUpQuestions,
  }) {
    if (!topUpOptions.contains(topUpQuestions)) {
      return null;
    }

    return _safe(savedPaidBalance) + topUpQuestions;
  }

  /// Detect 120 and 145 question warning thresholds.
  static int? usageWarning({
    required int previousPackageUsed,
    required int currentPackageUsed,
  }) {
    final before = _safe(previousPackageUsed);
    final after = _safe(currentPackageUsed);

    if (before < 120 && after >= 120) {
      return 120;
    }

    if (before < 145 && after >= 145) {
      return 145;
    }

    return null;
  }
}
