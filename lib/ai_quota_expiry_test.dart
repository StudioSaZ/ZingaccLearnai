import 'ai_quota_model.dart';

void main() {
  final now = DateTime(2026, 10, 12);

  // The previous subscription has expired.
  final expiredAccount = AiQuotaModel(
    freeQuestionsUsed: 5,
    carriedForward: 60,
    currentPackageRemaining: 0,
    topUpRemaining: 25,
    subscriptionExpiresAt: DateTime(2026, 10, 1),
  );

  // Unused questions must remain saved.
  assert(expiredAccount.savedPaidBalance == 85);

  // But they cannot be used without an active plan.
  assert(expiredAccount.availablePaidBalance(now) == 0);

  // Preview a new monthly subscription.
  final renewedBalance = expiredAccount.balanceAfterRenewal;

  assert(renewedBalance == 235);

  // Simulate an active subscription for calculation only.
  final activeAccount = AiQuotaModel(
    freeQuestionsUsed: 5,
    carriedForward: 85,
    currentPackageRemaining: 150,
    topUpRemaining: 0,
    subscriptionExpiresAt: DateTime(2026, 11, 11),
  );

  assert(activeAccount.availablePaidBalance(now) == 235);

  print('Saved after expiry: 85');
  print('Available while expired: 0');
  print('Available after renewal: 235');
  print('ALL EXPIRY TESTS PASSED');
}