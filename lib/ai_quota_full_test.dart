// Zingacc Learn AI - Full quota calculation tests.
// Preview only: no Firebase, network, payments, or balance writes.
// Place this file in lib/ beside ai_quota_service.dart and ai_quota_model.dart.
import 'ai_quota_service.dart';
import 'ai_quota_model.dart';

void main() {
  var passed = 0;
  void check(String name, bool condition) {
    if (!condition) throw StateError('FAILED: $name');
    passed++;
    print('PASS $passed: $name');
  }

  check('Free initial 5', AiQuotaService.freeRemaining(0) == 5);
  check('Free after 1 used', AiQuotaService.freeRemaining(1) == 4);
  check('Free exhausted', AiQuotaService.freeRemaining(5) == 0);
  check('Free capped after 6', AiQuotaService.freeRemaining(6) == 0);
  check('Negative used safely treated as zero',
      AiQuotaService.freeRemaining(-1) == 5);
  check(
      'Monthly grant constant', AiQuotaService.monthlyPackageQuestions == 150);
  check('Duration constant', AiQuotaService.packageDurationDays == 30);
  check(
      'Saved paid total',
      AiQuotaService.savedPaidQuestions(
          carriedForward: 60,
          currentPackageRemaining: 100,
          topUpRemaining: 25) ==
          185);
  check(
      'Negative balances clamped',
      AiQuotaService.savedPaidQuestions(
          carriedForward: -5,
          currentPackageRemaining: 10,
          topUpRemaining: -1) ==
          10);

  final now = DateTime.utc(2026, 10, 12);
  final expiry = DateTime.utc(2026, 10, 1);
  final future = DateTime.utc(2026, 11, 11);
  final expired = AiQuotaModel(
      freeQuestionsUsed: 5,
      carriedForward: 60,
      topUpRemaining: 25,
      subscriptionExpiresAt: expiry);
  check('Expired plan inactive', !expired.isSubscriptionActive(now));
  check('Expired paid balance still saved', expired.savedPaidBalance == 85);
  check('Expired paid balance unavailable',
      expired.availablePaidBalance(now) == 0);
  check('Renewal preserves saved 85 and adds 150',
      expired.balanceAfterRenewal == 235);
  final active = AiQuotaModel(
      freeQuestionsUsed: 5,
      carriedForward: 85,
      currentPackageRemaining: 150,
      subscriptionExpiresAt: future);
  check(
      'Active plan available balance', active.availablePaidBalance(now) == 235);
  check('Expiry instant is inactive', active.availablePaidBalance(future) == 0);
  check(
      'No expiry is inactive',
      const AiQuotaModel(currentPackageRemaining: 150)
          .availablePaidBalance(now) ==
          0);
  check(
      'Valid top-up 25',
      AiQuotaService.balanceAfterTopUp(
          savedPaidBalance: 85, topUpQuestions: 25) ==
          110);
  check(
      'Valid top-up 50',
      AiQuotaService.balanceAfterTopUp(
          savedPaidBalance: 85, topUpQuestions: 50) ==
          135);
  check(
      'Valid top-up 100',
      AiQuotaService.balanceAfterTopUp(
          savedPaidBalance: 85, topUpQuestions: 100) ==
          185);
  check(
      'Invalid top-up rejected',
      AiQuotaService.balanceAfterTopUp(
          savedPaidBalance: 85, topUpQuestions: 10) ==
          null);
  check(
      'Warning at 120',
      AiQuotaService.usageWarning(
          previousPackageUsed: 119, currentPackageUsed: 120) ==
          120);
  check(
      'Warning at 145',
      AiQuotaService.usageWarning(
          previousPackageUsed: 144, currentPackageUsed: 145) ==
          145);
  check(
      'No repeated warning',
      AiQuotaService.usageWarning(
          previousPackageUsed: 120, currentPackageUsed: 121) ==
          null);
  check('Copy changes count',
      active.copyWith(topUpRemaining: 25).topUpRemaining == 25);
  check('Copy retains expiry by default',
      active.copyWith(carriedForward: 90).subscriptionExpiresAt == future);
  check(
      'Copy explicitly clears expiry',
      active.copyWith(clearSubscriptionExpiry: true).subscriptionExpiresAt ==
          null);
  check(
      'Copy can set a new expiry',
      expired.copyWith(subscriptionExpiresAt: future).subscriptionExpiresAt ==
          future);
  print('ALL $passed QUOTA TESTS PASSED');
}